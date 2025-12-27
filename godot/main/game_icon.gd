extends AnimatedSprite2D

@export var title: String
@export var scene: PackedScene
@export var animation_duration: float = 0.2

@onready var default_scale = self.scale

func on_focus_change(focused: bool, instant: bool = false):
	var new_scale = default_scale if focused else default_scale / 2
	if instant:
		scale = new_scale
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", new_scale, animation_duration)
	
