using System;
using System.Device.Pwm;
using System.Device.Spi;
using System.Linq;
using Godot;
using Godot.Collections;
using Iot.Device.Ws28xx;

namespace Toastmachine.rpi;

public class LedController
{
    private const int LedCount = 32;
    private readonly Ws28xx _neo;
    private readonly RawPixelContainer _img;
    private readonly PwmChannel _pwm;

    private float _ledBrightness = 0.25f;
    
    public LedController()
    {
        try
        {
              _pwm = PwmChannel.Create(0, 0, 10000, 0);
              _pwm.Start();
              _pwm.DutyCycle = 0.5f;
             
             SpiConnectionSettings settings = new(1, 0)
             {
                 ClockFrequency = 2_400_000,
                 Mode = SpiMode.Mode0,
                 DataBitLength = 8
             };
        
             using var spi = SpiDevice.Create(settings);
             
             _neo = new Ws2812b(spi, LedCount);
             _img = _neo.Image;
        }
        catch (Exception e)
        {
            GD.Print("Failed to create pwm channel: " + e.Message);
        }
    }

    public void UpdateBrightness(float brightness)
    {
        _ledBrightness = float.Clamp(brightness, 0.0f, 1.0f);
    }
    
    public void UpdateCenterLed(double dutyCycle)
    {
        if (_pwm != null) _pwm.DutyCycle = dutyCycle;
    }
    
    public void UpdateLeds(Array<Color> leds)
    {
        if (leds.Count < LedCount) return;
        
        var brightness = _ledBrightness * 255;
        foreach (var item in leds.Select((led, i) => new { led, i }))
        {
            _img?.SetPixel(
                item.i,
                0,
                System.Drawing.Color.FromArgb(
                    (int)(item.led.R * brightness),
                    (int)(item.led.G * brightness),
                    (int)(item.led.B * brightness)
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
            if (_neo != null)
            {
                GD.Print("Failed to update led controller: " +  ex.Message);
            }
        }
    }
    
    public void TurnOff()
    {
        try
        {
            _img.Clear(System.Drawing.Color.Black);
            TryUpdateLeds();
            _pwm.Stop();
        }
        catch (Exception ex)
        {
            GD.Print("Failed to turn off led controller: " + ex.Message);
        }
    }
}
