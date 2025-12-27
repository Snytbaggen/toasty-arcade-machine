using System;
using System.Collections.Generic;
using System.Device.Gpio;
using System.Threading.Tasks;
using Godot;
using Godot.Collections;

namespace Toastmachine.rpi;

public partial class RpiGpio : Node
{
    [Signal]
    public delegate void NfcTagDetectedEventHandler(string id);

    [Signal]
    public delegate void StartNfcTagReadEventHandler();

    [Signal]
    public delegate void StopNfcTagReadEventHandler();

    [Signal]
    public delegate void CenterLedUpdateEventHandler(double dutyCycle);
    
    [Signal]
    public delegate void LedStripUpdateEventHandler(Array<Color> leds);

    private readonly Queue<Action> _deferredActionQueue = new();

    private readonly InputInstance _input = Input.Singleton;
    private GpioController _gpioController;
    private bool _isGpioControllerDisposed;
    private string _lastReadTag;

    private NfcController _nfcController;
    private LedController _ledController;
    private readonly IEnumerable<Pin> _buttons = Pin.GetPins();

    public override void _Ready()
    {
        // Attempt to set up GPIO related things
        try
        {
            _gpioController = new GpioController();
            _nfcController = new NfcController(_gpioController);

            // Set up button pins
            foreach (var button in _buttons) { button.Setup(_gpioController); }
        }
        catch
        {
            GD.Print("Failed to set up GPIO");
        }
        
        // While interacting with hardware, the LED controller is SPI-based and can be set up separately
        _ledController = new LedController();

        // Setup signal listeners
        StartNfcTagRead += ReadNfcTag;
        StopNfcTagRead += () => _nfcController?.StopNfcTagRead();

        LedStripUpdate += leds => _ledController.UpdateLeds(leds);
        CenterLedUpdate += dutyCycle => _ledController.UpdateCenterLed(dutyCycle);
    }

    public override void _Process(double delta)
    {
        if (_gpioController == null || _isGpioControllerDisposed) return;
        
        // Read (and send) buttons
        foreach (var button in _buttons) { button.Read(_gpioController); }

        // Loop through any deferred actions at the end of the frame.
        // There's no limit to the executed actions as of now, as we only expect the occasional NFC read to show up
        // here. But if more async things are added in the future we might want to look at this.
        while (_deferredActionQueue.TryDequeue(out var action))
        {
            action();
        }
    }

    private void ReadNfcTag()
    {
        if (_nfcController == null) return;

        // This must be run as a task, as it will otherwise lock up the thread until a tag is read
        Task.Run(() =>
        {
            var newTag = _nfcController.StartTagRead();

            // New tag read, broadcast it. Does not account for the same tag being read twice. 
            EmitSignalOnMainThread(SignalName.NfcTagDetected, newTag);
            _lastReadTag = newTag;
        });
    }

    public override void _ExitTree()
    {
        _ledController?.TurnOff();
        _nfcController?.StopNfcTagRead();
        _gpioController?.Dispose();
        _isGpioControllerDisposed = true;
        base._ExitTree();
    }
    
    private void EmitSignalOnMainThread(StringName signal, params Variant[] args)
    {
        DeferToMainThread(() => { EmitSignal(signal, args); });
    }

    private void DeferToMainThread(Action action)
    {
        if (action != null)
            _deferredActionQueue.Enqueue(action);
    }
}
