extends Node2D

@export var tween_time := 0.08
@export var dark_energy := 0.75
@export var stage_light_on := false

@onready var lock_light: PointLight2D = $LockLight
@onready var stage_light: PointLight2D = $StageLight

const HALF_FRAME := 1

var _tween_lock: Tween
var _tween_stage: Tween
var is_ready := false

var _last_left_frame := 0
var _last_right_frame := 0


func _ready() -> void:
	# Skapa exakta texturer för varje zon (inga scale-artefakter)
	# Lock-zon: x 147–333 (186px), y 199–479 (280px) - utökad nedåt
	lock_light.texture = _create_rect_texture(186, 280)
	# Stage-zon: x 333–480 (147px), y 200–480 (280px) - utökad nedåt
	stage_light.texture = _create_rect_texture(147, 280)

	lock_light.energy = dark_energy
	stage_light.energy = dark_energy
	is_ready = true
	set_middle_from_doors(_last_left_frame, _last_right_frame)


func _create_rect_texture(w: int, h: int) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGB8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)


func set_stage_light(state: bool) -> void:
	stage_light_on = state
	set_middle_from_doors(_last_left_frame, _last_right_frame)


func set_middle_from_doors(left_frame: int, right_frame: int) -> void:
	if not is_ready:
		return

	_last_left_frame = left_frame
	_last_right_frame = right_frame

	var left_openish := left_frame >= HALF_FRAME
	var right_openish := right_frame >= HALF_FRAME

	var stage_lit := stage_light_on or (left_openish and right_openish)
	var middle_should_be_lit := left_openish or (right_openish and stage_lit)

	# Inverterad logik: SUB-ljus, energy=0 = upplyst, energy=dark_energy = mörkt
	_tween_energy(lock_light, 0.0 if middle_should_be_lit else dark_energy, "_tween_lock")
	_tween_energy(stage_light, 0.0 if stage_lit else dark_energy, "_tween_stage")


func _tween_energy(light: PointLight2D, target: float, tween_name: String) -> void:
	var tween: Tween = get(tween_name)
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property(light, "energy", target, tween_time)
	set(tween_name, tween)
