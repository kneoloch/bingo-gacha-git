extends Node

@warning_ignore("unused_signal")
signal updatePoints
@warning_ignore("unused_signal")
signal loginUser
@warning_ignore("unused_signal")
signal eunuchsRetrieved
@warning_ignore("unused_signal")
signal addItem(item_data: Dictionary)
@warning_ignore("unused_signal")
signal removeItem(item_data: Dictionary)
@warning_ignore("unused_signal")
signal getGachaData(gacha_data: Dictionary)
@warning_ignore("unused_signal")
signal getEunuchData(eunuch_data: Dictionary)
@warning_ignore("unused_signal")
signal getGifted(eunuch_data: Dictionary)

enum User {AMYRA, JOEY, KMOR, V}
const BIRD_AVATAR = preload("uid://c5j4lno02psms")
const CAT_AVATAR = preload("uid://bc0lodymueh1t")
const LOACH_AVATAR = preload("uid://dp6okdprao8t6")
const BUNNY_AVATAR = preload("uid://daw1uj5nmrjpw")

## HTTP Database: Google Forms
const url_eunuch_data: String = "https://opensheet.elk.sh/1YgRPfQaau04TJlxzdhOXMib0cW0Y04QwhWaudrK9hW8/EunuchsData"
const url_eunuch_submit: String = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSfZDQuTsP0M9JzrQzb7iC5BT-AIXUx-mLYlb0-uQVeE3MHBQQ/formResponse"
const url_gacha_data: String = "https://opensheet.elk.sh/1YgRPfQaau04TJlxzdhOXMib0cW0Y04QwhWaudrK9hW8/Data"
const url_gacha_submit: String = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSckJTN2uMihyvS_SfMI4c4NXz49nZ5SonfiqQXEQKBw3_6rRA/formResponse"
const headers: Array = ["Content-Type: application/x-www-form-urlencoded"]
var client: HTTPClient = HTTPClient.new()
## Eunuch Data Dictionary
var USER: User
var USERNAME: String
var USER_TEXTURE: CompressedTexture2D = null
var USER_COLOR: Color = Color.WHITE
var POINTS: float = 10
var ROLLOVER_POINTS: float = 0
var TALLY: int = 0
var INVENTORY: Array[Dictionary] = []
var starter_inv: Array[Dictionary] = []

## Retrieve Gacha Pull Data from Google Forms
# ALERT: Use 'variableName = variableName.replace(" ","+")' with String user inputs for Google Forms' readability!
func get_gacha_data() -> void:
	_retrieve_data("gacha_data", "")

func _on_gacha_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_on_retrieval("gacha_data", body, "")

## Retrieve Eunuchs' User Data from Google Forms
func get_eunuchs_data() -> void: # login_screen, gui
	_retrieve_data("eunuchs_data", "")

## On User Data Retrieval: Load the most recent save entry
func _on_eunuchs_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_on_retrieval("eunuchs_data", body, "")

## Retrieve Gifted Eunuchs' User Data from Google Forms
func get_gifted(gifted_user: String) -> void:
	_retrieve_data("gifted_user_data", gifted_user)

func _on_gifted_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray, gifted_user: String) -> void:
	_on_retrieval("gifted_user_data", body, gifted_user)

## Send Eunuch User Data to Google Forms
func sync_eunuch_data(user: String, sprite: Texture2D, user_color: Color, points: float, rollover_points: float, tally: int, inventory: Array) -> void: # gui. card_item
	var http: HTTPRequest = HTTPRequest.new()
	var pool_headers = PackedStringArray(headers)
	var query_string: String = client.query_string_from_dict({
		"entry.803632991": user, "entry.238405189": sprite, "entry.694666525": user_color, "entry.1774473989": points, "entry.95307706": rollover_points, "entry.1057900872": tally, "entry.77959177": inventory}) # DROPS
	add_child(http)
	http.request(url_eunuch_submit, pool_headers, HTTPClient.METHOD_POST, query_string)
	http.request_completed.connect(_cull_http)

## Send Gacha Pull Data to Google Forms
func add_gacha_data(user: String, points: float, drop: Dictionary) -> void: # card_item
	var http: HTTPRequest = HTTPRequest.new()
	var pool_headers = PackedStringArray(headers)
	var query_string: String = client.query_string_from_dict({
		"entry.1921461023": user, "entry.1027356974": points, "entry.1208091828": drop})
	add_child(http)
	http.request(url_gacha_submit, pool_headers, HTTPClient.METHOD_POST, query_string)
	http.request_completed.connect(_cull_http)

func _retrieve_data(data_type: String, gifted_user: String) -> void:
	var http: HTTPRequest = HTTPRequest.new()
	var pool_headers = PackedStringArray(headers)
	add_child(http)
	match data_type:
		"gacha_data":
			http.request(url_gacha_data, pool_headers, HTTPClient.METHOD_GET)
			http.request_completed.connect(_on_gacha_request_completed)
			#print("Retrieving gacha data from online database...")
		"eunuchs_data":
			http.request(url_eunuch_data, pool_headers, HTTPClient.METHOD_GET)
			http.request_completed.connect(_on_eunuchs_request_completed)
			#print("Retrieving eunuchs data from online database...")
		"gifted_user_data":
			http.request(url_eunuch_data, pool_headers, HTTPClient.METHOD_GET)
			http.request_completed.connect(_on_gifted_request_completed.bind(gifted_user))
			#print("Retrieving gifted eunuch's data from online database...")

func _on_retrieval(data_type: String, body: PackedByteArray, gifted_user: String) -> void:
	var database: String = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	var data: String = JSON.stringify(database)
	var error = json.parse(data)
	match data_type:
		"gacha_data":
			if error == OK:
				var data_received = json.data
				if typeof(data_received) == TYPE_STRING: ##ARRAY
					var data_array: Array = str_to_var(data_received)
					for gacha_data: Dictionary in data_array:
						emit_signal("getGachaData", gacha_data)
						self.get_child(0).queue_free()
				else:
					print("Unexpected data")
			else:
				print("JSON Parse Error: %s in %s at line %d" % [json.get_error_message(), data, json.get_error_line()])
		"eunuchs_data":
			if error == OK:
				var data_received = json.data
				if typeof(data_received) == TYPE_STRING: ##ARRAY
					var data_array: Array = str_to_var(data_received)
					## Isolate current user and retrieve the most recent save data
					var eunuch_entries: Array = []
					for eunuchs: Dictionary in data_array:
						if eunuchs["User"] == USERNAME:
							eunuch_entries.append(eunuchs)
							emit_signal("getEunuchData", eunuch_entries[-1])
					eunuch_entries = []
					self.get_child(0).queue_free()
				else:
					print("Unexpected data")
			else:
				print("JSON Parse Error: %s in %s at line %d" % [json.get_error_message(), data, json.get_error_line()])
		"gifted_user_data":
			if error == OK:
				var data_received = json.data
				if typeof(data_received) == TYPE_STRING: ##ARRAY
					var data_array: Array = str_to_var(data_received)
					## Isolate current user and retrieve the most recent save data
					var eunuch_entries: Array = []
					for eunuchs: Dictionary in data_array:
						if eunuchs["User"] == gifted_user:
							eunuch_entries.append(eunuchs)
							emit_signal("getGifted", eunuch_entries[-1])
					eunuch_entries = []
					self.get_child(0).queue_free()
				else:
					print("Unexpected data")
			else:
				print("JSON Parse Error: %s in %s at line %d" % [json.get_error_message(), data, json.get_error_line()])

func _cull_http(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	self.get_child(0).queue_free()

## Adds item to user inventory
func add_item_to_inv(rarity: String, bingo_word: String, effect: String, value: float, quantity: int) -> void:
	var new_item: Dictionary = {
		"item_rarity": rarity,
		"bingo_word": bingo_word,
		"effect": effect,
		"value": value,
		"quantity": quantity
	}
	var new: bool = true
	if INVENTORY.is_empty():
		_obtained_drop(new_item)
	else:
		## Checks new item added to inventory with existing items for duplicants and stacks by quantity
		for item: int in range(INVENTORY.size()):
			if INVENTORY[item]["item_rarity"] == new_item["item_rarity"] and INVENTORY[item]["bingo_word"] == new_item["bingo_word"]:
				new = false
				print("-- existing item: %s" % new_item["bingo_word"])
				INVENTORY[item]["quantity"] += new_item["quantity"]
				print("%s's quantity increased to %d!" % [INVENTORY[item]["bingo_word"], INVENTORY[item]["quantity"]])
				_obtained_drop(new_item)
		if new:
			print("-- new item: %s" % new_item["bingo_word"])
			INVENTORY.append(new_item)
			emit_signal("addItem", new_item)
			_obtained_drop(new_item)

## Submits HTTP data to Google Forms
func _obtained_drop(item_data: Dictionary) -> void:
	add_gacha_data(USERNAME, POINTS, item_data)
	sync_eunuch_data(USERNAME, USER_TEXTURE, color(USER), POINTS, ROLLOVER_POINTS, TALLY, INVENTORY)
	print(get_inventory(), "\n")

func remove_item(item_data: Dictionary) -> void:
	INVENTORY.erase(item_data)
	emit_signal("removeItem", item_data)
	print("Removing %s item..." % item_data["item_rarity"])

func exchange_item(item_data: Dictionary) -> void:
	print("%s exchanged %s item for %.2f!" % [USERNAME, item_data["item_rarity"], item_data["value"]])
	match item_data["item_rarity"]:
		"COMMON":
			POINTS += item_data["value"]
		"UNCOMMON":
			POINTS += item_data["value"]
		"RARE":
			POINTS += item_data["value"]
		"EPIC":
			POINTS += item_data["value"]
		"LEGENDARY":
			POINTS += item_data["value"]
		"AMYRA":
			TALLY += item_data["value"]
		"JOEY":
			TALLY += item_data["value"]
		"KMOR":
			TALLY += item_data["value"]
		"V":
			TALLY += item_data["value"]
	remove_item(item_data)
	sync_eunuch_data(USERNAME, USER_TEXTURE, color(USER), POINTS, ROLLOVER_POINTS, TALLY, INVENTORY)

func gift_item(item_data: Dictionary, gifted_user: String) -> void:
	remove_item(item_data)
	get_gifted(gifted_user)
	getGifted.connect(_get_gifted.bind(item_data))
	print("%s gifted %s!" % [USERNAME, gifted_user])

func _get_gifted(eunuch_data: Dictionary, item_data: Dictionary) -> void:
	var inv_string: String = "[%s]" % eunuch_data["Inventory"]
	var new_inv = str_to_var(inv_string)
	new_inv.append(item_data)
	sync_eunuch_data(eunuch_data["User"], texture(get_user(eunuch_data["User"])), color(get_user(eunuch_data["User"])), eunuch_data["Points"].to_float(), eunuch_data["Rollover Points"].to_float(), eunuch_data["Tally"].to_int(), new_inv)

func get_user(user_name: String) -> User:
	match user_name:
		"AMYRA":
			return User.AMYRA
		"JOEY":
			return User.JOEY
		"KMOR":
			return User.KMOR
		"V":
			return User.V
	return USER

func get_inventory() -> String:
	if INVENTORY.is_empty():
		print("Inventory is empty!")
		return "Inventory is empty!"
	else:
		var inv: Array = []
		var item_data: String
		var inv_str: String 
		for items in INVENTORY:
			if items["item_rarity"] != "COMMON":
				item_data = "%s x%d" % [items["item_rarity"], items["quantity"]]
			else:
				item_data = "%s: %s x%d" % [items["item_rarity"], items["bingo_word"], items["quantity"]]
			inv.append(item_data)
			inv_str = str(inv)
		return inv_str

func change_user(u: User) -> void:
	USER = u
	USERNAME = User.keys()[USER]

func username(u: User, abv: bool) -> String:
	if !abv:
		match u:
			User.AMYRA:
				return "AMYRA"
			User.JOEY:
				return "JOEY"
			User.KMOR:
				return "KMOR"
			User.V:
				return "V"
		return ""
	else:
		match u:
			User.AMYRA:
				return "A"
			User.JOEY:
				return "J"
			User.KMOR:
				return "K"
			User.V:
				return "V"
		return ""

func color(u: User) -> Color:
	match u:
		User.AMYRA:
			return Color.BLACK
		User.JOEY:
			return Color.ORANGE
		User.KMOR:
			return Color.LAWN_GREEN
		User.V:
			return Color.HOT_PINK
	return Color.WHITE

func texture(u: User) -> CompressedTexture2D:
	match u:
		User.AMYRA:
			return CAT_AVATAR
		User.JOEY:
			return LOACH_AVATAR
		User.KMOR:
			return BIRD_AVATAR
		User.V:
			return BUNNY_AVATAR
	return null
