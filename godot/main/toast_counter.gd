extends Node2D

@onready var user_id = Global.current_user
@onready var username = UserDatabase.GetUsernameById(user_id)
var count = 0
var mode = "toast"

func _ready():
	Global.user_logout.connect(_on_logged_out)
	# Sanity check, should not happen
	if user_id == -1:
		Global.logout()
	
	count = UserDatabase.GetToastCountForUser(user_id)
	if count == -1:
		count = 0
	
	$LblUsername.text = username
	$ToastCount/LblToastCount.text = str(count)

func _set_mode(new_mode: String):
	if new_mode == "toast":
		mode = new_mode
		count = UserDatabase.GetToastCountForUser(user_id)
		if count == -1:
			count = 0
		$ToastCount/LblToastCount.text = str(count)
		$LblTitle.text = "Personlig\nToasträknare"
		$LblToastsPurchasedText.text = "Köpta toast"
		$LblInstructions.text = "Tryck på knappen\nför att registrera toast!"
		$ButtonMode.text = "Kaffe"
	elif new_mode == "coffee":
		mode = new_mode
		count = UserDatabase.GetCoffeeCountForUser(user_id)
		if count == -1:
			count = 0
		$ToastCount/LblToastCount.text = str(count)
		$LblTitle.text = "Personlig\nKafferäknare"
		$LblToastsPurchasedText.text = "Köpta kaffe"
		$LblInstructions.text = "Tryck på knappen\nför att registrera kaffe!"
		$ButtonMode.text = "Toast"

func _process(delta):
	if Input.is_action_just_pressed("btn_center"):
		_on_purchase()

func _on_logout_button_pressed():
	Global.logout()

func _on_purchase():
	# Update database and display updated score
	if mode == "toast":
		UserDatabase.SaveToast(user_id)
	elif mode == "coffee":
		UserDatabase.SaveCoffee(user_id)
	count += 1
	$ToastCount/LblToastCount.text = str(count)
	
	# Play audio
	$AudioToastBuy.play()
	
	#Animate toast score
	$ToastCount.scale *= 1.5
	var out_tween = get_tree().create_tween()
	out_tween.tween_property($ToastCount, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE)

func _on_logged_out():
	get_parent()._on_back(true)

func _on_mode_button_down():
	if mode == "toast":
		_set_mode("coffee")
	elif mode == "coffee":
		_set_mode("toast")
