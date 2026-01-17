using System;
using System.Device.Gpio;
using System.Device.Spi;
using System.Threading;
using Iot.Device.Mfrc522;
using Iot.Device.Rfid;

namespace Toastmachine.rpi;

public class NfcController
{
    private readonly MfRc522 _mfRc522;
    private bool _shouldStopNfcTagRead;

    public NfcController(GpioController gpioController)
    {
        var connection = new SpiConnectionSettings(0, 0);
        var spi = SpiDevice.Create(connection);

        _mfRc522 = new MfRc522(spi, RpiPins.NfcResetPin, gpioController);
        _mfRc522.Enabled = false;
    }

    public void StopNfcTagRead()
    {
        _shouldStopNfcTagRead = true;
    }

    public string StartTagRead()
    {
        bool res;
        Data106kbpsTypeA card;
        _mfRc522.Enabled = true;
        _shouldStopNfcTagRead = false;

        do
        {
            res = _mfRc522.ListenToCardIso14443TypeA(out card, TimeSpan.FromSeconds(2));
            if (!res)
            {
                Thread.Sleep(200);
            }
        } while (!res && !_shouldStopNfcTagRead);

        _mfRc522.Enabled = false;
        return Convert.ToHexString(card.NfcId);
    }
}
