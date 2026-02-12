extends Button

func _on_button_down():
	Global.scene_back.emit()
