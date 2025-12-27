extends Node2D

signal game_over
signal game_start

@export var pipe_scene: PackedScene
@onready var autoscroll = $Floor/Parallax2D.autoscroll

var is_running = false

var score = 0

func spawn_pipe():
	var pipe = pipe_scene.instantiate()
	pipe.position = $Marker2D.position
	pipe.position.y += randf_range(-10, 10) * 10
	pipe.velocity = autoscroll
	pipe.name = "Pipe"
	
	pipe.connect('pipe_hit', pipe_hit)
	pipe.connect('increase_score', increase_score)
	connect('game_over', pipe.on_game_over)
	connect('game_start', pipe.on_game_start)
	
	add_child(pipe)

func pipe_hit():
	stop_game()

func increase_score():
	score += 1
	$Score.text = str(score)

func _on_timer_timeout():
	spawn_pipe()

func start_game():
	if is_running:
		return
	is_running = true
	$Timer.start()
	$Floor/Parallax2D.autoscroll = autoscroll
	game_start.emit()
	spawn_pipe()
	score = 0
	$Score.text = str(score)

func stop_game(was_floor = false):
	if not is_running:
		return
	game_over.emit()
	is_running = false
	$Timer.stop()
	$Floor/Parallax2D.autoscroll = Vector2.ZERO
	$DeathSound.play()
	if not was_floor:
		$FallSound.play()

func _process(_delta):
	if not is_running and Input.is_action_just_pressed("btn_center"):
		start_game()

func _on_bounds_hit(_body, was_floor):
	stop_game(was_floor)
