extends Node2D

var animation_time = 0.25

var animation_stack = []
func _ready():
	var current_node: NavigationNode = load("res://main/home.tscn").instantiate()
	current_node.navigate_back.connect(animate_back)
	current_node.navigate_to.connect(animate_to)
	$Content.add_child(current_node)

func animate_to(new_scene: NavigationNode, direction: String):
	var in_marker: Marker2D
	var out_marker: Marker2D
	match direction:
		"left":
			in_marker = $MarkerLeft
			out_marker = $MarkerRight
		"right":
			in_marker = $MarkerRight
			out_marker = $MarkerLeft
		"top":
			in_marker = $MarkerTop
			out_marker = $MarkerBottom
		"bottom":
			in_marker = $MarkerBottom
			out_marker = $MarkerTop
		_:
			print("Error, unknown direction ", direction)
			return

	# Save current scene to the stack
	var current_scene = $Content.get_child(0)
	animation_stack.push_front(current_scene)
	
	# Animate out current content
	var out_tween = get_tree().create_tween()
	out_tween.tween_property(
		current_scene, "position", out_marker.position, animation_time
	).set_trans(Tween.TRANS_SINE)
	out_tween.tween_callback(remove_current_scene)
	
	# Animate in new content
	$Content.add_child(new_scene)
	new_scene.navigate_back.connect(animate_back)
	new_scene.navigate_to.connect(animate_to)
	new_scene.set_start_position(in_marker.position)
	var in_tween = get_tree().create_tween()
	in_tween.tween_property(
		new_scene, "position", $MarkerCenter.position, animation_time
	).set_trans(Tween.TRANS_SINE)

func remove_current_scene():
	$Content.remove_child(animation_stack.front())

func animate_back(to_start: bool):
	if animation_stack.size() == 0:
		print("Empty animation stack!")
		return
	
	# Animate out and free current scene
	var current = $Content.get_child(0)
	var out_tween = get_tree().create_tween()
	out_tween.tween_property(
		current, "position", current.start_position, animation_time
	)
	out_tween.tween_callback(current.queue_free)
	
	if to_start:
		# Free all scenes except the final scene
		while (animation_stack.size() > 1):
			var scene = animation_stack.pop_front()
			scene.queue_free()
	
	# Animate in old scene
	var old_scene = animation_stack.pop_front()
	$Content.add_child(old_scene)
	var tweener = get_tree().create_tween()
	tweener.tween_property(
		old_scene, "position", $MarkerCenter.position, animation_time
	).set_trans(Tween.TRANS_SINE)
