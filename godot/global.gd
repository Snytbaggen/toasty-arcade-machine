extends Node

signal scene_change(new_scene: Node)

@warning_ignore("unused_signal")
signal scene_back()

const screen_width = 480

const SCENE_MAIN = "res://main/main.tscn"
const SCENE_FLAPPY_BIRD = "res://games/flappy_bird/FlappyBird.tscn"

func init_scene_change(path: String):
	match path:
		SCENE_MAIN:
			scene_change.emit(preload(SCENE_MAIN).instantiate())
		SCENE_FLAPPY_BIRD:
			scene_change.emit( preload(SCENE_FLAPPY_BIRD).instantiate())
