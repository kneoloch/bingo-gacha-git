extends RichTextLabel
class_name Console

func announce_inv() -> void:
	_add_text(UserData.get_inventory())

func _add_text(text_to_add: String) -> void:
	clear()
	append_text("[pulse freq=1.0 color=#ffffff40 ease=-2.0]" + text_to_add)
