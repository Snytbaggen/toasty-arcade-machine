extends Node2D

signal game_over
signal game_start

var state = "idle"

@export var spexare_scene: PackedScene
@onready var route = $Route.get_points()


func _process(_delta: float) -> void:
	if state != "running" and Input.is_action_just_pressed("btn_center"):
		start_game()


func start_game():
	change_state("running")
	game_start.emit()


func end_game():
	change_state("game_over")
	game_over.emit()

func change_state(new_state):
	$Overlay/GameOver.visible = new_state == "game_over"
	state = new_state


func _on_doors_both_doors_open() -> void:
	end_game()


func _on_spex_time_clock_time_changed(clock_time: String) -> void:
	$InfoPanel/Time.text = clock_time


func _on_inspicient_end_of_show() -> void:
	end_game()
