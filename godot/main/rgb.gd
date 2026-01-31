extends Node2D

func _ready():
	$Parallax2D.visible = false

func show_rgb():
	$Parallax2D.visible = true
	$TimerRgb.start()

func _on_timer_rgb_timeout():
	$Parallax2D.visible = false
