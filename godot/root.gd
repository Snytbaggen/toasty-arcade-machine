extends Node

func _input(event):
	var old_pos = event.position.rotated(0)
	event.position.x = Global.screen_width - old_pos.y
	event.position.y = old_pos.x
	print(event.position.x)
	$GameViewport.push_input(event)
