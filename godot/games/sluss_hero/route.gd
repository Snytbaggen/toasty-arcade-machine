extends Node2D
class_name Route

@export var door_left_index := 15
@export var door_right_index := 20 
@export var z_map: Dictionary = {
	0: 0,
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
	9: 0,
	10: 0,
	11: 0,
	12: 12,
	13: 12,
	14: 12,
	15: 12,
	16: 12,
	17: 12,
	18: 12,
	19: 12,
	20: 12,
	21: 12,
	22: 12,
	23: 12,
	24: 12
} 

var _occupants: Dictionary = {}

# Tvåfilig trafik - olika z-värden beroende på startposition
func z_for_index_and_start_position(i: int, start_position: String) -> int:
	var base_z := int(z_map.get(i, 0))
	# "stage" (från scenen) är alltid ett steg närmare kameran
	if start_position == "stage":
		return base_z + 1
	else:  # "downstairs"
		return base_z

# Fallback för bakåtkompatibilitet
func z_for_index(i: int) -> int:
	return z_for_index_and_start_position(i, "downstairs")


func get_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for child in get_children():
		if child is Marker2D:
			points.append((child as Marker2D).global_position)
	return points

func is_door_index(i: int) -> bool:
	return i == door_left_index or i == door_right_index


func door_type_for_index(i: int) -> String:
	if i == door_left_index:
		return "left"
	if i == door_right_index:
		return "right"
	return ""


# Tvåfilig occupancy - använder "index_startposition" som nyckel
func _make_key(index: int, start_position: String) -> String:
	return str(index) + "_" + start_position


func occupy(index: int, who: Node, start_position: String = "downstairs") -> void:
	var key := _make_key(index, start_position)
	_occupants[key] = who.get_instance_id()


func release(index: int, who: Node, start_position: String = "downstairs") -> void:
	var id := who.get_instance_id()
	var key := _make_key(index, start_position)
	if _occupants.get(key, -1) == id:
		_occupants.erase(key)


func try_reserve(index: int, who: Node, start_position: String = "downstairs") -> bool:
	var id := who.get_instance_id()
	var key := _make_key(index, start_position)
	var existing: int = _occupants.get(key, -1)

	if existing == -1 or existing == id:
		_occupants[key] = id
		return true
	return false


func clear_occupants() -> void:
	_occupants.clear()


func _on_sluss_hero_game_start() -> void:
	clear_occupants()
