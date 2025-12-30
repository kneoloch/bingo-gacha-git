extends PanelContainer
class_name Bingo

signal bingoWin
signal bingoHighlight
signal lockBingo
enum BingoLines {COLUMN_1, COLUMN_2, COLUMN_3,COLUMN_4, COLUMN_5, ROW_1, ROW_2, ROW_3, ROW_4, ROW_5, DIAGONAL_1, DIAGONAL_2}

@onready var bingo_grid: GridContainer = %BingoGrid
@onready var http: HTTPRequest = %HTTPRequest
@onready var loading_text: RichTextLabel = %LoadingText
@onready var generate_button: Button = %GenerateButton
@onready var bingo_tab: HBoxContainer = %BingoTab
@onready var tab_label: RichTextLabel = %TabLabel
@onready var minimize_button: Button = %MinimizeButton
@onready var sub_viewport: SubViewport = %SubViewport
@onready var lock_button: TextureButton = $SubViewportContainer/SubViewport/VBoxContainer/PanelContainer/HBoxContainer/BingoTab/LockButton
@onready var reroll_button: Button = %RerollButton
@onready var clear_marks_button: Button = %ClearMarksButton
@onready var pop_up_panel: PanelContainer = %PopUpPanel

const BINGO_BOX = preload("uid://boqjn0ltpmrr2")
var selected_words: Array[String] = []
var column_1: Array = [0, 5, 10, 15, 20]
var column_2: Array = [1, 6, 11, 16, 21]
var column_3: Array = [2, 7, 12, 17, 22]
var column_4: Array = [3, 8, 13, 18, 23]
var column_5: Array = [4, 9, 14, 19, 24]
var row_1: Array = [0, 1, 2, 3, 4]
var row_2: Array = [5, 6, 7, 8, 9]
var row_3: Array = [10, 11, 12, 13, 14]
var row_4: Array = [15, 16, 17, 18, 19]
var row_5: Array = [20, 21, 22, 23, 24]
var diagonal_1: Array = [0, 6, 12, 18, 24]
var diagonal_2: Array = [4, 8, 12, 16, 20]
var completed_lines: Array = []
var bingo_lines: Dictionary = {
	COLUMN_1 = column_1,
	COLUMN_2 = column_2,
	COLUMN_3 = column_3,
	COLUMN_4 = column_4,
	COLUMN_5 = column_5,
	ROW_1 = row_1,
	ROW_2 = row_2,
	ROW_3 = row_3,
	ROW_4 = row_4,
	ROW_5 = row_5,
	DIAGONAL_1 = diagonal_1,
	DIAGONAL_2 = diagonal_2
}
var box_1: int = 0
var box_2: int = 5
var box_3: int = 10
var box_4: int = 15
var box_5: int = 20
var space_num: int = 1
## Window Drag UI
var drag_window: bool = false
var prev_mouse_pos: Vector2 = Vector2.ZERO
var minimize_toggle: bool = false
var style_box: StyleBoxFlat = get_theme_stylebox("panel")

func _ready() -> void:
	#size = Vector2(660.0, 691.0)
	generate_button.show()
	bingo_tab.hide()
	loading_text.hide()
	tab_label.hide()
	pop_up_panel.hide()
	minimize_button.hide()
	reroll_button.disabled = true
	_solid_bg_panel(true)
	Gacha.bingoReroll.connect(_reroll)

func _process(_delta: float) -> void:
	## UI: Draggable window
	if drag_window:
		var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var mouse_delta = curr_mouse_pos - prev_mouse_pos
		position += mouse_delta
		prev_mouse_pos = curr_mouse_pos

func _solid_bg_panel(transparency: bool):
	if transparency:
		style_box.bg_color = Color(.13, .13, .13, 0)
		add_theme_stylebox_override("panel", style_box)
	else:
		style_box.bg_color = Color(.13, .13, .13, 1)
		add_theme_stylebox_override("panel", style_box)

func _generate_bingo() -> void:
	var bingo_box: BingoBox = BINGO_BOX.instantiate()
	bingo_grid.add_child(bingo_box)
	bingo_box.name = "BingoBox%d" % space_num
	if bingo_box.name == "BingoBox13":
		bingo_box.add_word("FREE SPACE")
	else:
		bingo_box.add_word(selected_words[space_num - 1])

func _bingo_shuffle() -> void:
	selected_words = []
	selected_words.append_array(Gacha.priority_critical)
	Gacha.priority_normal.shuffle()
	for i: int in 15:
		selected_words.append(Gacha.priority_normal[i])
	Gacha.priority_honorary.shuffle()
	for i: int in 5:
		selected_words.append(Gacha.priority_honorary[i])
	selected_words.shuffle()

func _add_bingo_boxes() -> void:
	for i: int in 25:
		_generate_bingo()
		space_num += 1

func _clear_bingo_grid() -> void:
	while bingo_grid.get_child_count() > 0:
		var child: Control = bingo_grid.get_child(0) 
		bingo_grid.remove_child(child)
		child.queue_free()

func check_for_bingo() -> void:
	var curr_arr: Array = []
	completed_lines = []
	## Checks through all bingo win combination lines (columns, rows, diagonals) 
	for i: StringName in bingo_lines: #ie. column_1: StringName
		curr_arr = bingo_lines[i] #ie. [0, 5, 10, 15, 20]: Array
		box_1 = curr_arr[0] #ie. 0 
		box_2 = curr_arr[1] #ie. 5
		box_3 = curr_arr[2] #ie. 10
		box_4 = curr_arr[3] #ie. 15
		box_5 = curr_arr[4] #ie. 20
		## Checks if all of the boxes in the bingo line's array are marked (5-in-a-row)!
		if bingo_grid.get_child(box_1).marked and bingo_grid.get_child(box_2).marked and bingo_grid.get_child(box_3).marked and bingo_grid.get_child(box_4).marked and bingo_grid.get_child(box_5).marked:
			## Adds [i] StringName to [completed_lines] Array
			completed_lines.append(i) #ie. [column_1]
			_update_bingo_indicator(curr_arr, false)
	for lines: StringName in bingo_lines:
		if !completed_lines.has(lines):
			_update_bingo_indicator(bingo_lines[lines], false)
	for line in completed_lines:
		#print("%s: complete!" % str(line))
		_update_bingo_indicator(bingo_lines[line], true)
	#print("--Check completed!-- \n")

func _update_bingo_indicator(bingo_line: Array, bingo_win: bool) -> void:
	for boxes: int in bingo_line:
		bingo_grid.get_child(boxes).bingo = bingo_win
		emit_signal("bingoHighlight")

func _locking_in() -> void:
	#for line in completed_lines:
		#print("%s: complete!" % str(line))
	emit_signal("bingoWin", completed_lines.size()*5)
	emit_signal("lockBingo")
	Gacha.bingo_locked = true
	lock_button.disabled = true
	reroll_button.hide()
	clear_marks_button.hide()
	_screenshot()

func _on_generate_button_pressed() -> void:
	generate_button.hide()
	loading_text.show()
	tab_label.text = "%s'S BINGO SHEET" % UserData.USERNAME
	await get_tree().create_timer(1.0).timeout
	_bingo_shuffle()
	await get_tree().create_timer(0.5).timeout
	loading_text.hide()
	bingo_tab.show()
	minimize_button.show()
	_solid_bg_panel(false)
	_add_bingo_boxes()

func _reroll() -> void:
	reroll_button.disabled = false

func _on_reroll_button_pressed() -> void:
	space_num = 1
	loading_text.show()
	_bingo_shuffle()
	_clear_bingo_grid()
	bingo_tab.hide()
	_solid_bg_panel(true)
	await get_tree().create_timer(0.5).timeout
	_add_bingo_boxes()
	loading_text.hide()
	bingo_tab.show()
	_solid_bg_panel(false)
	reroll_button.disabled = true

func _on_clear_marks_button_pressed() -> void:
	for boxes: int in bingo_grid.get_child_count():
		bingo_grid.get_child(boxes).clear_marks()

## UI
func _minimize(toggled_on: bool) -> void:
	match toggled_on:
		true:
			minimize_toggle = true
			bingo_grid.visible = false
			self.size.y = 35.0
			tab_label.show()
			bingo_tab.hide()
			_solid_bg_panel(true)
		false:
			minimize_toggle = false
			bingo_grid.visible = true
			self.size.y = 680.0
			tab_label.hide()
			bingo_tab.show()
			_solid_bg_panel(false)

func _on_drag_window_button_button_up() -> void:
	drag_window = false

func _on_drag_window_button_button_down() -> void:
	drag_window = true
	prev_mouse_pos = get_viewport().get_mouse_position()

func _on_minimize_button_toggled(toggled_on: bool) -> void:
	_minimize(toggled_on)

func _on_drag_window_button_gui_input(event: InputEvent) -> void:
	if !generate_button.visible:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			minimize_toggle = !minimize_toggle
			_minimize(minimize_toggle)

func _screenshot() -> void:
	var img: Image = sub_viewport.get_texture().get_image()
	var datetime_string = Time.get_datetime_string_from_system()
	img.save_png("res://screenshots/%s_%s.png" % [UserData.USERNAME, datetime_string.replace("-", "").replace(":", "").replace("T", "_")])

func _on_screenshot_button_pressed() -> void:
	_screenshot()

func _on_lock_button_pressed() -> void:
	pop_up_panel.show()

func _on_confirm_button_pressed() -> void:
	pop_up_panel.hide()
	_locking_in()

func _on_cancel_button_pressed() -> void:
	pop_up_panel.hide()

func _on_hide_button_pressed() -> void:
	get_parent().hide()
