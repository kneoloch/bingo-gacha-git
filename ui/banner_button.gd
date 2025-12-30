extends Button
class_name BannerButton

@export var banner_text: String
@onready var banners: Array = get_tree().get_nodes_in_group("banner")

func _ready() -> void:
	#self.custom_minimum_size = Vector2(0, 80)
	_show_banner()

func _on_mouse_entered() -> void:
	self.text = banner_text
	#self.custom_minimum_size = Vector2(200, 80)

func _on_mouse_exited() -> void:
	_show_banner()

func _on_pressed() -> void:
	GachaManager.selected_banner = self
	_show_banner()

func _show_banner() -> void:
	for i in banners:
		i.text = ""
		#self.custom_minimum_size = Vector2(0, 80)
	GachaManager.selected_banner.text = GachaManager.selected_banner.banner_text
	#GachaManager.selected_banner.custom_minimum_size = Vector2(200, 80)
