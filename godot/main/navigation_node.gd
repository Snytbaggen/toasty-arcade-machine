class_name NavigationNode
extends Node2D

var start_position: Vector2 = Vector2.ZERO

signal navigate_to(node: NavigationNode, entering_from: String)
signal navigate_back(to_start: bool)

func _on_navigation(node: NavigationNode, entering_from: String):
	navigate_to.emit(node, entering_from)

func _on_back(to_start: bool = false):
	navigate_back.emit(to_start)

func set_start_position(new_position: Vector2):
	start_position = new_position
	position = new_position
