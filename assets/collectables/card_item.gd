extends TextureButton
class_name CardItem

enum CardFace {FRONT, BACK}

@onready var draw_hand: DrawHand = get_parent()
@onready var item_word: RichTextLabel = %ItemWord
@onready var hover_texture: TextureRect = %HoverTexture
@onready var stack: RichTextLabel = %Stack

@export var face: CardFace = CardFace.BACK
@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0
@export_category("Oscillator")
@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0
const FRONT_CARD = preload("uid://bofrrxmbywp3e")
const BACK_CARD = preload("uid://dox0c1mtl3yq3")
const FRONT_CARD_FORGED = preload("uid://d2avd6q2cu48p")
const BACK_CARD_FORGED = preload("uid://cb2nbwrlgbs04")
const SIZE: Vector2 = Vector2(116, 148)
var flip: bool = false
var drawn: bool = false
var revealed: bool = false
var forged: bool = false
var unique_item_data: Dictionary
var starter: bool = false

var displacement: float = 0.0 
var oscillator_velocity: float = 0.0

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2
var middle_position: Vector2 = self.global_position + scale * size / 2.0

#var mouse_in: bool = false

func _ready() -> void:
	_face(face)
	# Convert to radians because lerp_angle is using that
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	self.connect("gui_input", _on_input)
	#Gacha.connect("revealDrop", _bingo_text)

func _process(delta: float) -> void:
	rotate_velocity(delta)
	follow_mouse(delta)

func  _unhandled_input(event: InputEvent) -> void:
	#mouse_in = false
	if is_hovered():
		if event.is_action_released("flip"):
			_flip_card(face)

func follow_mouse(_delta: float) -> void:
	if not following_mouse: return
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (size/2.0)

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.is_action_released("options"):
		Gacha.select_card(self)
		if drawn and face == CardFace.FRONT:
			Gacha.emit_signal("tooltip", false, unique_item_data)
			if Gacha.player_deck.has(self):
				Gacha.emit_signal("tooltip", true, unique_item_data)
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed():
		following_mouse = true
		Gacha.select_card(self)
		if drawn:
			self.reparent(draw_hand.to)
	else:
		## Drop card
		following_mouse = false
		if tween_handle and tween_handle.is_running():
			tween_handle.kill()
		tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_handle.tween_property(self, "rotation", 0.0, 0.3)
		
		_snap_to_slot()
		_discard()
		Gacha.checkUnclaimedCards.emit() # gacha_manager

func _on_gui_input(event: InputEvent) -> void:
	handle_mouse_click(event)
	# Don't compute rotation when moving the card
	if following_mouse: return
	if not event is InputEventMouseMotion: return
	
	# Handles rotation
	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	
	self.material.set_shader_parameter("x_rot", rot_y)
	self.material.set_shader_parameter("y_rot", rot_x)

func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.is_double_click():
			_flip_card(face)

func rotate_velocity(delta: float) -> void:
	if not following_mouse: return
	# Compute the velocity
	velocity = (position - last_pos) / delta
	last_pos = position
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	rotation = displacement

func _face(f: CardFace) -> void:
	match f:
		CardFace.FRONT:
			face = CardFace.FRONT
			if forged:
				texture_normal = FRONT_CARD_FORGED
			else:
				texture_normal = FRONT_CARD
			item_word.show()
			stack.show()
		CardFace.BACK:
			face = CardFace.BACK
			if forged:
				texture_normal = BACK_CARD_FORGED
			else:
				texture_normal = BACK_CARD
			item_word.hide()
			stack.hide()

func _flip_card(f: CardFace) -> void:
	if !drawn:
		return
	if !revealed:
		revealed = true
		_face(CardFace.FRONT)
	else:
		match f:
			CardFace.FRONT:
				_face(CardFace.BACK)
			CardFace.BACK:
				_face(CardFace.FRONT)

func generate_card(item_data: Dictionary) -> void:
	unique_item_data = item_data
	item_word.text = unique_item_data["bingo_word"]
	var rarity: String = unique_item_data["item_rarity"]
	match rarity:
		"AMYRA":
			item_word.add_theme_color_override("default_color", Color.CYAN)
		"JOEY":
			item_word.add_theme_color_override("default_color", UserData.color(UserData.User.JOEY))
		"KMOR":
			item_word.add_theme_color_override("default_color", UserData.color(UserData.User.KMOR))
		"V":
			item_word.add_theme_color_override("default_color", UserData.color(UserData.User.V))
		"UNCOMMON":
			item_word.add_theme_color_override("default_color", Color.SPRING_GREEN)
		"RARE":
			item_word.add_theme_color_override("default_color", Color.DEEP_SKY_BLUE)
		"EPIC":
			item_word.add_theme_color_override("default_color", Color.GOLD)
		"LEGENDARY":
			item_word.add_theme_color_override("default_color", Color.MAGENTA)
	stack.text = "x %d" % unique_item_data["quantity"]
	if unique_item_data["quantity"] > 1:
		forged = true
		_face(CardFace.BACK)
		print("%s: forged" % name)

func activate_effect() -> void:
	match unique_item_data["bingo_word"]:
		## Gamble for a random chance to gain/lose up to 1 pt (range: -1.0 to 1.0)
		"GAMBLE": 
			var gamble_point: float = snappedf(randf_range(-1, 1), 0.1)
			UserData.POINTS += gamble_point
			_reset_deck_arr()
			Gacha.cardActivated.emit(unique_item_data["item_rarity"], gamble_point)
			_destroy()
		## Reroll your bingo sheet (only if you haven't locked in already)
		"BINGO REROLL": 
			if !Gacha.bingo_locked:
				Gacha.bingoReroll.emit()
				_reset_deck_arr()
				_destroy()
			else:
				print("Bingo generation has already been locked for today!")
			Gacha.cardActivated.emit(unique_item_data["item_rarity"], unique_item_data["value"])
		## Gain 1 rollover pt which converts into 1 pt for the next month
		"ROLLOVER POINT": 
			UserData.ROLLOVER_POINTS += unique_item_data["value"]
			_reset_deck_arr()
			Gacha.cardActivated.emit(unique_item_data["item_rarity"], unique_item_data["value"])
			_destroy()

func _reset_deck_arr() -> void:
	following_mouse = false
	if Gacha.unclaimed_hand.has(self):
		Gacha.unclaimed_hand.erase(self)
	if Gacha.player_deck.has(self):
		Gacha.player_deck.erase(self)
	self.remove_from_group("card_drawn")
	if UserData.INVENTORY.has(unique_item_data):
		UserData.INVENTORY.erase(unique_item_data)
		UserData.sync_eunuch_data(UserData.USERNAME, UserData.texture(UserData.USER), UserData.color(UserData.USER), UserData.POINTS, UserData.ROLLOVER_POINTS, UserData.TALLY, UserData.INVENTORY)
	Gacha.selected_card = []
	Gacha.hideTooltip.emit()

## TODO: Implement "discard" with "delete" hotkey to tween discard from hand
func _discard() -> void:
	for i in get_tree().get_nodes_in_group("card_drawn"):
		if get_tree().get_first_node_in_group("discard_slot").get_global_rect().has_point(i.global_position):
			i.reparent(get_tree().get_first_node_in_group("discard_slot"))
			i.following_mouse = false
			i.global_position = get_tree().get_first_node_in_group("discard_slot").global_position
			if Gacha.unclaimed_hand.has(i):
				Gacha.unclaimed_hand.erase(i)
			if Gacha.player_deck.has(i):
				Gacha.player_deck.erase(i)
			Gacha.discard.emit(i.unique_item_data["item_rarity"], i.unique_item_data["value"])
			i._destroy()

func _destroy() -> void:
	rotation = 0
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()
	tween_destroy = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_destroy.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.5).from(Color.WHITE)
	await tween_destroy.finished
	queue_free()

func _snap_to_slot() -> void:
	for slot: CardSlot in get_tree().get_nodes_in_group("card_slots"):
		slot.snap_drag()
	
	for slot: Combiner in get_tree().get_nodes_in_group("combiner_slot"):
		slot.snap_to_combiner()

	for slot: CardSlot in get_tree().get_nodes_in_group("card_slots"):
		if slot.get_child_count() == 2:
			#print("%s is occupied" % slot.name)
			if slot.get_child(1) is CardItem:
				if !Gacha.player_deck.has(slot.get_child(1)):
					Gacha.player_deck.append(slot.get_child(1))
				if !UserData.INVENTORY.has(slot.get_child(1).unique_item_data):
					UserData.INVENTORY.append(slot.get_child(1).unique_item_data)
	#print("player deck: %s" % str(Gacha.player_deck))

func _on_pressed() -> void:
	if !drawn:
		_drawn_card()
	if !starter:
		return
	match Gacha.num_of_draws:
		1:
			draw_hand.undraw_cards(draw_hand.from.global_position)

func _drawn_card() -> void:
	drawn = true
	self.reparent(draw_hand.to)
	if !Gacha.unclaimed_hand.has(self):
		Gacha.unclaimed_hand.append(self)
	Gacha.emit_signal("drawn") # gacha_manager
	if !is_in_group("card_drawn"):
		add_to_group("card_drawn")
	if !UserData.starter_inv.has(unique_item_data):
		UserData.INVENTORY.append(unique_item_data)
		UserData.add_gacha_data(UserData.USERNAME, UserData.POINTS, self.unique_item_data)
		UserData.sync_eunuch_data(UserData.USERNAME, UserData.texture(UserData.USER), UserData.color(UserData.USER), UserData.POINTS, UserData.ROLLOVER_POINTS, UserData.TALLY, UserData.INVENTORY)
	else:
		UserData.starter_inv.erase(unique_item_data)

func _on_mouse_entered() -> void:
	if !drawn:
		position.y = -160
	hover_texture.set_self_modulate(UserData.color(UserData.USER))
	
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)

func _on_mouse_exited() -> void:
	if !drawn:
		position.y = -80
	hover_texture.set_self_modulate(Color(0.13, 0.13, 0.13, 1.0))
	# Reset rotation
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(self.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(self.material, "shader_parameter/y_rot", 0.0, 0.5)
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
