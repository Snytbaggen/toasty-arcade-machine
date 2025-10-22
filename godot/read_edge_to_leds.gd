extends Node

## Script for controlling the LED lights by looking at the edge rows of the
## viewport. This works by extending the screen 2 pixels to the side (and
## offsetting it by 1 pixel to compensate) and sampling the extra rows at
## certain intervals. These colors are sent through a signal to the Raspberry
## Pi.
##
## This script can be used on any node with the extra size, preferrably as
## high up in the hirerarchy. [b]Only one script should be active at any given
## time![/b]

const x_step = 50 ## X sample step. 800 / 16 (LED count)
const y_step = 482 ## Y sample step. Screen width + 2
var leds: Array = Array()

func _init():
	for i in range(0, 32):
		leds.append(Color.BLACK)

func _process(delta):
	var texture = get_viewport().get_texture()
	var image := texture.get_image()
	
	var i = 0
	for x in range(0, y_step, y_step-1): ## Read first and last column
		for y in range(0, 800, x_step): ## Sample column at x_step intervals
			var pixel := image.get_pixel(x, y)
			leds[i] = Color(pixel.r, pixel.g, pixel.b)
			i += 1

	RpiGpio.emit_signal("LedStripUpdate", leds)
	
