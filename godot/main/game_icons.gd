extends Node2D

signal title_change(title: String)

var anim_duration = 0.2

var icons: Array = []

var left_index = 0
var center_index = 1
var right_index = 2

func _ready():
	icons.append($IconFlappyBird)
	icons.append($IconDinoGame)
	icons.append($IconFlappyBird2)
	icons.append($IconDinoGame2)
	
	icons[left_index].position = $MarkerLeft.position
	icons[center_index].position = $MarkerCenter.position
	icons[right_index].position = $MarkerRight.position
	
	update_focus(true)
	update_title()

func update(action: String):
	animate_out(action)
	
	# Update indices
	if action == "btn_right":
		center_index = center_index + 1 if center_index < icons.size() - 1 else 0
	elif action == "btn_left":
		center_index = center_index - 1 if center_index > 0 else icons.size() - 1
	left_index = center_index - 1 if center_index > 0 else icons.size() - 1
	right_index = center_index + 1 if center_index < icons.size() - 1 else 0

	animate_in(action)

	update_focus()
	update_title()

func animate_out(action: String):
	var edge_tween = get_tree().create_tween()
	var center_out_tween = get_tree().create_tween()
	var center_in_tween = get_tree().create_tween()
	if action == "btn_right":
		edge_tween.tween_property(icons[left_index], "position", $MarkerLeftOos.position, anim_duration)
		center_out_tween.tween_property(icons[center_index], "position", $MarkerLeft.position, anim_duration)
		center_in_tween.tween_property(icons[right_index], "position", $MarkerCenter.position, anim_duration)
	elif action == "btn_left":
		edge_tween.tween_property(icons[right_index], "position", $MarkerRightOos.position, anim_duration)
		center_out_tween.tween_property(icons[center_index], "position", $MarkerRight.position, anim_duration)
		center_in_tween.tween_property(icons[left_index], "position", $MarkerCenter.position, anim_duration)

func animate_in(action: String):
	var edge_tween = get_tree().create_tween()
	if action == "btn_right":
		var icon = icons[right_index]
		icon.position = $MarkerRightOos.position
		edge_tween.tween_property(icon, "position", $MarkerRight.position, anim_duration)
	elif action == "btn_left":
		var icon = icons[left_index]
		icon.position = $MarkerLeftOos.position
		edge_tween.tween_property(icon, "position", $MarkerLeft.position, anim_duration)

func update_focus(instant: bool = false):
	icons[left_index].on_focus_change(false, instant)
	icons[center_index].on_focus_change(true, instant)
	icons[right_index].on_focus_change(false, instant)

func update_title():
	title_change.emit(icons[center_index].title)

func _process(_delta):
	if Input.is_action_just_pressed("btn_left"):
		update("btn_left")
	elif Input.is_action_just_pressed("btn_right"):
		update("btn_right")
	elif Input.is_action_just_pressed("btn_center"):
		_on_play_button_down()

func _on_play_button_down():
	print("Play button down")
	var scene = icons[center_index].scene
	Global.scene_change.emit(scene.instantiate())
