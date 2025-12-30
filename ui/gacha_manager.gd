extends PanelContainer
class_name GachaManager

signal gachaPull

@onready var bingo_screen: Control = %BingoScreen
@onready var player_hand: Control = %PlayerHand
@onready var destroy_area: Control = %DestroyArea
@onready var combine_cards_area: Control = %CombineCardsArea

@onready var draw_hand: DrawHand = %DrawHand
@onready var center_mark: Control = %CenterMark
@onready var one_draw_button: Button = %OneDrawButton
@onready var ten_draws_button: Button = %TenDrawsButton
@onready var console: ConsoleUI = %Console
@onready var console_line: RichTextLabel = %ConsoleLine
## BANNERS
@onready var banner_texture: TextureRect = %BannerTexture
@onready var standard_banner_button: Button = %StandardBannerButton
@onready var one_details_label: RichTextLabel = %OneDetailsLabel
@onready var ten_details_label: RichTextLabel = %TenDetailsLabel
## Banner Info and Rewards Probability Dataset
@export var banner_info: BannerInfo = BannerInfo.new()
@export var starting_banner: Button
static var selected_banner: Button
var CURR_BANNER: BannerInfo.Banner = BannerInfo.Banner.STANDARD
var RNG: RandomNumberGenerator = RandomNumberGenerator.new()
var DROP: BannerInfo.BannerDrop
var drop_announcement: String = ""
var draws: int = 1
var user: String = str(UserData.User.keys()[UserData.USER])
var new_drop: String = str(BannerInfo.BannerDrop.keys()[DROP])
var drawn_card_collection: Array = []

func _ready() -> void:
	selected_banner = starting_banner
	_choose_banner(CURR_BANNER)
	_toggle_inv(false)
	_toggle_draw_buttons(true)
	Gacha.connect("selectBanner", _on_selected_banner)
	Gacha.drawCardPool.connect(_new_card_collection)
	Gacha.drawn.connect(_drawn, ConnectFlags.CONNECT_DEFERRED) # card_item
	Gacha.toggleDraws.connect(_toggle_draw_buttons, ConnectFlags.CONNECT_DEFERRED)
	Gacha.checkUnclaimedCards.connect(_check_for_unclaimed_cards) # card_item
	Gacha.toggleInv.connect(_toggle_inv) # card_item, #drawn_cards

func _input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		player_hand.visible = !player_hand.visible
		destroy_area.visible = !destroy_area.visible

func _toggle_draw_buttons(lock: bool) -> void:
	one_draw_button.disabled = lock
	ten_draws_button.disabled = lock

## Updates console text to announce the drop
func _announce(card_text: String) -> void:
	user = str(UserData.User.keys()[UserData.USER])
	new_drop = str(BannerInfo.BannerDrop.keys()[DROP])
	if DROP == BannerInfo.BannerDrop.COMMON:
		drop_announcement = user + " has obtained " + new_drop + ": " + card_text + "!"
	else:
		drop_announcement = user + " has obtained " + new_drop + "!"
	console_line._add_text(drop_announcement)

func _choose_banner(banner: BannerInfo.Banner) -> void:
	CURR_BANNER = banner
	Gacha.CURR_BANNER = banner
	banner_info.get_banner_texture(CURR_BANNER)
	_banner_details()

func _on_selected_banner(_banner: BannerInfo.Banner, texture: CompressedTexture2D) -> void:
	banner_texture.texture = texture

func _banner_details() -> void:
	var keys: Array = BannerInfo.BannerDrop.keys()
	var one_values: Array = []
	var ten_values: Array = []
	match CURR_BANNER:
		BannerInfo.Banner.STANDARD:
			one_values = BannerInfo.standard_one.values()
			ten_values = BannerInfo.standard_ten.values()
		BannerInfo.Banner.AMYRA:
			one_values = BannerInfo.amyra_one.values()
			ten_values = BannerInfo.amyra_ten.values()
		BannerInfo.Banner.JOEY:
			one_values = BannerInfo.joey_one.values()
			ten_values = BannerInfo.joey_ten.values()
		BannerInfo.Banner.KMOR:
			one_values = BannerInfo.kmor_one.values()
			ten_values = BannerInfo.kmor_ten.values()
		BannerInfo.Banner.V:
			one_values = BannerInfo.v_one.values()
			ten_values = BannerInfo.v_ten.values()
		BannerInfo.Banner.WILD:
			## TODO: Add randomizer
			pass
	var one_details: Dictionary = {}
	var ten_details: Dictionary = {}
	for i: int in keys.size():
		var percentages: String = str(one_values[i]) + "%"
		one_details[keys[i]] = percentages
	for i: int in keys.size():
		var percentages: String = str(ten_values[i]) + "%"
		ten_details[keys[i]] = percentages
	var one: String = str(one_details).replace("\"", "").replace(",", "\n").replace("{ ", " ").replace(" }", "")
	var ten: String = str(ten_details).replace("\"", "").replace(",", "\n").replace("{ ", " ").replace(" }", "")
	one_details_label.text = "1 pt | Draw x 1:\n" + one
	ten_details_label.text = "10 pts | Draw x 10:\n" + ten

func _new_card_collection(item_data: Dictionary) -> void:
		drawn_card_collection.append(item_data)
		if drawn_card_collection.size() == 10:
			draw_hand.draw_cards(draw_hand.from.position, 10, drawn_card_collection)
			drawn_card_collection.clear()

## If user does not have enough points to spend, draw buttons are disabled
func draw_buttons_toggle() -> void:
	if UserData.POINTS >= 10:
		_toggle_draw_buttons(false)
	if UserData.POINTS < 10:
		one_draw_button.disabled = false
		ten_draws_button.disabled = true
	if UserData.POINTS == 1:
		one_draw_button.disabled = false
		ten_draws_button.disabled = true
	if UserData.POINTS < 1:
		_toggle_draw_buttons(true)
	if UserData.POINTS <= 0:
		UserData.POINTS = 0
		_toggle_draw_buttons(true)
	_check_hand()

func _drawn() -> void:
	if !draw_hand.get_child_count() == 0:
		_toggle_draw_buttons(true)
	if draw_hand.get_child_count() == 0:
		_check_for_unclaimed_cards()

func _check_for_unclaimed_cards() -> void:
	if center_mark.get_child_count() == 1:
		draw_buttons_toggle()
	_check_hand()

func _check_hand() -> void:
	if !center_mark.get_child_count() == 1:
		_toggle_draw_buttons(true)
	if !draw_hand.get_child_count() == 0:
		_toggle_draw_buttons(true)
	## If the combiner slots are occupied, the gacha draw cards buttons are locked.
	if !get_tree().get_nodes_in_group("combiner_slot")[0].get_child_count() == 0 or !get_tree().get_nodes_in_group("combiner_slot")[1].get_child_count() == 0:
		_toggle_draw_buttons(true)
	if !draw_hand.get_child_count() == 0:
		_toggle_draw_buttons(true)

func _draws(num: int) -> void:
	_toggle_inv(false) # true
	_toggle_draw_buttons(true)
	## Subtracts points from user's points pool on banner draws
	UserData.POINTS -= num
	for i: int in 10:
		Gacha.draw_card(Gacha.CURR_BANNER, num)
	gachaPull.emit(num) # Updates GUI's point tracker
	Gacha.emit_signal("drawn")
	#UserData.emit_signal("updatePoints") 

func _toggle_inv(toggle: bool) -> void:
	match toggle:
		true:
			bingo_screen.hide()
			destroy_area.show()
			player_hand.show()
		false:
			bingo_screen.hide()
			destroy_area.hide()
			player_hand.hide()

func _on_one_draw_button_pressed() -> void:
	_draws(1)

func _on_ten_draws_button_pressed() -> void:
	_draws(10)

func _on_standard_banner_button_pressed() -> void:
	_choose_banner(BannerInfo.Banner.STANDARD)

func _on_amyra_banner_button_pressed() -> void:
	_choose_banner(BannerInfo.Banner.AMYRA)

func _on_joey_banner_button_pressed() -> void:
	_choose_banner(BannerInfo.Banner.JOEY)
