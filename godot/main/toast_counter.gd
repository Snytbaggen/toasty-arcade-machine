extends Node2D

@onready var user_id = Global.current_user
@onready var username = UserDatabase.GetUsernameById(user_id)
var toast_count = 0

func _ready():
	Global.user_logout.connect(_on_logged_out)
	# Sanity check, should not happen
	if user_id == -1:
		Global.logout()
	
	toast_count = UserDatabase.GetToastCountForUser(user_id)
	
	$LblUsername.text = username
	$ToastCount/LblToastCount.text = str(toast_count)

func _process(delta):
	if Input.is_action_just_pressed("btn_center"):
		print("Detecting button press")
		_on_toast_purchase()

func _on_logout_button_pressed():
	Global.logout()

func _on_toast_purchase():
	# Update database and display updated score
	toast_count = UserDatabase.SaveToast(user_id)
	$ToastCount/LblToastCount.text = str(toast_count)
	
	# Play audio
	$AudioToastBuy.play()
	
	#Animate toast score
	$ToastCount.scale *= 1.5
	var out_tween = get_tree().create_tween()
	out_tween.tween_property($ToastCount, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE)

func _on_logged_out():
	get_parent()._on_back(true)
