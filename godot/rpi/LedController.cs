using System;
using System.Device.Spi;
using System.Linq;
using Godot;
using Godot.Collections;
using Iot.Device.Ws28xx;
using Color = System.Drawing.Color;

namespace Toastmachine.rpi;

public class LedController
{
    private const int LedCount = 28;
    private readonly Ws28xx _neo;
    private readonly RawPixelContainer _img;
    
    public LedController()
    {
        SpiConnectionSettings settings = new(1, 0)
        {
            ClockFrequency = 2_400_000,
            Mode = SpiMode.Mode0,
            DataBitLength = 8
        };

        using var spi = SpiDevice.Create(settings);

        _neo = new Ws2812b(spi, LedCount);
        _img = _neo.Image;
        
        GD.Print("Failed to initialize led controller");
    }

    public void UpdateImage(Array<Vector3> leds)
    {
        if (leds.Count < LedCount) return;
        
        foreach (var item in leds.Select((led, i) => new { led, i }))
        {
            _img.SetPixel(
                item.i,
                0,
                Color.FromArgb(
                    255,
                    (int)(item.led.X * 255),
                    (int)(item.led.Y * 255),
                    (int)(item.led.Z * 255)
                    )
                );
        }
        TryUpdateLeds();
    }

    private void TryUpdateLeds()
    {
        try
        {
            _neo.Update();
        }
        catch (Exception ex)
        {
            GD.Print("Failed to update led controller: " +  ex.Message);
        }
    }
    
    public void TurnOff()
    {
        _neo.Image.Clear();
        _neo.Update();
    }
}
