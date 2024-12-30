extends Control
class_name OptionTab

const _OPTION_TAB: String = "OptionTab"
const _GET_HEIGHT: String = "get_height"
const _ALREADY_MODE: String = "Already in %s mode"
const _CLIPPING_MODE: String = "clipping_mode"
const _NORMAL_MODE: String = "Tab already in normal mode"

# Abstract class; Implementers use signal
@warning_ignore("unused_signal")
signal value_updated(data_type: UIData.TYPE, updated_entry: Dictionary)

@export var tab_backgroud: Panel
@export var tab_name: String

var font_update_list: Array[Control]
var y_scale_update_list: Array[Control]
var xy_scale_update_list: Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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
	# Slider/checkbox rescaling
	var menu_item_scale: float = DisplaySize.MENU_SCALE_MATRIX.get(display_size)
	for xy_rescale in xy_scale_update_list:
		xy_rescale.scale.y = menu_item_scale
		xy_rescale.scale.x = menu_item_scale

## Returns the height of the most packed object in the tab
## Returns 0 if not implemented (or needed)
func get_height() -> float:
	return 0

## Enables a clipping visual mode to indicate tab is aware it is clipping
func clipping_mode() -> void:
	if !is_clipping_mode():
		var background_tint: StyleBoxFlat = StyleBoxFlat.new()
		background_tint.bg_color = GlobalSettings.COLOR.SCROLL
		tab_backgroud.add_theme_stylebox_override("panel", background_tint)
	else:
		Logger.debug(_ALREADY_MODE, [_CLIPPING_MODE], self)

## Removes overrides applied and displays default tab mode
func normal_mode() -> void:
	if is_clipping_mode():
		tab_backgroud.remove_theme_stylebox_override("panel")
	else:
		Logger.debug(_NORMAL_MODE, [], self)

func is_clipping_mode() -> bool:
	return tab_backgroud.has_theme_stylebox_override("panel")
