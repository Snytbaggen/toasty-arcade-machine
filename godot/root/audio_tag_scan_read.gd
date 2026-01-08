extends AudioStreamPlayer

func _init():
	RpiGpio.NfcTagDetected.connect(_nfc_tag_detected)

func _nfc_tag_detected(id: String):
	play()
