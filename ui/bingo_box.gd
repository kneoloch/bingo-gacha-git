extends PanelContainer
class_name BingoBox

@onready var parent: Bingo = get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var button: TextureButton = %TextureButton
@onready var checkmark: TextureRect = %Checkmark
@onready var word: RichTextLabel = %RichTextLabel
var bingo: bool = false
var marked: bool = false
var locked: bool = false

func _ready() -> void:
	checkmark.hide()
	button.material.set_shader_parameter("mix_color", Color(.13, .13, .13, 1))
	parent.connect("bingoHighlight", _highlight_bingo_line)
	parent.connect("lockBingo", _locked)

func add_word(bingo_word: String) -> void:
	word.text = "[outline_size={4}]%s[/outline_size]" % bingo_word

func clear_marks() -> void:
	marked = false
	checkmark.visible = false
	bingo = false
	_highlight_bingo_line()

func _highlight_bingo_line() -> void:
	var color_to_add = Color(0.2, 0.2, 0.2, 0.5) 
	if bingo:
		if UserData.USER == 0:
			button.material.set_shader_parameter("mix_color", (Color.CYAN - color_to_add).clamp())
		else:
			button.material.set_shader_parameter("mix_color", (UserData.color(UserData.USER) - color_to_add).clamp()) 
	else:
		button.material.set_shader_parameter("mix_color", Color(.13, .13, .13, 1))

func _locked() -> void:
	locked = true

func _on_texture_button_pressed() -> void:
	if !locked:
		marked = !marked
		checkmark.visible = !checkmark.visible
		parent.check_for_bingo()
		#print("%s marked: %s" % [self.name, str(marked)])
