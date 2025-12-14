extends Node2D

signal pipe_hit
signal increase_score

@export var velocity: Vector2

func _process(delta):
	position += delta * velocity

func _on_pipe_entered(body):
	if body is CharacterBody2D:
		pipe_hit.emit()

func _on_score_entered(body):
	$AudioStreamPlayer.play()
	increase_score.emit()

func _on_screen_exited():
	queue_free()

func on_game_over():
	velocity = Vector2.ZERO

func on_game_start():
	queue_free()
