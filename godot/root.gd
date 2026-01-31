extends Node

@export var initial_scene: PackedScene

var scene_stack = []

func _ready():
	Global.scene_change.connect(_on_scene_change)
	Global.scene_back.connect(_on_scene_back)
	$GameViewport.add_child(initial_scene.instantiate())
	if OS.is_debug_build():
		$DevLabel.visible = true

func _input(event):
	if event is InputEventMouse:
		var old_pos = event.position.rotated(0)
		event.position.x = Global.screen_width - old_pos.y
		event.position.y = old_pos.x
	$GameViewport.push_input(event)

func _process(_delta):
	if Input.is_action_just_pressed("mock_tag"):
		RpiGpio.NfcTagDetected.emit("049B115Ew6F6180")

func _on_scene_change(new_scene: Node):
	# Removing and saving the current scene allows it to be restored later, while
	# keeping it from running in the background
	var current = $GameViewport.get_child(0)
	scene_stack.append(current)
	$GameViewport.remove_child(current)
	$GameViewport.add_child(new_scene)

func _on_scene_back():
	$GameViewport.get_child(0).queue_free()
	$GameViewport.add_child(scene_stack.pop_front())
