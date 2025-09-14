extends CharacterBody2D

@export var walk_acceleration = 5000
@export var jump_speed = 600
@export var max_walk_speed = 300
@export var stop_force = 5000

@onready var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity"))
@onready var screen_size := get_viewport_rect().size

var can_double_jump = true
	
func _physics_process(delta):
	if is_on_floor():
		can_double_jump = true
	
	var walk_speed = Input.get_axis("btn_left", "btn_right") * walk_acceleration * delta
	if abs(walk_speed) > 0:
		velocity.x += walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, stop_force * delta )
	velocity.x = clamp(velocity.x, -max_walk_speed, max_walk_speed)
	
	velocity.y += delta * gravity
	
	if (is_on_floor() or can_double_jump) and Input.is_action_just_pressed("btn_center"):
		velocity.y = - jump_speed
		# A bit clunky but this sets can_double_jump to false on the second jump
		can_double_jump = is_on_floor()
	
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)
