extends CharacterBody2D

@export var jump_speed = 600

var is_running = false
var is_idle = true
var just_started = false

@onready var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity"))
@onready var start_pos := self.position

func _ready():
	$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if is_idle:
		return
	
	velocity.y += delta * gravity

	if is_running:
		if Input.is_action_just_pressed("btn_center") or just_started:
			$FlapSound.play()
			velocity.y = - jump_speed
			just_started = false
		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("fall")
	
	if not is_on_floor():
		$AnimatedSprite2D.rotation_degrees = min(velocity.y/10, 90)

	move_and_slide()


func _on_flappy_bird_game_start():
	is_idle = false
	is_running = true
	just_started = true
	position = start_pos

func _on_flappy_bird_game_over():
	is_running = false
