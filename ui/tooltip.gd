extends PanelContainer
class_name Tooltip

enum Option {EXCHANGE, GIFT}

## TODO: Fix exchange button to value
@onready var exchange_button: Button = %ValueButton
@onready var effect_description: RichTextLabel = %EffectDescription
@onready var activate_button: Button = %ActivateButton
@onready var gift_button: Button = $VBoxContainer/GiftButton
@onready var gift_amyra_button: Button = %GiftAmyraButton
@onready var gift_joey_button: Button = %GiftJoeyButton
@onready var gift_kmor_button: Button = %GiftKmorButton
@onready var gift_v_button: Button = %GiftVButton

func _ready() -> void:
	hide()
	_toggle_gifting_visibility(false)
	Gacha.connect("tooltip", _ui_toggle)
	Gacha.connect("hideTooltip", _hide)

func  _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		hide()

func _ui_toggle(in_hand: bool, card_data: Dictionary) -> void:
	match in_hand:
		true:
			show()
			if card_data["effect"] == "":
				effect_description.hide()
				activate_button.hide()
			else:
				effect_description.show()
				activate_button.show()
				if !get_tree().get_first_node_in_group("card_unclaimed_area").get_child_count() == 1:
					activate_button.hide()
				if !get_tree().get_first_node_in_group("draw_hand").get_child_count() == 0:
					activate_button.hide()
				if !get_tree().get_nodes_in_group("combiner_slot")[0].get_child_count() == 0 or !get_tree().get_nodes_in_group("combiner_slot")[1].get_child_count() == 0:
					activate_button.hide()
			gift_button.show()
		false:
			show()
			activate_button.hide()
			if card_data["effect"] == "":
				effect_description.hide()
			else:
				effect_description.show()
			gift_button.hide()
	_toggle_gifting_visibility(false)
	position = get_global_mouse_position()
	match card_data["item_rarity"]:
		"AMYRA":
			exchange_button.text = "value: %0.2f tally" % card_data["value"]
		"JOEY":
			exchange_button.text = "value: %0.2f tally" % card_data["value"]
		"KMOR":
			exchange_button.text = "value: %0.2f tally" % card_data["value"]
		"V":
			exchange_button.text = "value: %0.2f tally" % card_data["value"]
		"LEGENDARY":
			exchange_button.text = "value: %0.2f rollover pt" % card_data["value"]
		_:
			exchange_button.text = "value: %0.2f pts" % card_data["value"]
	effect_description.text = "effect:[p][font_size=12]%s" % card_data["effect"]

func _hide() -> void:
	hide()

func display_gift_options() -> void:
	_toggle_gifting_visibility(true)
	match UserData.USERNAME:
		"AMYRA":
			gift_amyra_button.hide()
		"JOEY":
			gift_joey_button.hide()
		"KMOR":
			gift_kmor_button.hide()
		"V":
			gift_v_button.hide()

func _tooltip(option: Option, _gifted_user: String) -> void:
	#var item_data: Dictionary = get_parent().get_parent().unique_item_data
	match option:
		Option.EXCHANGE:
			#UserData.exchange_item(item_data)
			print("exchange")
		Option.GIFT:
			#UserData.gift_item(item_data, gifted_user)
			get_parent().console_line._add_text("Sorry, this feature has not yet implemented!")
	self.hide()

func _on_gift_amyra_button_pressed() -> void:
	_tooltip(Option.GIFT, "AMYRA")
	_toggle_gifting_visibility(false)

func _on_gift_joey_button_pressed() -> void:
	_tooltip(Option.GIFT, "JOEY")
	_toggle_gifting_visibility(false)

func _on_gift_kmor_button_pressed() -> void:
	_tooltip(Option.GIFT, "KMOR")
	_toggle_gifting_visibility(false)

func _on_gift_v_button_pressed() -> void:
	_tooltip(Option.GIFT, "V")
	_toggle_gifting_visibility(false)

func _toggle_gifting_visibility(toggle: bool) -> void:
	match toggle:
		true:
			gift_amyra_button.show()
			gift_joey_button.show()
			gift_kmor_button.show()
			gift_v_button.show()
		false:
			gift_amyra_button.hide()
			gift_joey_button.hide()
			gift_kmor_button.hide()
			gift_v_button.hide()

#func _tooltip_text(username: String, value: float) -> void:
	#if UserData.USERNAME != username:
		#Tooltip.tooltip.exchange_button.text = "$ Value: 0.0 pts"
	#else:
		#tooltip.exchange_button.text = "$ Value: %0.1f tally" % value

func _on_activate_button_pressed() -> void:
	Gacha.activateCard.emit()

func _on_gift_button_pressed() -> void:
	display_gift_options()

func _on_mouse_exited() -> void:
	hide()
