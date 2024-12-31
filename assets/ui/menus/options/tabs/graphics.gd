extends OptionTab
class_name GraphicsTab

# TODO OOOOO
# TODO Values are saving just need to get them loading now
# TODO Delayed process changes should still result in signals
# TODO Save button shouldn't take you back to general tab
# TODO Make an Apply button for Graphics settings
#		Delay setting all the settings until Apply is selected
# TODO Load current Graphics values in and set them before visible so there isn't a delay
# TODO Make sure non-saved changes are reset when menu closes
# TODO Ensure settings are saved to saveSettings file
# TODO Ensure settings are persisted through sessions
# TODO Have dropdowns update when things like window size are changed BUT if the user sets the value in the dropdown it shoudlnt' be overriden
#		User should be allowed to keep their set setting and save it while expanding and shrinking window

const _DISPLAY_NUMBER: String = "Display %d"

@export var motion_blur_check: CheckBox
@export var bloom_check: CheckBox
@export var performance_display_check: CheckBox
@export var display_type_label: Label
@export var display_type_select: OptionButton
@export var monitor_choice_label: Label
@export var monitor_choice_select: OptionButton
@export var frame_rate_label: Label
@export var frame_rate_select: OptionButton
@export var graphics_columns: HBoxContainer
@export var graphics_rows: VBoxContainer
@export var ui_scaling_dropdown: OptionButton

@export var process_delay_frame_count: int
var frame_count: int
var default_graphic_column_count: int
var dropdown_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_graphic_column_count = graphics_columns.get_child_count()
	initialize_ui(true)

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

# TODO New values you are persisting need to be loaded in here for viewing
# TODO You need to be sure they are being saved to file
#			If a category doesn't exist you will have to create one
# TODO Make sure they are being loaded in to GlobalSettings at startup and on save
func initialize_ui(_ready_loadup: bool = false) -> void:
	performance_display_check.button_pressed = GlobalSettings.DISPLAY.get(CONSTANTS.PERFORMANCE, GlobalSettings.DISPLAY_DEFAULTS.PERFORMANCE)
	_set_available_displays()
	_set_ui_scaling_value(_ready_loadup)

## Detects changes to the gamestate and updates UI elements accordingly
func _update_contents() -> void:
	# Update dropdown setting value
	var temp_index: int = display_type_select.get_item_index(get_window().mode)
	if temp_index != dropdown_index:
		dropdown_index = temp_index
		display_type_select.select(dropdown_index)
		var new_entry: Dictionary = {CONSTANTS.WINDOW_MODE: dropdown_index}
		value_updated.emit(UIData.TYPE.DISPLAY, new_entry)
	_set_available_displays()
	_set_current_display()

func get_height() -> float:
	return graphics_rows.size.y

func _on_performance_display_check_toggled(toggled_on: bool) -> void:
	var new_entry: Dictionary = {CONSTANTS.PERFORMANCE: toggled_on}
	value_updated.emit(UIData.TYPE.DISPLAY, new_entry)

## Handles changes to the UI scaling dropdown
func _update_scaling(incoming_index: int) -> void:
	var selected_scale: float = ui_scaling_dropdown.get_item_text(incoming_index) as float
	var new_entry: Dictionary = {CONSTANTS.UI_SCALE: selected_scale}
	value_updated.emit(UIData.TYPE.DISPLAY, new_entry)
	# TODO Eventually save this for Apply
	get_tree().root.set_content_scale_factor(selected_scale)

## Handles changes to the display type dropdown
func _update_window_type(incoming_index: int) -> void:
	var requested_mode: Window.Mode = display_type_select.get_item_id(incoming_index) as Window.Mode
	var new_entry: Dictionary = {CONSTANTS.WINDOW_MODE: incoming_index}
	value_updated.emit(UIData.TYPE.DISPLAY, new_entry)
	# TODO Eventually save this for Apply
	get_window().set_mode(requested_mode)

## Handles changes to the FPS lock dropdown
func _update_fps_lock(incoming_index: int) -> void:
	var frame_lock: int
	var selected_value: String = frame_rate_select.get_item_text(incoming_index)
	if selected_value == CONSTANTS.UNLIMITED:
		frame_lock = 0
	else:
		frame_lock = selected_value as int
	var new_entry: Dictionary = {CONSTANTS.FPS_LOCK: frame_lock}
	value_updated.emit(UIData.TYPE.DISPLAY, new_entry)
	# TODO Eventually save this for Apply
	Engine.set_max_fps(frame_lock)

## Handles changes to the selected monitor dropdown and moves game window
func _move_window(display_id: int) -> void:
	var current_window: Window = get_window()
	var previous_mode: Window.Mode = current_window.mode
	var display_name: String = monitor_choice_select.get_item_text(display_id)
	var new_entry: Dictionary = {CONSTANTS.SET_DISPLAY: display_name}
	value_updated.emit(UIData.TYPE.DISPLAY, new_entry)
	# TODO Eventually save this for Apply
	current_window.set_mode(Window.MODE_WINDOWED)
	DisplayServer.window_set_current_screen(display_id, current_window.get_window_id())
	current_window.set_mode(previous_mode)

## Detects available displays and sets them as values in selection dropdown
func _set_available_displays() -> void:
	monitor_choice_select.clear()
	var display_count: int = DisplayServer.get_screen_count()
	for i in display_count:
		var item_label: String = _DISPLAY_NUMBER % (i + 1)
		monitor_choice_select.add_item(item_label, i)

## Detects what display the window is on and sets it in the dropdown list
func _set_current_display() -> void:
	var current_index: int = _detect_current_display()
	var display_name: String = monitor_choice_select.get_item_text(current_index)
	var new_entry: Dictionary = {CONSTANTS.SET_DISPLAY: display_name}
	value_updated.emit(UIData.TYPE.DISPLAY, new_entry)
	monitor_choice_select.select(current_index)

## Detects what display the window is on and returns its index
func _detect_current_display() -> int:
	return DisplayServer.window_get_current_screen(get_window().get_window_id())

## Determines what the closest setting in the dropdown is to the project default scaling is
## Sets that value in the dropdown
func _set_ui_scaling_value(_ready_loadup: bool = false) -> void:
	var ui_scaling: float = ProjectSettings.get_setting("display/window/stretch/scale")
	var match_found: bool = false
	for i in range(ui_scaling_dropdown.item_count):
		var scale_value: float = ui_scaling_dropdown.get_item_text(i) as float
		if scale_value == ui_scaling:
			ui_scaling_dropdown.select(i)
			match_found = true
	if not match_found:
		var new_index: int = ui_scaling_dropdown.item_count + 1
		ui_scaling_dropdown.add_item(str(ui_scaling), new_index)
		if not _ready_loadup:
			ui_scaling_dropdown.select(new_index)
