extends Button

func _on_button_down():
	if OS.is_debug_build():
		get_tree().quit();
	else:
		UserDb.save_all()
		OS.execute("sudo", ["shutdown", "-h", "now"])
		get_tree().quit();
