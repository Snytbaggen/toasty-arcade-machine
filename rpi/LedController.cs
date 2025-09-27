using System.Device.Spi;
using System.Drawing;
using Iot.Device.Ws28xx;

namespace Toastmachine.rpi;

public class LedController
{
    private const int count = 5;
    private readonly Ws28xx neo;
    
    public LedController()
    {
        SpiConnectionSettings settings = new(1, 0)
        {
            ClockFrequency = 2_400_000,
            Mode = SpiMode.Mode0,
            DataBitLength = 8
        };
        using var spi = SpiDevice.Create(settings);

        neo = new Ws2812b(spi, count);
        var img = neo.Image;
        for (var i = 0; i < count; i++)
        {
            img.SetPixel(i, 0, Color.Aqua);
        }
        neo.Update();
    }

    public void TurnOff()
    {
        neo.Image.Clear();
        neo.Update();
    }
}
