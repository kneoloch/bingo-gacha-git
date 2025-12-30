extends Button
class_name SyncData

@onready var console: ConsoleUI = %Console
@onready var inventory: Inventory = %Inventory
@onready var console_line: RichTextLabel = %ConsoleLine
@onready var player_hand: Control = %PlayerHand
@onready var destroy_area: Control = %DestroyArea

### Receive HTTP Data from Google Forms
func _on_pressed() -> void:
	#console.clear_grid_container()
	#UserData.get_gacha_data()
	console_line.announce_inv()
	player_hand.visible = !player_hand.visible
	destroy_area.visible = !destroy_area.visible
	#inventory.visible = !inventory.visible
