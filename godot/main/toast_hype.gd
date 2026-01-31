extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("btn_center"):
		$Rgb.show_rgb()
		$AudioToastBuy.play()
