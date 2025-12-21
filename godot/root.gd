extends Node

@export var initial_scene: PackedScene

func _ready():
	Global.scene_change.connect(on_scene_change)
	Global.scene_back.connect(on_scene_back)
	$GameViewport.add_child(initial_scene.instantiate())

func _input(event):
	if event is InputEventMouse:
		var old_pos = event.position.rotated(0)
		event.position.x = Global.screen_width - old_pos.y
		event.position.y = old_pos.x
	$GameViewport.push_input(event)

func on_scene_change(path: String, new_scene: Node):
	var last_index = $GameViewport.get_child_count() - 1
	if last_index >= 0:
		$GameViewport.get_child(last_index).set_visible(false)
	$GameViewport.add_child(new_scene)

func on_scene_back():
	var children = $GameViewport.get_child_count()
	if children < 2:
		return
	
	$GameViewport.get_child(children - 1).queue_free()
	$GameViewport.get_child(children - 2).set_visible(true)
