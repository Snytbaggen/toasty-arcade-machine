extends Node


@export var schedule_path: String = "res://games/sluss_hero/res/schedule.json"
@onready var spex_time: Node = $"../SpexTime"
@onready var lightning_root: Node2D = $"../Lighting"
@export var spexare_scene: PackedScene
@onready var route: Route = $"../Route"
@onready var doors: Doors = $"../Doors"
@onready var spexare_root: Node2D = $"../Spexare"
@onready var ring1: TextureRect = $"../Ring1"
@onready var ring2: TextureRect = $"../Ring2"
@onready var ring3: TextureRect = $"../Ring3"
@onready var info_label: Label = $"../InfoPanel/Label"

signal end_of_show

const RING_DELAY := 0.1  # Tid mellan varje ring
const RING_DURATION := 0.5  # Hur länge rings visas

var cues: Array[Dictionary] = []
var _rings: Array[TextureRect] = []

func start() -> void:
	cues = load_schedule(schedule_path)
	_rings = [ring1, ring2, ring3]
	for ring in _rings:
		ring.visible = false
	set_lights(true)
	set_label("")

func clear_spexare() -> void:
	for child in spexare_root.get_children():
		child.queue_free()

func load_schedule(path: String) -> Array[Dictionary]:
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	
	var schedule: Array[Dictionary] = []
	for item in parsed:
		schedule.append(item as Dictionary)

	return schedule


func _on_spex_time_show_time_changed(show_time: int) -> void:
	if cues.size() == 0:
		return
		 
	var next_cue := cues[0]
	var cue_time := String(next_cue["time"])
	var event_time := int(spex_time.time_string_to_show_minute(cue_time))
	if event_time <= show_time:
		cues.pop_front()
		run_event(next_cue) 
	
		
func run_event(event: Dictionary) -> void:
	var event_type := String(event["type"])
	match event_type:
		"ring":
			ring(int(event["times"]))
		"go":
			create_spexare(String(event["from"]), String(event["to"]), int(event["number"]))
		"lights":
			set_lights(bool(event["state"]))
		"label":
			set_label(String(event["text"]))
		"show_over":
			end_show()


func ring(times: int) -> void:
	var rings_to_show := mini(times, _rings.size())

	# Visa varje ring med progressiv delay
	for i in rings_to_show:
		var show_delay := i * RING_DELAY
		get_tree().create_timer(show_delay).timeout.connect(func():
			_rings[i].visible = true
		, CONNECT_ONE_SHOT)

	# Göm alla rings efter att sista visats + duration
	var hide_delay := (rings_to_show - 1) * RING_DELAY + RING_DURATION
	get_tree().create_timer(hide_delay).timeout.connect(func():
		for i in rings_to_show:
			_rings[i].visible = false
	, CONNECT_ONE_SHOT)

func set_lights(state: bool) -> void:
	lightning_root.set_stage_light(state)

func set_label(text: String) -> void:
	info_label.text = text
	
func create_spexare(from: String, to: String, number: int) -> void:
	for i in number:
		var s: Spexare = spexare_scene.instantiate()
		spexare_root.add_child(s)

		s.init_with_route(
			route.get_points(),
			doors,
			route,
			spex_time,
			from,
		)

func end_show() -> void:
	end_of_show.emit()

func _on_sluss_hero_game_start() -> void:
	clear_spexare()
	start()
