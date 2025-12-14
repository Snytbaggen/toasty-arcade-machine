extends Node2D

@export var mob_scene: PackedScene

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	
	mob.position = $MobMarker.position
	
	mob.linear_velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	
	add_child(mob)
