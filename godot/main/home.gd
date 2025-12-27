extends Node2D

func _show_create_profile():
	var node = load("res://main/create_profile.tscn").instantiate()
	get_parent()._on_navigation(node, "left")

func _on_show_games_list():
	var node = load("res://main/select_game.tscn").instantiate()
	get_parent()._on_navigation(node, "right")
