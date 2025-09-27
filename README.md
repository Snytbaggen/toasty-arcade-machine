# Prerequisites
* Raspberry Pi 4 or greater, tested with 4 GB ram.
* SPI ports enabled on the Raspberry Pi (done in Raspi config)

# Pinouts
Physical pin in parentheses. Names taken from https://pinout.xyz

## Buttons
GPIO 3 (5): Right button \
GPIO 4 (7): Center button \
GPIO 5 (29): Left button \
PWM 0  (32): Center button LED

All buttons are connected to ground, with each pin set up with `PinMode.InputPullUp`. The center button LED uses 12 V,
so the output from the GPIO PWM pin is fed through an opto coupler which controls an NFET transistor.

## RC522 (NFC)
3v3 Power (17): 3v3 \
SPI0 MOSI (19): MOSI \
SPI0 MISO (21): MISO \
GPIO 25   (22): RST \
SPI0 SCLK (23): SCK \
SPI0 CE0  (24): SDA \
Ground    (25): GND

The IRQ pin on the RC522 unit is unconnected.

## WS2812b LED strip
SPI1 MOSI (38): Data

The data line is connected through a logic level shifter. The power line of the LED strip is connected directly
to a 12V power line.

# BoM
* 1x Raspberry Pi 4 (or newer) with at least 4 GB of RAM
* 2x Sanwa 30mm arcade button
* 1x 100 mm arcade button with built-in LED
* 1x 480x800 screen with built-in touch 
* 2 strips of WS2812b compatible LEDs, each with 16 LEDS
* 1x MINI RFIC-RC522 controller
* 1x miniature USB hub
* 1x audio amplifier with speaker
