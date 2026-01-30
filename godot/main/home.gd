extends Node2D

func _ready():
	Global.user_login.connect(_on_user_login)
	Global.unused_tag_read.connect(_on_unused_tag_read)

func _enter_tree():
	RpiGpio.StartNfcRead()
	_display_highscore()
	$LblToasts.text = str(UserDatabase.GetToastCount())

func _exit_tree():
	RpiGpio.StopNfcRead()

func _display_highscore():
	var scores = UserDatabase.GetToastHighScore()
	$UI/BtnStatistics/FirstPlace.text = scores[0] if scores.size() >= 1 else ""
	$UI/BtnStatistics/SecondPlace.text = scores[1] if scores.size() >= 2 else ""
	$UI/BtnStatistics/ThirdPlace.text = scores[2] if scores.size() >= 3 else ""

func _on_user_login(_user_id: int):
	var node = load("res://main/toast_counter.tscn").instantiate()
	get_parent()._on_navigation(node, "right")

func _on_unused_tag_read(_tag_id: String):
	var node = load("res://main/create_profile.tscn").instantiate()
	get_parent()._on_navigation(node, "right")

func _on_show_games_list():
	var node = load("res://main/select_game.tscn").instantiate()
	get_parent()._on_navigation(node, "right")

func _on_show_settings():
	var node = load("res://main/settings.tscn").instantiate()
	get_parent()._on_navigation(node, "bottom")
