extends Node

signal toggleDraws(lock: bool)
signal activateCard
@warning_ignore("unused_signal")
signal toggleInv
@warning_ignore("unused_signal")
signal checkUnclaimedCards
@warning_ignore("unused_signal")
signal cardActivated(item_rarity: String, value: float) # card_item
@warning_ignore("unused_signal")
signal discard(item_rarity: String, value: float)
@warning_ignore("unused_signal")
signal drawn
@warning_ignore("unused_signal")
signal tooltip(in_hand: bool, card_data: Dictionary)
@warning_ignore("unused_signal")
signal hideTooltip

@warning_ignore("unused_signal")
signal selectBanner(banner: BannerInfo.Banner, texture: CompressedTexture2D)
@warning_ignore("unused_signal")
signal revealDrop(text: String)
@warning_ignore("unused_signal")
signal drawCardPool(item_data: Dictionary)
@warning_ignore("unused_signal")
signal bingoReroll # card_item

## Retrieve Bingo List
const url_bingo_word_bank: String = "https://opensheet.elk.sh/1YgRPfQaau04TJlxzdhOXMib0cW0Y04QwhWaudrK9hW8/BingoWordBank"
const headers: Array = ["Content-Type: application/x-www-form-urlencoded"]

var bingo_word_bank: Array[Dictionary] = []
var bingo_list: Array[String] = []
var priority_critical: Array[String] = []
var priority_normal: Array[String] = []
var priority_honorary: Array[String] = []
var DROP_RARITY: BannerInfo.BannerDrop
var CURR_BANNER: BannerInfo.Banner = BannerInfo.Banner.STANDARD
var RNG: RandomNumberGenerator = RandomNumberGenerator.new()
var new_drop: String = str(BannerInfo.BannerDrop.keys()[DROP_RARITY])
var num_of_draws: int
var player_deck: Array = []
var unclaimed_hand: Array = []
var selected_card: Array[CardItem] = []
var bingo_locked: bool = false

func _ready() -> void:
	Gacha.activateCard.connect(_activate_selected_card)

## Retrieve Bingo Word List from Google Spreadsheets
func get_bingo_bank() -> void:
	var http: HTTPRequest = HTTPRequest.new()
	var pool_headers = PackedStringArray(headers)
	add_child(http)
	http.request(url_bingo_word_bank, pool_headers, HTTPClient.METHOD_GET)
	http.request_completed.connect(_on_request_completed)

func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var database: String = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	var data: String = JSON.stringify(database)
	var error = json.parse(data)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_STRING: ##ARRAY
			var data_array: Array = str_to_var(data_received)
			for word: Dictionary in data_array:
				bingo_word_bank.append(word)
				bingo_list.append(word["BingoWord"])
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: %s in %s at line %d" % [json.get_error_message(), data, json.get_error_line()])
	for i: int in bingo_word_bank.size():
		if bingo_word_bank[i]["Priority"] == "1":
			priority_critical.append(bingo_word_bank[i]["BingoWord"])
	for i: int in bingo_word_bank.size():
		if bingo_word_bank[i]["Priority"] == "2":
			priority_normal.append(bingo_word_bank[i]["BingoWord"])
	for i: int in bingo_word_bank.size():
		if bingo_word_bank[i]["Priority"] == "3":
			priority_honorary.append(bingo_word_bank[i]["BingoWord"])
	emit_signal("toggleDraws", false)

func draw_card(banner: BannerInfo.Banner, num: int) -> void:
	num_of_draws = num
	if num == 1:
		match banner:
			BannerInfo.Banner.STANDARD:
				_calculate_drop_chances(BannerInfo.standard_one)
			BannerInfo.Banner.AMYRA:
				_calculate_drop_chances(BannerInfo.amyra_one)
			BannerInfo.Banner.JOEY:
				_calculate_drop_chances(BannerInfo.joey_one)
			BannerInfo.Banner.KMOR:
				_calculate_drop_chances(BannerInfo.kmor_one)
			BannerInfo.Banner.V:
				_calculate_drop_chances(BannerInfo.v_one)
			BannerInfo.Banner.WILD:
				pass
	if num == 10:
		match banner:
			BannerInfo.Banner.STANDARD:
				_calculate_drop_chances(BannerInfo.standard_ten)
			BannerInfo.Banner.AMYRA:
				_calculate_drop_chances(BannerInfo.amyra_ten)
			BannerInfo.Banner.JOEY:
				_calculate_drop_chances(BannerInfo.joey_ten)
			BannerInfo.Banner.KMOR:
				_calculate_drop_chances(BannerInfo.kmor_ten)
			BannerInfo.Banner.V:
				_calculate_drop_chances(BannerInfo.v_ten)
			BannerInfo.Banner.WILD:
				pass

## Calculates the weighted drop probabilities from the selected banner
func _calculate_drop_chances(banner: Dictionary) -> void:
	## Determines the int values from a range of 1 to 100 and pulls a random int
	var amyra_chance: float = banner[0]
	var joey_chance: float = amyra_chance + banner[1]
	var kmor_chance: float = joey_chance + banner[2]
	var v_chance: float = kmor_chance + banner[3]
	var common_chance: float = v_chance + banner[4]
	var uncommon_chance: float = common_chance + banner[5]
	var rare_chance: float = uncommon_chance + banner[6]
	var epic_chance: float = rare_chance + banner[7]
	var legendary_chance: float = epic_chance + banner[8]
	var rand: float = RNG.randf_range(0, 100.0)
	if UserData.POINTS > 0:
		if rand <= amyra_chance:
			DROP_RARITY = BannerInfo.BannerDrop.AMYRA
		if rand >= amyra_chance and rand <= joey_chance:
			DROP_RARITY = BannerInfo.BannerDrop.JOEY 
		if rand >= joey_chance and rand <= kmor_chance:
			DROP_RARITY = BannerInfo.BannerDrop.KMOR
		if rand >= kmor_chance and rand <= v_chance:
			DROP_RARITY = BannerInfo.BannerDrop.V 
		if rand >= v_chance and rand <= common_chance:
			DROP_RARITY = BannerInfo.BannerDrop.COMMON
		if rand >= common_chance and rand <= uncommon_chance:
			DROP_RARITY = BannerInfo.BannerDrop.UNCOMMON
		if rand >= uncommon_chance and rand <= rare_chance:
			DROP_RARITY = BannerInfo.BannerDrop.RARE
		if rand >= rare_chance and rand <= epic_chance:
			DROP_RARITY = BannerInfo.BannerDrop.EPIC
		if rand >= epic_chance and rand <= legendary_chance:
			DROP_RARITY = BannerInfo.BannerDrop.LEGENDARY
	_generate_drop()

## Creates a new item with these values and adds to user's inventory
func _generate_drop() -> void:
	new_drop = str(BannerInfo.BannerDrop.keys()[DROP_RARITY])
	var rarity: String = new_drop
	var bingo_word: String = new_drop
	var effect: String = ""
	var value: float = 0
	var quantity: int = 1
	
	## Randomizes bingo word text on card
	match DROP_RARITY:
		BannerInfo.BannerDrop.COMMON: # Regular bingo words
			var rand: int = randi_range(1, bingo_list.size()-1)
			bingo_word = bingo_list[rand]
			value = 0.2
		BannerInfo.BannerDrop.UNCOMMON:
			bingo_word = "GAMBLE"
			effect = "gamble for a random chance to gain/lose up to 1 pt (range: -1.0 to 1.0)"
			value = 0.4 
		BannerInfo.BannerDrop.RARE:
			bingo_word = "BINGO REROLL"
			effect = "reroll your bingo sheet (only if you haven't locked in already)"
			value = 0.6
		BannerInfo.BannerDrop.EPIC:
			bingo_word = "DOUBLE VALUE"
			effect = "combine with a card to double (2x) its value"
			value = 0.8
		BannerInfo.BannerDrop.LEGENDARY:
			bingo_word = "ROLLOVER POINT"
			effect = "gain 1 rollover pt which converts into 1 pt for the next month"
			value = 1.0
		BannerInfo.BannerDrop.AMYRA:
			bingo_word = new_drop
			value = 1.0
		BannerInfo.BannerDrop.JOEY:
			bingo_word = new_drop
			value = 1.0
		BannerInfo.BannerDrop.KMOR:
			bingo_word = new_drop
			value = 1.0
		BannerInfo.BannerDrop.V:
			bingo_word = new_drop
			value = 1.0
	_draw_card_pool(rarity, bingo_word, effect, value, quantity)
	#UserData.add_item_to_inv(rarity, bingo_word, effect, value, quantity)
	#_announce(bingo_word)
	#emit_signal("revealDrop", "%s" % bingo_word)

## Generates draw cards gacha pool
func _draw_card_pool(rarity: String, bingo_word: String, effect: String, value: float, quantity: int) -> void:
	var new_item: Dictionary = {
		"item_rarity": rarity,
		"bingo_word": bingo_word,
		"effect": effect,
		"value": value,
		"quantity": quantity
	}
	emit_signal("drawCardPool", new_item)

func select_card(card: CardItem) -> void:
	if !selected_card.is_empty():
		selected_card.clear()
		selected_card.append(card)
	else:
		selected_card.append(card)

func _activate_selected_card() -> void:
	if !selected_card.is_empty():
		selected_card[0].activate_effect()
