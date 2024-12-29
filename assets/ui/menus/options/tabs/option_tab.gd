extends Control
class_name OptionTab

var font_update_list: Array[Control]
var y_scale_update_list: Array[Control]
var xy_scale_update_list: Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize_ui() -> void:
	_handle_resize()

## Resize UI objects
func _handle_resize(display_size: DisplaySize.SIZE = DisplaySize.SIZE.UNKNOWN) -> void:
	var window_size: DisplaySize.SIZE
	if display_size == DisplaySize.SIZE.UNKNOWN:
		window_size = DisplaySize.determine_display_size(get_viewport().get_visible_rect().size)
	else:
		window_size = display_size
	handle_font_resize(window_size)
	handle_icon_resize(window_size)

func handle_font_resize(display_size: DisplaySize.SIZE) -> void:
	var font_size: int = DisplaySize.FONT_MATRIX.get(display_size)
	for update_control in font_update_list:
		if update_control != null:
			update_control.add_theme_font_size_override(CONSTANTS.FONT_SIZE, font_size)

func handle_icon_resize(display_size: DisplaySize.SIZE) -> void:
	# ControlList rescaling
	var icon_scale: float = DisplaySize.ICON_SCALE_MATRIX.get(display_size)
	# Slider/checkbox rescaling
	var menu_item_scale: float = DisplaySize.MENU_SCALE_MATRIX.get(display_size)
	for xy_rescale in xy_scale_update_list:
		xy_rescale.scale.y = menu_item_scale
		xy_rescale.scale.x = menu_item_scale

func _reset_variables() -> void:
	pass
