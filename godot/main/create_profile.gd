extends Node2D

@onready var pending_tag = Global.pending_tag

func _ready():
	if pending_tag == "":
		get_parent()._on_back()
	Global.user_login.connect(_on_user_login)

func _on_create_account():
	var username = $TxtUsername.text
	if username == "":
		$AudioFailure.play()
		return
	
	UserDatabase.CreateUser(username, pending_tag, "", true)
	RpiGpio.NfcTagDetected.emit(pending_tag)

func _on_user_login(_user_id: int):
	if get_tree() == null:
		return
	var node = load("res://main/toast_counter.tscn").instantiate()
	get_parent()._on_navigation(node, "right")

func _show_keyboard():
	$OnscreenKeyboard.show()

func _hide_keyboard():
	$OnscreenKeyboard.hide()
