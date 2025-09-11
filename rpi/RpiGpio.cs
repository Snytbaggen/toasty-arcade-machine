using Godot;
using System.Device.Gpio;

namespace Toastmachine.rpi;

public partial class RpiGpio : Node
{
    private static class Pins
    {
        public const int RightButton = 3;
    }

    private readonly InputInstance _input = Input.Singleton;
    private GpioController _gpioController;

    public override void _Ready()
    {
        try
        {
            _gpioController = new GpioController();
            _gpioController.OpenPin(Pins.RightButton, PinMode.InputPullUp);
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

        _input.ParseInputEvent(
            new InputEventAction()
            {
                Action = "btn_right",
                Pressed = _gpioController.Read(Pins.RightButton) == PinValue.Low
            }
        );
    }

    public override void _ExitTree()
    {
        base._ExitTree();
        _gpioController?.Dispose();
    }
}
