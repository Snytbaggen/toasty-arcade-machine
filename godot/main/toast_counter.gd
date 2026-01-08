extends Node2D

@onready var user_id = Global.current_user
@onready var username = UserDatabase.GetUsernameById(user_id)

func _ready():
	Global.user_logout.connect(_on_logged_out)
	# Sanity check, should not happen
	if user_id == -1:
		Global.logout()
	
	$LblUsername.text = username
	$ToastCount/LblToastCount.text = str(UserDatabase.GetToastCountForUser(user_id))

func _process(delta):
	if Input.is_action_just_pressed("btn_center"):
		_on_toast_purchase()

func _on_logout_button_pressed():
	Global.logout()

func _on_toast_purchase():
	# Update database and display updated score
	UserDatabase.SaveToast(user_id)
	$ToastCount/LblToastCount.text = str(UserDatabase.GetToastCountForUser(user_id))
	
	# Play audio
	$AudioToastBuy.play()
	
	#Animate toast score
	$ToastCount.scale *= 1.5
	var out_tween = get_tree().create_tween()
	out_tween.tween_property($ToastCount, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE)

func _on_logged_out():
	get_parent()._on_back(true)
