extends Button

func _on_button_down():
	Global.init_scene_change(Global.SCENE_FLAPPY_BIRD)
	# RpiGpio.emit_signal("StartNfcTagRead")
