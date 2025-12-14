extends Button

func _on_button_down():
	print("Sending signal")
	RpiGpio.emit_signal("StartNfcTagRead")
