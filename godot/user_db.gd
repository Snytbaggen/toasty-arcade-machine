extends Node

var _users_path = "/home/lisse/users.json"
var _toasts_path = "/home/lisse/toasts.json"
var _coffee_path = "/home/lisse/coffee.json"
var _flappy_bird_score_path = "/home/lisse/flappy_bird_score.json"

@onready var users: Array = _load_json(_users_path, [])
@onready var toasts: Array = _load_json(_toasts_path, [])
@onready var coffee: Array = _load_json(_coffee_path, [])
@onready var flappy_bird_score: Array = _load_json(_flappy_bird_score_path, [])

func _ready():
	if OS.is_debug_build():
		_users_path = "./users.json"
		_toasts_path = "./toasts.json"
		_coffee_path = "./coffee.json"
		_flappy_bird_score_path = "./flappy_bird_score.json"
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 15 * 60 # 15 minutes
	timer.one_shot = false
	timer.start()
	timer.timeout.connect(save_all)

func _exit_tree():
	save_all()

func save_all():
	_save_json(_users_path, users)
	_save_json(_toasts_path, toasts)
	_save_json(_coffee_path, coffee)
	_save_json(_flappy_bird_score_path, flappy_bird_score)

func _load_json(path, default):
	if not FileAccess.file_exists(path):
		return default
	
	var raw_json = FileAccess.get_file_as_string(path)
	if not raw_json.is_empty():
		var json = JSON.parse_string(raw_json)
		return default if json == null else json

func _save_json(path, array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var raw_json = JSON.stringify(array)
	file.store_string(raw_json)

func create_user(
	username: String,
	tag_id: String,
	secondary_tag_id: String = "",
	displayScore: bool = true,
	):
		users.append(
			{
				id = UserDatabase.CreateGuid(),
				username = username,
				tagId = tag_id,
				secondaryTagId = secondary_tag_id,
				creation = UserDatabase.GetTimestamp(),
				lastLogin = UserDatabase.GetTimestamp(),
				displayScore = displayScore,
				toastCount = 0,
				coffeeCount = 0
			}
		)

func get_toast_high_score() -> Array:
	var filtered_users = users.filter(func(a): return a["toastCount"] > 0)
	
	filtered_users.sort_custom(func(a, b): return a["toastCount"] > b["toastCount"])
	var ret = []
	for i in range(0, min(3, filtered_users.size())):
		var u = filtered_users.get(i)
		ret.append(u["username"] + " - " + str(u["toastCount"] as int))
	return ret

func get_user_by_tag(tag_id) -> Dictionary:
	var user_index = users.find_custom(
		func(u): return u["tagId"] == tag_id or u["secondaryTagId"] == tag_id
	)
	if user_index == -1:
		return {}
	else:
		var user = users.get(user_index)
		return user

func get_user_by_id(id) -> Dictionary:
	var user_index = users.find_custom(
		func(u): return u["id"] == id
	)
	if user_index == -1:
		return {}
	else:
		var user = users.get(user_index)
		return user

func get_user_id_by_tag(tag_id) -> int:
	var user = get_user_by_tag(tag_id)
	return user["id"] if not user.is_empty() else -1

func get_username_by_id(id) -> String:
	var user = get_user_by_id(id)
	return user["username"] if not user.is_empty() else ""

func save_toast(user_id):
	var user = get_user_by_id(user_id)
	if not user.is_empty():
		user["toastCount"] += 1
		toasts.append(
			{
				userId = user_id,
				times = UserDatabase.GetTimestamp()
			}
		)

func save_coffee(user_id):
	var user = get_user_by_id(user_id)
	if not user.is_empty():
		if not user.has("coffeeCount"):
			user["coffeeCount"] = 0
		user["coffeeCount"] += 1
		coffee.append(
			{
				userId = user_id,
				times = UserDatabase.GetTimestamp()
			}
		)

func get_toast_count() -> int:
	return toasts.size()

func get_toast_count_for_user(id) -> int:
	var user = get_user_by_id(id)
	return user["toastCount"] if not user.is_empty() else -1

func get_coffee_count_for_user(id) -> int:
	var user = get_user_by_id(id)
	if not user.is_empty() and user.has("coffeeCount"):
		return user["coffeeCount"]
	else:
		return -1
