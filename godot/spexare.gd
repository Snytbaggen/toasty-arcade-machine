extends Node2D
class_name Spexare

@export var step_time := 0.12
@export var bounce_height := 40.0

var _route: Array[Vector2] = []
var _i := 0
var _moving := false
var _start_position := "downstairs"  # "downstairs" eller "stage"

var doors: Doors
var route_node: Route
var spex_time: Node

func _ready():
	pass


func init_with_route(points: Array[Vector2], doors_ref: Doors, route_ref: Route, spex_time_ref: Node, start_position: String = "downstairs") -> void:
	spex_time = spex_time_ref
	doors = doors_ref
	route_node = route_ref
	_start_position = start_position

	# Om från stage, reversera rutten
	if start_position == "stage":
		_route = points.duplicate()
		_route.reverse()
	else:
		_route = points

	_i = 0
	global_position = _route[0]
	if route_node:
		route_node.occupy(_i, self, _start_position)
		# Sätt rätt z-index baserat på startposition
		z_index = route_node.z_for_index_and_start_position(_original_index(_i), _start_position)

	# Koppla step_tick-signalen efter att spex_time är satt
	if spex_time:
		spex_time.step_tick.connect(step)



func set_route(points: Array[Vector2]) -> void:
	_route = points
	_i = 0
	if _route.size() > 0:
		global_position = _route[0]

func _original_index(i: int) -> int:
	if _start_position == "stage":
		return (_route.size() - 1) - i
	return i

func step() -> void:
	if _moving:
		return
	if _route.is_empty():
		return
	if _i >= _route.size() - 1:
		if route_node:
			route_node.release(_i, self, _start_position)
			queue_free()
			return


	var next_index := _i + 1

	# 🚪 Dörrcheck
	# 1) Om nästa ruta är en dörr: kräver plats direkt efter dörren
	var original_next := _original_index(next_index)
	if route_node and route_node.is_door_index(original_next):
		# vilken dörr?
		var door_type := route_node.door_type_for_index(original_next)

		# dörren måste vara öppen
		if door_type == "left":
			if doors and not doors.can_pass_left():
				return
		elif door_type == "right":
			if doors and not doors.can_pass_right():
				return

		# måste finnas en ruta efter dörren
		var after_door_index := next_index + 1
		if after_door_index >= _route.size():
			return

		# Försök reservera rutan efter dörren (så ingen fastnar i dörren)
		var ok_after := route_node.try_reserve(after_door_index, self, _start_position)
		if not ok_after:
			return

		# Om vi fick plats efter dörren: reservera även själva dörr-rutan
		var ok_door := route_node.try_reserve(next_index, self, _start_position)
		if not ok_door:
			# rulla tillbaka reservationen efter dörren om dörr-rutan blev tagen
			route_node.release(after_door_index, self, _start_position)
			return

	# 2) Vanlig ruta (inte dörr): vanlig kö-reservering
	else:
		if route_node:
			var ok_next := route_node.try_reserve(next_index, self, _start_position)
			if not ok_next:
				return
	# === RÖRELSE ===
	_moving = true
	var start := global_position
	_i += 1
	var end := _route[_i]

	var dx := end.x - start.x
	if has_node("Sprite2D") and dx != 0:
		$Sprite2D.flip_h = (dx < 0)

	var t := create_tween()
	t.tween_property(self, "global_position:x", end.x, step_time)

	t.parallel().tween_property(self, "global_position:y", start.y - bounce_height, step_time * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "global_position:y", end.y, step_time * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	var prev_index := _i - 1

	t.finished.connect(func():
		z_index = route_node.z_for_index_and_start_position(_original_index(_i), _start_position)
		global_position = end

		# släpp rutan vi kom ifrån (vi reserverade nästa innan vi gick)
		if route_node:
			route_node.release(prev_index, self, _start_position)

		_moving = false
)

func _exit_tree() -> void:
	if route_node:
		route_node.release(_i, self, _start_position)
