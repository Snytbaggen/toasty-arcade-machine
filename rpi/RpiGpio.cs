using Godot;
using System.Device.Gpio;

namespace Toastmachine.rpi;

public partial class RpiGpio : Node
{
    private static class Pins
    {
        public const int RightButton = 3;
        public const int CenterButton = 4;
        public const int LeftButton = 5;
    }

    private readonly InputInstance _input = Input.Singleton;
    private GpioController _gpioController;

    public override void _Ready()
    {
        try
        {
            _gpioController = new GpioController();
            _gpioController.OpenPin(Pins.RightButton, PinMode.InputPullUp);
            _gpioController.OpenPin(Pins.CenterButton, PinMode.InputPullUp);
            _gpioController.OpenPin(Pins.LeftButton, PinMode.InputPullUp);
        }
        catch
        {
            GD.Print("Failed to set up GPIO");
        }
    }

    public override void _Process(double delta)
    {
        if (_gpioController == null)
        {
            return;
        }
        
        SendAction("btn_right", _gpioController.Read(Pins.RightButton) == PinValue.Low);
        SendAction("btn_center", _gpioController.Read(Pins.CenterButton) == PinValue.Low);
        SendAction("btn_left", _gpioController.Read(Pins.LeftButton) == PinValue.Low);
    }

    public override void _ExitTree()
    {
        base._ExitTree();
        _gpioController?.Dispose();
    }

    private void SendAction(string action, bool pressed)
    {
        _input.ParseInputEvent(
            new InputEventAction()
            {
                Action = action,
                Pressed = pressed
            }
        );
    }
}
