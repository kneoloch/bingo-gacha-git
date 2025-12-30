extends Panel
class_name Combiner

@onready var combiner1: Combiner = get_tree().get_nodes_in_group("combiner_slot")[0]
@onready var combiner2: Combiner = get_tree().get_nodes_in_group("combiner_slot")[1]
var middle_position: Vector2 = self.global_position + scale * size / 2.0

## Window Drag UI
var drag_window: bool = false
var prev_mouse_pos: Vector2 = Vector2.ZERO

static var valid_combo: bool = false

func _ready() -> void:
	if !is_in_group("combiner_slot"):
		add_to_group("combiner_slot")

func _process(_delta: float) -> void:
	## UI: Draggable window
	if drag_window:
		var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var mouse_delta = curr_mouse_pos - prev_mouse_pos
		get_parent().get_parent().position += mouse_delta
		prev_mouse_pos = curr_mouse_pos

func snap_to_combiner() -> void:
	for card: CardItem in get_tree().get_nodes_in_group("card_drawn"):
		if !self.get_child_count() == 0:
			return
		if self.get_global_rect().has_point(card.global_position + scale * size / 2.0):
			card.reparent(self)
			card.following_mouse = false
			card.global_position = self.global_position
	
	if combiner1.get_child_count() == 1 and combiner2.get_child_count() == 1:
		if combiner2.get_child(0).unique_item_data["bingo_word"] == combiner2.get_child(0).unique_item_data["bingo_word"]:
			valid_combo = true
		if combiner1.get_child(0).unique_item_data["bingo_word"] == "DOUBLE VALUE" or combiner2.get_child(0).unique_item_data["bingo_word"] == "DOUBLE VALUE":
			if combiner1.get_child(0).unique_item_data["bingo_word"] == "DOUBLE VALUE" and combiner2.get_child(0).unique_item_data["bingo_word"] == "DOUBLE VALUE":
				return
			else:
				valid_combo = true
	else:
		valid_combo = false

func _combine(card1: CardItem, card2: CardItem) -> void:
	print("Combine %s and %s!" % [card1.unique_item_data["bingo_word"], card2.unique_item_data["bingo_word"]])
	## Combine cards with the same bingo word into a stack
	if card1.unique_item_data["bingo_word"] == card2.unique_item_data["bingo_word"] and card1.unique_item_data["quantity"] == card2.unique_item_data["quantity"]:
		card2.unique_item_data["quantity"] = card1.unique_item_data["quantity"] + card2.unique_item_data["quantity"]
		card2.stack.text = "x %d" % card2.unique_item_data["quantity"]
		## Calculate card stack value based off of the rarity's base value:
		match card2.unique_item_data["item_rarity"]:
			"COMMON":
				card2.unique_item_data["value"] = card2.unique_item_data["quantity"] * 0.2
			"UNCOMMON": # GAMBLE
				card2.unique_item_data["value"] = card2.unique_item_data["quantity"] * 0.4
			"RARE":
				card2.unique_item_data["value"] = card2.unique_item_data["quantity"] * 0.6
			"EPIC":
				card2.unique_item_data["value"] = card2.unique_item_data["quantity"] * 0.8
			_:
				card2.unique_item_data["value"] = card2.unique_item_data["quantity"] * 1.0
		_forged(card2, card1)
	
	## Combine with a card to double (2x) its value
	if card1.unique_item_data["bingo_word"] == "DOUBLE VALUE":
		card2.unique_item_data["value"] = card2.unique_item_data["value"] * 2
		_forged(card2, card1)
	if card2.unique_item_data["bingo_word"] == "DOUBLE VALUE":
		card1.unique_item_data["value"] = card1.unique_item_data["value"] * 2
		_forged(card1, card2)

func _forged(forged_card: CardItem, destroyed_card: CardItem) -> void:
		forged_card.forged = true
		forged_card._face(forged_card.face)
		#forged_card.item_word.add_theme_color_override("default_color", Color.GOLD)
		destroyed_card._reset_deck_arr()
		destroyed_card._destroy()

func clear() -> void:
	while get_child_count() > 0:
		var child: Control = get_child(0) 
		remove_child(child)
		child.queue_free()

func _on_combine_button_pressed() -> void:
	if valid_combo:
		_combine(combiner1.get_child(0), combiner2.get_child(0))

func _on_drag_window_button_button_up() -> void:
	drag_window = false

func _on_drag_window_button_button_down() -> void:
	drag_window = true
	prev_mouse_pos = get_viewport().get_mouse_position()

func _on_drag_window_button_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			get_parent().visible = !get_parent().visible
