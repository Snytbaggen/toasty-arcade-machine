extends Node2D

signal game_over
signal game_start

@export var pipe_scene: PackedScene
@onready var autoscroll = $Floor/Parallax2D.autoscroll

var state = "idle"

var score = 0

var allow_start = true

func _ready():
	Global.user_login.connect(_on_tag_read)

func _on_cooldown_finished():
	allow_start = true;

func _exit_tree():
	RpiGpio.StopNfcRead()
	Global.logout()

func _on_tag_read(user_id):
	if state == "game_over":
		UserDatabase.SaveFlappyBirdScoreForUser(user_id, score)
		_display_high_score()

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
	
	$Pipes.add_child(pipe)

func pipe_hit():
	stop_game()

func increase_score():
	score += 1
	$Overlay/GameRunning/Score.text = str(score)

func _on_timer_timeout():
	spawn_pipe()

func change_state(new_state):
	$Overlay/GameInit.visible = new_state == "init"
	$Overlay/GameRunning.visible = new_state == "running"
	$Overlay/GameOver.visible = new_state == "game_over"
	state = new_state

func start_game():
	if state == "running":
		return
	RpiGpio.StopNfcRead()
	change_state("running")
	$Timer.start()
	$Floor/Parallax2D.autoscroll = autoscroll
	game_start.emit()
	spawn_pipe()
	score = 0
	$Overlay/GameRunning/Score.text = str(score)

func stop_game(was_floor = false):
	if state != "running":
		return
	$CooldownTimer.start()
	allow_start = false
	game_over.emit()
	change_state("game_over")
	_display_high_score()
	$Overlay/GameOver/LabelFinalScore.text = str(score)
	$Timer.stop()
	$Floor/Parallax2D.autoscroll = Vector2.ZERO
	$DeathSound.play()
	RpiGpio.StartNfcRead()
	if not was_floor:
		$FallSound.play()

func _display_high_score():
	var high_score = UserDatabase.GetFlappyBirdHighScores()
	var score_length = len(high_score)
	$Overlay/GameOver/TextureHighScore/LabelHSFirst.text = high_score[0] if score_length > 0 else ""
	$Overlay/GameOver/TextureHighScore/LabelHSSecond.text = high_score[1] if score_length > 1 else ""
	$Overlay/GameOver/TextureHighScore/LabelHSThird.text = high_score[2] if score_length > 2 else ""

func _process(_delta):
	if state != "running" and Input.is_action_just_pressed("btn_center") and allow_start:
		start_game()

func _on_bounds_hit(_body, was_floor):
	stop_game(was_floor)
