extends Node

signal scene_change(new_scene: Node)

@warning_ignore("unused_signal")
signal scene_back()

signal user_login(user_id: int)
signal user_logout()
signal unused_tag_read(tag_id: String)

const screen_width = 480

const SCENE_MAIN = "res://main/main.tscn"
const SCENE_FLAPPY_BIRD = "res://games/flappy_bird/FlappyBird.tscn"

var current_user: int = -1
var pending_tag = ""

func _ready():
	RpiGpio.NfcTagDetected.connect(_on_tag_read)

func _on_tag_read(tag_id: String):
	# Scanning an unused tag will log out the current user
	current_user = UserDb.get_user_id_by_tag(tag_id)
	if current_user == -1:
		pending_tag = tag_id
		unused_tag_read.emit(tag_id)
	else:
		pending_tag = ""
		user_login.emit(current_user)

func logout():
	current_user = -1
	user_logout.emit()

func init_scene_change(path: String):
	match path:
		SCENE_MAIN:
			scene_change.emit(preload(SCENE_MAIN).instantiate())
		SCENE_FLAPPY_BIRD:
			scene_change.emit( preload(SCENE_FLAPPY_BIRD).instantiate())
