extends PanelContainer
class_name ItemSlot

@onready var item_icon: TextureButton = %ItemIcon
@onready var tooltip: PanelContainer = %Tooltip
@onready var item_word: RichTextLabel = %ItemWord
@onready var stack: RichTextLabel = %Stack
#@onready var shadow = $Shadow
#@onready var collision_shape = $DestroyArea/CollisionShape2D
@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0
@export_category("Oscillator")
@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0

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

const BLANK_CARD: CompressedTexture2D = preload("uid://dwxwaxfjpnjlp")
const FRONT_CARD: CompressedTexture2D = preload("uid://bofrrxmbywp3e")
var unique_item_data: Dictionary = {}
var mouse_in: bool = false

func _ready() -> void:
	tooltip.hide()
	set_empty()
	# Convert to radians because lerp_angle is using that
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	#collision_shape.set_deferred("disabled", true)

func _process(delta: float) -> void:
	rotate_velocity(delta)
	follow_mouse(delta)
	#handle_shadow(delta)

func  _unhandled_input(_event: InputEvent) -> void:
	mouse_in = false
	tooltip_ui()

func follow_mouse(_delta: float) -> void:
	if not following_mouse: return
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (size/2.0)

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed():
		following_mouse = true
	else:
		# drop card
		following_mouse = false
		#collision_shape.set_deferred("disabled", false)
		if tween_handle and tween_handle.is_running():
			tween_handle.kill()
		tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_handle.tween_property(item_icon, "rotation", 0.0, 0.3)

func set_empty() -> void:
	item_icon.texture_normal = BLANK_CARD
	item_word.text = ""
	stack.text = ""

## Receives last item drop and instances a card into user's inventory
func add_item(item_data: Dictionary) -> void: ## TODO: Not just card items
	unique_item_data = item_data
	item_icon.texture_normal = FRONT_CARD
	item_word.text = unique_item_data["bingo_word"]
	var rarity: String = unique_item_data["item_rarity"]
	var value: float = unique_item_data["value"]
	tooltip.exchange_button.text = "$ Exchange: %0.1f pts" % value
	match rarity:
		"AMYRA":
			item_word.add_theme_color_override("default_color", Color.CYAN)
			_tooltip_text("AMYRA", value)
		"JOEY":
			item_word.add_theme_color_override("default_color", UserData.color(UserData.User.JOEY))
			_tooltip_text("JOEY", value)
		"KMOR":
			item_word.add_theme_color_override("default_color", UserData.color(UserData.User.KMOR))
			_tooltip_text("KMOR", value)
		"V":
			item_word.add_theme_color_override("default_color", UserData.color(UserData.User.V))
			_tooltip_text("V", value)
		"UNCOMMON":
			tooltip.exchange_button.text = "$ Exchange: %0.1f pts" % value
		"RARE":
			tooltip.exchange_button.text = "$ Exchange: %0.1f pts" % value
		"EPIC":
			tooltip.exchange_button.text = "$ Exchange: %0.1f pts" % value
		"LEGENDARY":
			tooltip.exchange_button.text = "$ Exchange: %0.1f pts" % value
	stack.text = "x %d" % unique_item_data["quantity"]

func _tooltip_text(username: String, value: float) -> void:
	if UserData.USERNAME != username:
		tooltip.exchange_button.text = "$ Exchange: 0.0 pts"
	else:
		tooltip.exchange_button.text = "$ Exchange: %0.1f tally" % value

func _on_item_icon_pressed() -> void:
	if Input.is_action_just_released("options"):
		mouse_in = true
		tooltip_ui()

func tooltip_ui() -> void:
	tooltip.visible = !tooltip.visible
	if !mouse_in:
		tooltip.visible = false
	tooltip.display_gift_options()
	tooltip.position = get_local_mouse_position()

func destroy() -> void:
	item_icon.use_parent_material = true
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()
	tween_destroy = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_destroy.tween_property(material, "shader_parameter/dissolve_value", 0.0, 2.0).from(1.0)
	#tween_destroy.parallel().tween_property(shadow, "self_modulate:a", 0.0, 1.0)

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

#func handle_shadow(_delta: float) -> void:
	# Y position is never changed.
	# Only x changes depending on how far we are from the center of the screen
	#var center: Vector2 = get_viewport_rect().size / 2.0
	#var distance: float = global_position.x - center.x
	
	#shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/(center.x)))

func _on_item_icon_gui_input(event: InputEvent) -> void:
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
	
	item_icon.material.set_shader_parameter("x_rot", rot_y)
	item_icon.material.set_shader_parameter("y_rot", rot_x)

func _on_item_icon_mouse_entered() -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(item_icon, "scale", Vector2(1.2, 1.2), 0.5)

func _on_item_icon_mouse_exited() -> void:
	# Reset rotation
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(item_icon.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(item_icon.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(item_icon, "scale", Vector2.ONE, 0.55)
