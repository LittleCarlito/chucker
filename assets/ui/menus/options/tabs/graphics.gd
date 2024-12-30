extends OptionTab
class_name GraphicsTab

@export var motion_blur_check: CheckBox
@export var bloom_check: CheckBox
@export var performance_display_check: CheckBox
@export var resolution_label: Label
@export var resolution_select: OptionButton
@export var display_type_label: Label
@export var display_type_select: OptionButton
@export var monitor_choice_label: Label
@export var monitor_choice_select: OptionButton
@export var frame_rate_label: Label
@export var frame_rate_select: OptionButton
@export var graphics_columns: HBoxContainer
@export var graphics_rows: VBoxContainer

@export var process_delay_frame_count: int
var frame_count: int
var default_graphic_column_count: int
var dropdown_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO Get resolution game is being rendered at and set it in the dropdown
	var initial_render_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var initial_render_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	var render_string: String = "%d x %d" % [initial_render_width, initial_render_height]
	Logger.debug(render_string, [], self)
	default_graphic_column_count = graphics_columns.get_child_count()
	initialize_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		# Losing decimals here doesn't matter and int is needed for % usage
		@warning_ignore("narrowing_conversion")
		frame_count += max(delta, 1)
		frame_count = min(process_delay_frame_count, frame_count)
		if frame_count % process_delay_frame_count == 0:
			_update_contents()
			frame_count = 0

func initialize_ui() -> void:
	performance_display_check.button_pressed = GlobalSettings.DISPLAY.get(CONSTANTS.PERFORMANCE, GlobalSettings.DISPLAY_DEFAULTS.PERFORMANCE)

func _on_performance_display_check_toggled(toggled_on: bool) -> void:
	var new_entry: Dictionary = {CONSTANTS.PERFORMANCE: toggled_on}
	value_updated.emit(UIData.TYPE.DISPLAY, new_entry)

func _update_contents() -> void:
	var window_width: int = get_window().size.x
	var window_height: int = get_window().size.y
	var runtime_string: String = "%d x %d" % [window_width, window_height]
	Logger.debug(runtime_string, [], self)
	# Update dropdown setting value
	var temp_index: int = display_type_select.get_item_index(get_window().mode)
	if temp_index != dropdown_index:
		dropdown_index = temp_index
		display_type_select.select(dropdown_index)

func get_height() -> float:
	return graphics_rows.size.y

func _set_resolution() -> void:
	pass
