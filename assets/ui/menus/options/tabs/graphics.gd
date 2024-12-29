extends OptionTab

signal value_updated(data_type: UIData.TYPE, value_name: String, value: Object)

# TODO Sort by logically used vs just updated UI varaiables
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

@export var process_delay_frame_count: int
var default_graphic_column_count: int
var frame_count: int
var dropdown_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_graphic_column_count = graphics_columns.get_child_count()
	font_update_list = [
		motion_blur_check,
		bloom_check,
		performance_display_check,
		resolution_label,
		resolution_select,
		display_type_label,
		display_type_select,
		monitor_choice_label,
		monitor_choice_select,
		frame_rate_label,
		frame_rate_select
	]
	xy_scale_update_list = [
		bloom_check,
		performance_display_check,
		motion_blur_check
	]
	initialize_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		frame_count += delta
		frame_count = min(process_delay_frame_count, frame_count)
		if frame_count % process_delay_frame_count == 0:
			_handle_resize()
			frame_count = 0

func initialize_ui() -> void:
	performance_display_check.button_pressed = GlobalSettings.DISPLAY.get(CONSTANTS.PERFORMANCE, GlobalSettings.DISPLAY_DEFAULTS.PERFORMANCE)
	super()

func _on_performance_display_check_toggled(toggled_on: bool) -> void:
	value_updated.emit(UIData.TYPE.DISPLAY, CONSTANTS.PERFORMANCE, toggled_on)

# TODO See to that this is called from delayed processing wherever it ends up
func _update_contents() -> void:
	# Update dropdown setting value
	var temp_index: int = display_type_select.get_item_index(get_window().mode)
	if temp_index != dropdown_index:
		dropdown_index = temp_index
		display_type_select.select(dropdown_index)

func _handle_resize_request(selected_index: int) -> void:
	var selected_window_type: int = display_type_select.get_item_id(selected_index)
	get_window().mode = selected_window_type
