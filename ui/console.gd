extends Control
class_name ConsoleUI

const CONSOLE_USER_INFO: PackedScene = preload("uid://df4miavu6f08j")
@onready var console: PanelContainer = %Console
@onready var console_container: VBoxContainer = %ConsoleContainer
@onready var resize_area: Control = %ResizeArea
var resize_area_vec2: Vector2 = Vector2(round(8), round(8))

func _ready() -> void:
	UserData.connect("getGachaData", _update_console_line)
	resize_area.custom_minimum_size = resize_area_vec2
	resize_area.position = console.size - (resize_area.custom_minimum_size / 2)

func _update_console_line(gacha_data: Dictionary) -> void:
	var console_line: Node = CONSOLE_USER_INFO.instantiate()
	console_container.add_child(console_line)
	console_line.user.text = gacha_data["User"]
	console_line.points.text = "obtained" #gacha_data["Points"] + " pts"
	var drop: Dictionary = JSON.parse_string(gacha_data["Drop"])
	console_line.drop_rarity.text = str(drop["item_rarity"])
	console_line.drop_word.text = str(drop["bingo_word"])

## Clear inventory UI grid
func clear_grid_container():
	while console_container.get_child_count() > 0:
		var child: Control = console_container.get_child(0)
		console_container.remove_child(child)
		child.queue_free()

## Console UI Resize
func _mouse_drag(_event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		console.size = get_local_mouse_position() #get_global_mouse_position()
		resize_area.position = console.size - (resize_area.custom_minimum_size / 2)

func _on_resize_area_tree_entered() -> void:
	var parent = $"."
	var child: Control = parent.get_node("ResizeArea")
	if child:
		child.connect("gui_input", _mouse_drag)

func _on_resize_area_tree_exited() -> void:
	var parent = $"."
	var child: Control = parent.get_node("ResizeArea")
	if child:
		child.disconnect("gui_input", _mouse_drag)
