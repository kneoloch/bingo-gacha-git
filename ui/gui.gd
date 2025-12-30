extends CanvasLayer
class_name GUI

signal ui_text_submit

## Login Screen
@onready var console_line: RichTextLabel = %ConsoleLine
@onready var login_screen: Control = %LoginScreen
@onready var login_screen_users: Login = %LoginScreenUsers
@onready var login_bar: HBoxContainer = %LoginBar
@onready var login_line_edit: LineEdit = %LoginLineEdit
@onready var welcome_text: RichTextLabel = %WelcomeText
@onready var enter_button: Button = %EnterButton
## Home Screen
@onready var home_hud: PanelContainer = %HomeHUD
@onready var console: ConsoleUI = %Console
@onready var expand_console_button: Button = %ExpandConsoleButton
@onready var user_options_tab: GridContainer = %UserOptionsTab
@onready var inventory: Inventory = %Inventory
@onready var banner_details_button: Button = %BannerDetailsButton
@onready var banner_details_panel: Panel = %BannerDetailsPanel
## Gacha Screen
@onready var gacha_screen: PanelContainer = %GachaScreen
@onready var tracker_tab: HBoxContainer = %TrackerTab
@onready var tally_tracker: Button = %TallyTracker
@onready var roll_over_tracker: Button = %RollOverTracker
@onready var points_tracker: Button = %PointsTracker
@onready var combine_cards_area: Control = %CombineCardsArea
## Bingo Screen
@onready var bingo_screen: Control = %BingoScreen
@onready var bingo: Bingo = %Bingo
@export var login_riddles: LoginRiddles = LoginRiddles.new()
## Password Login
var password_entered: bool = false
var password_string: String = "loveyou"
var login_input: String = ""

const CARD_ITEM = preload("uid://e1b4i6m040jv")
const TOOLTIP = preload("uid://cxpuhbc7y4p34")
var tooltip: Tooltip = TOOLTIP.instantiate()

func _ready() -> void:
	expand_console_button.text = " + "
	password_string = login_riddles.pick_random()
	login_gui_toggle(true)
	console_line.show()
	console_line.text = "[pulse freq=1.0 color=#ffffff40 ease=-2.0]Only [REAL] eunuchs know the password..."
	await get_tree().create_timer(0.5).timeout
	console_line.text = "[pulse freq=1.0 color=#ffffff40 ease=-2.0]Hint: " + login_riddles.riddles_dict[password_string] + " (all lowercase, no space)"
	## Signals
	connect("ui_text_submit", _login_input)
	bingo.connect("bingoWin", _bingo_win)
	gacha_screen.connect("gachaPull", _gacha_pull)
	Gacha.discard.connect(_discard, ConnectFlags.CONNECT_DEFERRED)
	Gacha.connect("cardActivated", _card_activated)
	UserData.connect("updatePoints", _point_count)
	UserData.connect("loginUser", login_gui_toggle) # login screen
	UserData.connect("getEunuchData", _get_eunuch_data)
	add_child(tooltip)

## Updates Interface with Online Data
func _get_eunuch_data(eunuch_data: Dictionary) -> void:
	#print("eunuch inv: %s" % eunuch_data["Inventory"])
	get_tree().get_first_node_in_group("draw_hand").clear()
	if get_tree().get_first_node_in_group("card_unclaimed_area").get_child_count() > 1:
		for child in get_tree().get_first_node_in_group("card_unclaimed_area").get_children():
			## TODO: Fix Error "p_child->data.parent != this" is true
			if child is CardItem:
				remove_child(child)
				child.queue_free()
	for slot: CardSlot in get_tree().get_nodes_in_group("card_slots"):
		slot.clear()
	for slot: Combiner in get_tree().get_nodes_in_group("combiner_slot"):
		slot.clear()
	
	if !eunuch_data.has("Inventory"):
		UserData.INVENTORY = []
	else:
		var inv_string: String = "[%s]" % eunuch_data["Inventory"]
		var u = str_to_var(inv_string)
		UserData.INVENTORY = [] #empties inv on user change
		#var card_slot_num: int = 1
		for i in u:
			UserData.INVENTORY.append(i)
			UserData.starter_inv.append(i)
		#print("inv: %s" % str(UserData.INVENTORY))
	get_tree().get_first_node_in_group("draw_hand").draw_starter_cards(get_tree().get_first_node_in_group("draw_hand").from.global_position, UserData.INVENTORY.size(), UserData.INVENTORY)
	UserData.POINTS = eunuch_data["Points"]
	UserData.ROLLOVER_POINTS = eunuch_data["Rollover Points"]
	UserData.TALLY = eunuch_data["Tally"]
	_point_count()

func _point_count() -> void:
	points_tracker.text = "%0.2f" % UserData.POINTS
	roll_over_tracker.text = "%0.2f" % UserData.ROLLOVER_POINTS
	tally_tracker.text = "%d" % UserData.TALLY
	gacha_screen.draw_buttons_toggle()

func _bingo_win(points: int) -> void:
	console_line._add_text("%s won %d pts from playing bingo!" % [UserData.USERNAME, points])
	UserData.POINTS += points
	_point_count()
	UserData.sync_eunuch_data(UserData.USERNAME, UserData.USER_TEXTURE, UserData.color(UserData.USER), UserData.POINTS, UserData.ROLLOVER_POINTS, UserData.TALLY, UserData.INVENTORY)

func _gacha_pull(points: int) -> void:
	if points == 1:
		console_line._add_text("%s spent %d pt to draw cards!" % [UserData.USERNAME, points])
	else:
		console_line._add_text("%s spent %d pts to draw cards!" % [UserData.USERNAME, points])
	_point_count()

func _card_activated(item_rarity: String, value: float) -> void:
	match item_rarity:
		"UNCOMMON": # GAMBLE
			console_line._add_text("%s obtained %0.2f pt!" % [UserData.USERNAME, value])
		"RARE": # BINGO REROLL
			if !Gacha.bingo_locked:
				console_line._add_text("%s activated a bingo reroll!" % UserData.USERNAME)
			if Gacha.bingo_locked:
				console_line._add_text("%s can't activate the card effect because the bingo sheet has already been locked!" % UserData.USERNAME)
		"EPIC": # DOUBLE VALUE
			pass
		"LEGENDARY": # ROLLOVER POINT
			console_line._add_text("%s obtained %0.2f rollover pt!" % [UserData.USERNAME, value])
	_point_count()

func _discard(item_rarity: String, value: float) -> void:
	match item_rarity:
		UserData.USERNAME: 
			UserData.TALLY += 1
			console_line._add_text("%s obtained %d tally!" % [UserData.USERNAME, value])
		"COMMON":
			UserData.POINTS += value
			if value <= 1.0:
				console_line._add_text("%s obtained %0.2f pt!" % [UserData.USERNAME, value])
			else:
				console_line._add_text("%s obtained %0.2f pts!" % [UserData.USERNAME, value])
		"UNCOMMON": # GAMBLE
			UserData.POINTS += value
			console_line._add_text("%s obtained %0.2f pt!" % [UserData.USERNAME, value])
		"RARE": # BINGO REROLL
			UserData.POINTS += value
			console_line._add_text("%s obtained %0.2f pt!" % [UserData.USERNAME, value])
		"EPIC": # DOUBLE VALUE
			UserData.POINTS += value
			console_line._add_text("%s obtained %0.2f pt!" % [UserData.USERNAME, value])
		"LEGENDARY": # ROLLOVER POINT
			UserData.ROLLOVER_POINTS += value
			console_line._add_text("%s obtained %0.2f rollover pt!" % [UserData.USERNAME, value])
	_point_count()
	#UserData.sync_eunuch_data(UserData.USERNAME, UserData.USER_TEXTURE, UserData.color(UserData.USER), UserData.POINTS, UserData.ROLLOVER_POINTS, UserData.TALLY, UserData.INVENTORY)

func login_gui_toggle(on: bool) -> void:
	match on:
		true: # Login Screen
			if !password_entered:
				## 1) Login input
				bingo_screen.hide()
				home_hud.hide()
				login_screen.show()
				login_screen_users.hide()
				login_line_edit.grab_focus()
			else:
				## 2) Select profile
				login_bar.hide()
				login_screen.show()
				login_screen_users.show()
				console_line.text = "[pulse freq=1.0 color=#ffffff40 ease=-2.0]Select your eunuch profile..."
			bingo_screen.hide()
			gacha_screen.hide()
			home_hud.hide()
		false:
			## Gacha screen
			login_screen.hide()
			gacha_screen.show()
			home_hud.show()

func _on_user_options_button_pressed() -> void:
	user_options_tab.visible = !user_options_tab.visible

func _on_switch_user_button_pressed() -> void:
	UserData.INVENTORY = []
	console_line._add_text("Select your eunuch profile...")
	login_gui_toggle(true)

func _on_expand_console_button_pressed() -> void:
	console.visible = !console.visible
	if !console.visible:
		expand_console_button.text = " + "
	else:
		expand_console_button.text = " - "

func _on_banner_details_button_pressed() -> void:
	banner_details_panel.visible = !banner_details_panel.visible
	if banner_details_panel.visible:
		banner_details_button.add_theme_color_override("font_color", UserData.color(UserData.USER))

func _on_login_line_edit_text_submitted(new_text: String) -> void:
	_scene_change(new_text)

func _scene_change(new_text: String) -> void:
	if new_text == password_string:
		password_entered = true
		login_gui_toggle(true)
		login_line_edit.hide()
	else:
		login_line_edit.clear()
		console_line.text = "[pulse freq=1.0 color=#ffffff40 ease=-2.0]Hint: " + login_riddles.riddles_dict[password_string] + " (all lowercase, no space)"

func _save_inv() -> void:
	UserData.INVENTORY = []
	for i in get_tree().get_nodes_in_group("card_drawn"):
		UserData.INVENTORY.append(i.unique_item_data)
	UserData.sync_eunuch_data(UserData.USERNAME, UserData.texture(UserData.USER), UserData.color(UserData.USER), UserData.POINTS, UserData.ROLLOVER_POINTS, UserData.TALLY, UserData.INVENTORY)

func _on_enter_button_pressed() -> void:
	_scene_change(login_input)
	enter_button.release_focus()
	login_line_edit.grab_focus()

func _login_input(new_text: String) -> void:
	login_input = new_text

func _on_login_line_edit_text_changed(new_text: String) -> void:
	ui_text_submit.emit(new_text)

func _on_play_bingo_button_pressed() -> void:
	bingo_screen.visible = !bingo_screen.visible

func _on_combine_button_pressed() -> void:
	combine_cards_area.visible = !combine_cards_area.visible

func _on_hide_combiner_button_pressed() -> void:
	combine_cards_area.hide()

func _on_save_button_pressed() -> void:
	_save_inv()
