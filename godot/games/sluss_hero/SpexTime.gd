extends Node

signal time_changed(h: int, m: int)
signal show_time_changed(show_time: int)
signal clock_time_changed(clock_time: String)
signal delay_changed(delay: int)
signal stress_changed(stress: float)
signal step_tick

const game_speed := 0.9
const START_HOUR := 15
const START_MINUTE := 40
const START_IN_MINUTES := START_HOUR * 60 + START_MINUTE

const minutes_per_stress_level := 5
const max_stress_level := 5.0

@export var step_interval := 0.05
var _step_accum := 0.0

@export var stress := 0.0
@export var running_time := 0.0
@export var delay := 0
var _last_show_time := 0.0
var _last_clock_time := ""

var is_running := false


func start() -> void:
	reset()
	is_running = true


func stop()-> void:
	is_running = false


func reset() -> void:
	is_running = false
	running_time = 0.0
	delay = 0
	_emit_time(true)


func _process(delta: float) -> void:
	if not is_running:
		return

	running_time += delta / game_speed
	_emit_time()

	# === STEP TICK ===
	_step_accum += delta
	while _step_accum >= step_interval:
		_step_accum -= step_interval
		step_tick.emit()


func _emit_time(force: bool = false) -> void:
	var show_time := current_show_time()

	if force or show_time != _last_show_time:
		_last_show_time = show_time
		show_time_changed.emit(show_time)

	var clock_time := current_clock_time()
	if force or clock_time != _last_clock_time:
		_last_clock_time = clock_time
		clock_time_changed.emit(clock_time)


func current_show_time() -> int:
	return int(running_time + delay)

func current_clock_time() -> String:
	return running_time_to_clock_time(current_show_time())

func running_time_to_clock_time(running_time: int) -> String:
	var time := show_minutes_to_time(running_time)
	return time_to_string(time.x, time.y)
	

func time_to_string(hours: int, minutes: int) -> String:
	return "%02d:%02d" % [hours, minutes]

func time_to_show_minutes(hour: int, minute: int) -> int:
	var time_in_minutes := hour * 60 + minute
	return time_in_minutes - START_IN_MINUTES


func show_minutes_to_time(show_minutes: int) -> Vector2i:
	var total_minutes := show_minutes + START_IN_MINUTES
	total_minutes %= 1440
	return Vector2i(total_minutes / 60, total_minutes % 60)


func time_string_to_time(time_string: String) -> Vector2i:
	var parts := time_string.strip_edges().split(":")
	if parts.size() != 2:
		push_error("Bad time string: %s" % time_string)
		return Vector2i(0, 0)

	var hours := int(parts[0])
	var minutes := int(parts[1])

	return Vector2i(hours, minutes)


func time_string_to_show_minute(time_string: String) -> int:
	var time := time_string_to_time(time_string)
	return time_to_show_minutes(time.x, time.y)


func _on_sluss_hero_game_start() -> void:
	start()


func _on_sluss_hero_game_over() -> void:
	stop()
