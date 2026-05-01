extends Button

@export var keycode: Key
signal key_event(keycode: Key, pressed: bool)


func _on_button_down():
	key_event.emit(keycode, true)


func _on_button_up():
	key_event.emit(keycode, false)
