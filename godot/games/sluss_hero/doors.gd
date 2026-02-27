extends Node2D
class_name Doors

@onready var left: AnimatedSprite2D = $LeftDoorSprite
@onready var right: AnimatedSprite2D = $RightDoorSprite

@onready var lighting_root: Node2D = $"../Lighting"

signal both_doors_open

# 0 = stängd, 1 = halv, 2 = öppen
const CLOSED_FRAME := 0
const HALF_FRAME := 1
const OPEN_FRAME := 2

@export var step_time := 0.08

var is_running := false
var game_over := false

var left_target_open := false
var right_target_open := false

var step_accum := 0.0


func _ready() -> void:
	left.play("toggle")
	right.play("toggle")
	left.pause()
	right.pause()

	_set_frame(left, CLOSED_FRAME)
	_set_frame(right, CLOSED_FRAME)

	_update_lighting()


func _process(delta: float) -> void:
	if not is_running or game_over:
		return

	var left_pressed := Input.is_action_just_pressed("btn_left")
	var right_pressed := Input.is_action_just_pressed("btn_right")
	var pressed_both := left_pressed and right_pressed

	if left_pressed:
		left_target_open = not left_target_open

	if right_pressed:
		right_target_open = not right_target_open

	step_accum += delta
	var changed := false

	while step_accum >= step_time:
		step_accum -= step_time
		changed = _step_doors_toward_targets() or changed

		if changed:
			_update_lighting()

		if not lighting_root.stage_light_on and _is_leaking(left) and _is_leaking(right):
			_trigger_game_over(pressed_both)
			return


func _step_doors_toward_targets() -> bool:
	var changed := false
	changed = _step_one(left, left_target_open) or changed
	changed = _step_one(right, right_target_open) or changed
	return changed


func _step_one(sprite: AnimatedSprite2D, target_open: bool) -> bool:
	var f := sprite.frame

	if target_open:
		if f < OPEN_FRAME:
			_set_frame(sprite, f + 1)
			return true
	else:
		if f > CLOSED_FRAME:
			_set_frame(sprite, f - 1)
			return true

	return false


func _set_frame(sprite: AnimatedSprite2D, f: int) -> void:
	sprite.frame = clampi(f, CLOSED_FRAME, OPEN_FRAME)
	sprite.pause()


func _is_leaking(sprite: AnimatedSprite2D) -> bool:
	return sprite.frame >= HALF_FRAME


func _trigger_game_over(pressed_both: bool) -> void:
	game_over = true
	is_running = false

	if pressed_both:
		_set_frame(left, HALF_FRAME)
		_set_frame(right, HALF_FRAME)
	else:
		if _is_leaking(left) and left.frame != OPEN_FRAME:
			_set_frame(left, HALF_FRAME)
		if _is_leaking(right) and right.frame != OPEN_FRAME:
			_set_frame(right, HALF_FRAME)

	_update_lighting()
	both_doors_open.emit()


func _update_lighting() -> void:
	if lighting_root != null:
		lighting_root.set_middle_from_doors(left.frame, right.frame)

func can_pass() -> bool:
	return left.frame == OPEN_FRAME

func can_pass_left() -> bool:
	return left.frame == OPEN_FRAME

func can_pass_right() -> bool:
	return right.frame == OPEN_FRAME


func _on_sluss_hero_game_start() -> void:
	game_over = false
	is_running = true

	left_target_open = false
	right_target_open = false
	step_accum = 0.0

	_set_frame(left, CLOSED_FRAME)
	_set_frame(right, CLOSED_FRAME)

	_update_lighting()


func _on_sluss_hero_game_over() -> void:
	is_running = false
