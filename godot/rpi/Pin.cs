using System.Collections;
using System.Collections.Generic;
using System.Device.Gpio;
using Godot;

namespace Toastmachine.rpi;

// ReSharper disable MemberCanBePrivate.Global
public class Pin
{
    public required string Action { get; set; }
    public required int GpioPin { get; set; }
    public PinValue TriggerValue { get; set; } =  PinValue.Low;
    public PinMode PinMode { get; set; } = PinMode.InputPullUp;

    private readonly InputInstance _input = Input.Singleton;
    private PinValue? _lastValue;

    public void Setup(GpioController gpioController)
    {
        GD.Print("Setting up pin " + Action);
        gpioController.OpenPin(GpioPin, PinMode);
    }

    public void Read(GpioController gpioController)
    {
        GD.Print("Reading pin " + Action);
        var currentValue = gpioController.Read(GpioPin);
        var isTriggered = currentValue == TriggerValue;
        
        // We only need to send an update if the value has changed
        if (currentValue != _lastValue)
        {
            _input.ParseInputEvent(
                new InputEventAction
                {
                    Action = Action,
                    Pressed = isTriggered
                });
        }
        _lastValue = currentValue;
    }

    public static IEnumerable<Pin> GetPins()
    {
        return
        [
            new Pin
            {
                Action = "btn_right",
                GpioPin = RpiPins.RightButton,
            },
            new Pin
            {
                Action = "btn_center",
                GpioPin = RpiPins.CenterButton,
            },
            new Pin
            {
                Action = "btn_left",
                GpioPin = RpiPins.LeftButton,
            },
        ];
    }
}
