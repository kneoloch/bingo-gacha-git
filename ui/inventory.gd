extends Control
class_name Inventory

enum Action {ADD, REMOVE}

@onready var inventory_container: PanelContainer = %InventoryContainer
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var resize_area: Control = %ResizeArea
@onready var console_line: Console = %ConsoleLine
@export var ITEM_SLOT: PackedScene = preload("uid://cycdpqauu8805")
var resize_area_vec2: Vector2 = Vector2(round(8), round(8))
var INV_SIZE: int = UserData.INVENTORY.size() + 1
var minimize: bool = false
var drag_window: bool = false
var prev_mouse_pos: Vector2 = Vector2.ZERO
var item_data: Dictionary = {}

func _ready() -> void:
	## Updates inventory UI
	UserData.connect("addItem", _update_inv.bind(Action.ADD))
	UserData.connect("removeItem", _update_inv.bind(Action.REMOVE))
	UserData.connect("getEunuchData", _display_eunuch_inventory) #ConnectFlags.CONNECT_DEFERRED)
	resize_area.custom_minimum_size = resize_area_vec2
	resize_area.position = inventory_container.size - (resize_area.custom_minimum_size / 2)

func _process(_delta: float) -> void:
	## UI: Draggable window
	if drag_window:
		var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var mouse_delta = curr_mouse_pos - prev_mouse_pos
		position += mouse_delta
		prev_mouse_pos = curr_mouse_pos

func _mouse_drag(_event: InputEvent) -> void:
	## UI: Resizable window
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		inventory_container.size = get_local_mouse_position() 
		resize_area.position = inventory_container.size - (resize_area.custom_minimum_size / 2)

func _display_eunuch_inventory(eunuch_data: Dictionary) -> void:
	_clear_grid_container()
	if !eunuch_data.has("Inventory"):
		UserData.INVENTORY = []
	else:
		var inv_string: String = "[%s]" % eunuch_data["Inventory"]
		var u = str_to_var(inv_string)
		UserData.INVENTORY = [] #empties inv on user change
		for i in u:
			_update_inv(i, Action.ADD)

## Clear inventory UI grid
func _clear_grid_container():
	while inventory_grid.get_child_count() > 0:
		var child: Control = inventory_grid.get_child(0) 
		inventory_grid.remove_child(child)
		child.queue_free()

## Spawns item instance
func _update_inv(item: Dictionary, action: Action) -> void:
	match action:
		Action.ADD:
			var slot: ItemSlot = ITEM_SLOT.instantiate()
			inventory_grid.add_child(slot)
			slot.add_item(item)
		Action.REMOVE:
			for i in inventory_grid.get_child_count():
				if inventory_grid.get_child(i).unique_item_data == item:
					var slot: ItemSlot = inventory_grid.get_child(i)
					slot.destroy()
					inventory_grid.remove_child(slot)
			console_line.announce_inv()

## UI
func _on_drag_window_button_button_up() -> void:
	drag_window = false

func _on_drag_window_button_button_down() -> void:
	drag_window = true
	prev_mouse_pos = get_viewport().get_mouse_position()

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

## Minimize window to a collapsed taskbar
func _on_minimize_button_pressed() -> void:
	minimize = !minimize
	if minimize:
		inventory_container.size.y = 36
	else:
		inventory_container.size.y = 404

func _on_exit_button_pressed() -> void:
	hide()
