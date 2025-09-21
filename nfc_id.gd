extends Label

func _ready():
	RpiGpio.NfcTagDetected.connect(on_nfc_tag_read)
	
func on_nfc_tag_read(new_tag):
	text = new_tag
