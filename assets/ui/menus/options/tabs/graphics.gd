extends OptionTab
class_name GraphicsTab

# TODO Add revert screen after clicking apply

const _UI_SCALE: String = "display/window/stretch/scale"
const _DISPLAY_NUMBER: String = "Display %d"
const _UNLIMITED: String = "Unlimited"

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
	_set_available_displays()
	_set_ui_scaling_value(true)
	# Load performance display value
	performance_display_check.button_pressed = _detect_fps_display()
	# Set Window mode if available
	var set_window_mode: Window.Mode = get_window().mode
	var mode_index: int = display_type_select.get_item_index(set_window_mode)
	display_type_select.select(mode_index)
	# Set FPS lock if available
	var set_fps_lock: int = _get_fps_limit_index()
	if set_fps_lock != NUMBERS.INT16_MAX:
		frame_rate_select.select(set_fps_lock)
	# Set display if available
	monitor_choice_select.select(_detect_current_display())

## Detects changes to the gamestate and updates UI elements accordingly
func _update_contents() -> void:
	_set_window_mode()
	_set_available_displays()
	_set_current_display()

func _on_performance_display_check_toggled(toggled_on: bool) -> void:
	var apply_callable: Callable = func(): applied_changes[DebugConfig.PERFORMANCE] = toggled_on
	intermediate_changes[DebugConfig.PERFORMANCE] = apply_callable

## Handles changes to the UI scaling dropdown
func _update_scaling(incoming_index: int) -> void:
	var selected_scale: float = ui_scaling_dropdown.get_item_text(incoming_index) as float
	var apply_callable: Callable = func(): 
		get_tree().root.set_content_scale_factor(selected_scale)
		applied_changes[DisplayConfig.UI_SCALE] = selected_scale
	intermediate_changes[DisplayConfig.UI_SCALE] = apply_callable

## Handles changes to the display type dropdown
func _update_window_type(incoming_index: int) -> void:
	var requested_mode: Window.Mode = display_type_select.get_item_id(incoming_index) as Window.Mode
	var apply_callable: Callable = func():
		get_window().set_mode(requested_mode)
		applied_changes[DisplayConfig.WINDOW_MODE] = requested_mode
		if requested_mode == Window.MODE_WINDOWED:
			applied_changes[DisplayConfig.WINDOW_BORDERLESS] = DisplayConfig.DEFAULTS.window_borderless
	intermediate_changes[DisplayConfig.WINDOW_MODE] = apply_callable

## Handles changes to the FPS lock dropdown
func _update_fps_lock(incoming_index: int) -> void:
	var frame_lock: int
	var selected_value: String = frame_rate_select.get_item_text(incoming_index)
	if selected_value == _UNLIMITED:
		frame_lock = 0
	else:
		frame_lock = selected_value as int
	var apply_callable: Callable = func():
		Engine.set_max_fps(frame_lock)
		applied_changes[ApplicationConfig.FPS_LOCK] = frame_lock
	intermediate_changes[ApplicationConfig.FPS_LOCK] = apply_callable

## Handles changes to the selected monitor dropdown and moves game window
func _move_window(display_id: int) -> void:
	var apply_callable: Callable = func():
		var current_window: Window = get_window()
		var previous_mode: Window.Mode = current_window.mode
		current_window.set_mode(Window.MODE_WINDOWED)
		DisplayServer.window_set_current_screen(display_id, current_window.get_window_id())
		current_window.set_mode(previous_mode)
		applied_changes[DisplayConfig.WINDOW_INITIAL_SCREEN] = display_id
		applied_changes[DisplayConfig.WINDOW_INITIAL_POSITION] = DisplayConfig.DEFAULTS.window_initial_position
	intermediate_changes[DisplayConfig.WINDOW_INITIAL_SCREEN] = apply_callable

## Detects the window mode and updates it if no conflicting setting found
func _set_window_mode() -> void:
	var temp_index: int = display_type_select.get_item_index(get_window().mode)
	var is_manually_set: bool = intermediate_changes.has(DisplayConfig.WINDOW_MODE)
	if temp_index != dropdown_index and !is_manually_set:
		dropdown_index = temp_index
		display_type_select.select(dropdown_index)
		var dropdown_value: Window.Mode = display_type_select.get_item_id(dropdown_index) as Window.Mode
		var apply_callable: Callable = func():
			applied_changes[DisplayConfig.WINDOW_MODE] = dropdown_value
			if dropdown_value == Window.MODE_WINDOWED:
				applied_changes[DisplayConfig.WINDOW_BORDERLESS] = DisplayConfig.DEFAULTS.window_borderless			
		detected_changes[DisplayConfig.WINDOW_MODE] = apply_callable

## Detects available displays and sets them as values in selection dropdown
func _set_available_displays() -> void:
	var display_count: int = DisplayServer.get_screen_count()
	var current_selection_count: int = monitor_choice_select.item_count
	var only_placeholder: bool = monitor_choice_select.item_count == 1 and (monitor_choice_select.get_item_text(0) == DefaultLibrary.PLACEHOLDER)
	if display_count != current_selection_count or only_placeholder:
		monitor_choice_select.clear()
		for i in display_count:
			var item_label: String = _DISPLAY_NUMBER % (i + 1)
			monitor_choice_select.add_item(item_label, i)

## Detects what display the window is on and sets it in the dropdown list
func _set_current_display() -> void:
	var current_index: int = _detect_current_display()
	var has_exising_change: bool = intermediate_changes.has(DisplayConfig.WINDOW_INITIAL_SCREEN)
	var currently_selected: int = monitor_choice_select.selected
	# If there is no explicitly set display
	if !has_exising_change:
		# if current set index isn't what window actually is
		if current_index != currently_selected:
			var apply_callable: Callable = func(): 
				applied_changes[DisplayConfig.WINDOW_INITIAL_SCREEN] = current_index
				if current_index != 0:
					applied_changes[DisplayConfig.WINDOW_INITIAL_POSITION] = DisplayConfig.DEFAULTS.window_initial_position
			detected_changes[DisplayConfig.WINDOW_INITIAL_SCREEN] = apply_callable
			monitor_choice_select.select(current_index)

## Detects what display the window is on and returns its index
func _detect_current_display() -> int:
	return DisplayServer.window_get_current_screen(get_window().get_window_id())

## Detects if fps is being displayed
func _detect_fps_display() -> bool:
	return ProjectSettings.has_setting(DebugConfig._DISPLAY_PERFORMANCE)

## Detects current FPS limit and gets associated dropdown index
## Returns INT16_MAX if no match is found
func _get_fps_limit_index() -> int:
	var match_index: int = NUMBERS.INT16_MAX
	var max_fps: int = Engine.max_fps
	for i in range(frame_rate_select.item_count):
		var dropdown_string: String = frame_rate_select.get_item_text(i)
		var dropdown_value: float
		if dropdown_string != _UNLIMITED:
			dropdown_value = dropdown_string as float
		else:
			dropdown_value = 0
		if max_fps == dropdown_value:
			match_index = i
			break
	if match_index == NUMBERS.INT16_MAX:
		const _NO_INDEX_MATCH: String = "No %s index could be matched to value \"%s\""
		Logger.debug(_NO_INDEX_MATCH, [ApplicationConfig.FPS_LOCK, str(max_fps)], self)
	return match_index

## Determines what the closest setting in the dropdown is to the project default scaling is
## Sets that value in the dropdown
func _set_ui_scaling_value(_ready_loadup: bool = false) -> void:
	var ui_scaling: float = ProjectSettings.get_setting(_UI_SCALE)
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
