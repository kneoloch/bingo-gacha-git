extends HBoxContainer
class_name Login
## Emits loginUser and getEunuchData

@onready var console_line: RichTextLabel = %ConsoleLine
@onready var user_options_button: Button = %UserOptionsButton
@onready var amyra_login_button: Button = %AmyraLoginButton
@onready var joey_login_button: Button = %JoeyLoginButton
@onready var kmor_login_button: Button = %KmorLoginButton
@onready var v_login_button: Button = %VLoginButton

func _ready() -> void:
	_user_color(amyra_login_button, Color.CYAN)
	_user_color(joey_login_button, UserData.color(UserData.User.JOEY))
	_user_color(kmor_login_button, UserData.color(UserData.User.KMOR))
	_user_color(v_login_button, UserData.color(UserData.User.V))

## Assign eunuchs' UI colors
func _user_color(button: Button, c: Color) -> void:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(.13, .13, .13)
	style_box.border_color = c
	style_box.set_border_width_all(4)
	button.add_theme_stylebox_override("hover", style_box)
	button.add_theme_color_override("font_pressed_color", c)

func _login(u: UserData.User) -> void:
	## Load Interface
	UserData.change_user(u) # assign user
	print("Login for %s..." % UserData.username(u, false))
	console_line._add_text("%s has signed in." % str(UserData.User.keys()[u]))
	user_options_button.show()
	user_options_button.text = UserData.username(u, true)
	user_options_button.add_theme_color_override("font_color", UserData.color(UserData.USER))
	## Signals
	UserData.emit_signal("loginUser", false)
	UserData.get_eunuchs_data() # retrieves online data
	Gacha.get_bingo_bank()
	self.hide() # hides login screen

func _on_amyra_login_button_pressed() -> void:
	_login(UserData.User.AMYRA)

func _on_joey_login_button_pressed() -> void:
	_login(UserData.User.JOEY)

func _on_kmor_login_button_pressed() -> void:
	_login(UserData.User.KMOR)

func _on_v_login_button_pressed() -> void:
	_login(UserData.User.V)

func _on_amyra_login_button_mouse_entered() -> void:
	amyra_login_button.text = ""
	amyra_login_button.add_theme_icon_override("icon", UserData.texture(UserData.User.AMYRA))

func _on_amyra_login_button_mouse_exited() -> void:
	amyra_login_button.text = "A"
	amyra_login_button.remove_theme_icon_override("icon")

func _on_joey_login_button_mouse_entered() -> void:
	joey_login_button.text = ""
	joey_login_button.add_theme_icon_override("icon", UserData.texture(UserData.User.JOEY))

func _on_joey_login_button_mouse_exited() -> void:
	joey_login_button.text = "J"
	joey_login_button.remove_theme_icon_override("icon")

func _on_kmor_login_button_mouse_entered() -> void:
	kmor_login_button.text = ""
	kmor_login_button.add_theme_icon_override("icon", UserData.texture(UserData.User.KMOR))

func _on_kmor_login_button_mouse_exited() -> void:
	kmor_login_button.text = "K"
	kmor_login_button.remove_theme_icon_override("icon")

func _on_v_login_button_mouse_entered() -> void:
	v_login_button.text = ""
	v_login_button.add_theme_icon_override("icon", UserData.texture(UserData.User.V))

func _on_v_login_button_mouse_exited() -> void:
	v_login_button.text = "V"
	v_login_button.remove_theme_icon_override("icon")
