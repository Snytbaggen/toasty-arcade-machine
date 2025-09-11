extends Node
@onready var game_viewport := $GameViewport
@onready var game_display := $GameDisplay

func _ready():
	game_display.texture = game_viewport.get_texture()
	game_display.rotation_degrees = -90
	game_display.size = Vector2(800, 480)
