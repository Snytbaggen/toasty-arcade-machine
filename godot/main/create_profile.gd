extends Node2D

@onready var pending_tag = Global.pending_tag

func _ready():
	if pending_tag == "":
		get_parent()._on_back()

func _on_create_account():
	var username = $TxtUsername.text
	if username == "":
		$AudioFailure.play()
		return
	
	UserDatabase.CreateUser(username, pending_tag, "", true)
	RpiGpio.NfcTagDetected.emit(pending_tag)

func _show_keyboard():
	$OnscreenKeyboard.show()

func _hide_keyboard():
	$OnscreenKeyboard.hide()
