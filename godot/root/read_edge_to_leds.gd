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

@export var ambilight = false

const y_step = 50 ## Y sample step. 800 / 16 (LED count)
const screen_width = Global.screen_width + 2 ## X sample step. Screen height + 2

var leds: Array = Array()

func _init():
	for i in range(0, 32):
		leds.append(Color.BLACK)

func _process(_delta):
	var image = Image.new()
	
	@warning_ignore("integer_division")
	var width = screen_width/4 if ambilight else screen_width
	image.copy_from(get_viewport().get_texture().get_image())
	image.resize(482, 16, Image.INTERPOLATE_TRILINEAR)
	
	var i = 0
	for y in range(15, -1, -1):
		var pixel := image.get_pixel(width-1, y)
		leds[i] = Color(pixel.r, pixel.g, pixel.b)
		i += 1
		
	for y in range(0, 16, 1):
		var pixel := image.get_pixel(0, y)
		leds[i] = Color(pixel.r, pixel.g, pixel.b)
		i += 1

	RpiGpio.emit_signal("LedStripUpdate", leds)
