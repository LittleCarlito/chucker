extends Control
class_name OptionsMenu

const _UPDATE_CONTROL_LOG: String = "Updating control \"%s\" to input \"%s\""
const _SELECT_ERROR_LOG: String = "Incorrect number of items selected to change control input; \"%s\" items selected"
const _UNBOUND_INPUT_LOG: String = "\"%s\" is not bound to an input"
const _UNBIND_LOG: String = "Input \"%s\" key has been rebound"
const _CONTROL_REMAPPED_LOG: String = "Control \"%s\" has been remapped from \"%s\" to \"%s\""
const _NO_KEYCODE_ICON_STRING: String = "Path \"%s\" could not be mapped back to a keycode; Not persisting input change"
const _MISSING_CONSTANT_LOG: String = "No constant could be found for input \"%s\"; Returning \"%s\""

@export var fov_slider: HSlider
@export var fov_value: Label
@export var horizontal_aim_sensitivity_slider: HSlider
@export var horizontal_aim_sensitivity_value: Label
@export var vertical_aim_sensitivity_slider: HSlider
@export var vertical_aim_sensitivity_value: Label
@export var horizontal_look_sensitivity_slider: HSlider
@export var horizontal_look_sensitivity_value: Label
@export var vertical_look_sensitivity_slider: HSlider
@export var vertical_look_sensitivity_value: Label
@export var v_inversion_toggle: CheckButton
@export var h_inversion_toggle: CheckButton
@export var motion_blur_check: CheckBox
@export var bloom_check: CheckBox
@export var performance_display_check: CheckBox
@export var control_select_menu: ControlSelectMenu
@export var control_list: ItemList
@export var option_tab_container: TabContainer

enum SETTING_TABS {GENERAL, CONTROLS, GRAPHICS}
var camera_settings: Dictionary
var control_settings: Dictionary
var display_settings: Dictionary
var save_settings_dictionary: Dictionary

signal close_menu
signal back_menu
signal save_settings(updated_settings)
signal load_settings
signal apply_settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_ui()

func initialize_ui() -> void:
	control_select_menu.visible = false
	load_settings.emit()
	fov_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.PLAYER_FOV, GlobalSettings.CAMERA_DEFAULTS.PLAYER_FOV)
	fov_value.text = str(fov_slider.value)
	horizontal_aim_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_AIM_SENSITIVITY)
	horizontal_aim_sensitivity_value.text = str(horizontal_aim_sensitivity_slider.value)
	vertical_aim_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_AIM_SENSITIVITY)
	vertical_aim_sensitivity_value.text = str(vertical_aim_sensitivity_slider.value)
	horizontal_look_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
	horizontal_look_sensitivity_value.text = str(horizontal_look_sensitivity_slider.value)
	vertical_look_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_LOOK_SENSITIVITY)
	vertical_look_sensitivity_value.text = str(vertical_look_sensitivity_slider.value)
	v_inversion_toggle.button_pressed = GlobalSettings.CAMERA.get(CONSTANTS.INVERT_VERTICAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_VERTICAL)
	h_inversion_toggle.button_pressed = GlobalSettings.CAMERA.get(CONSTANTS.INVERT_HORIZONTAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_HORIZONTAL)
	performance_display_check.button_pressed = GlobalSettings.DISPLAY.get(CONSTANTS.PERFORMANCE, GlobalSettings.DISPLAY_DEFAULTS.PERFORMANCE)
	# Load in icons for set controls
	for i in control_list.item_count:
		var constant_name: String = _get_constant_name(control_list.get_item_text(i))
		var mapped_input: InputEvent = _get_constant_value(constant_name)
		var mapped_texture: Texture2D = InputSprite.get_sprite(mapped_input)
		control_list.set_item_icon(i, mapped_texture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.PAUSE) and self.visible:
		_on_back_menu()

func _on_close_menu() -> void:
	close_menu.emit()
	_reset_variables(SETTING_TABS.GENERAL)
	initialize_ui()

func _on_back_menu() -> void:
	back_menu.emit()
	_reset_variables(SETTING_TABS.GENERAL)
	initialize_ui()

func _on_save_menu() -> void:
	_save_controls()
	if not control_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Controls] = control_settings
	if not camera_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Camera] = camera_settings
	if not display_settings.is_empty():
		save_settings_dictionary[CONSTANTS.Display] = display_settings
	# Always emit saveSettings even if empty; Returns to defaults then
	save_settings.emit(save_settings_dictionary)
	apply_settings.emit()
	_reset_variables(option_tab_container.current_tab)

# Compares control_list items to set controls and saves the updated controls to ControlSetting
func _save_controls() -> void:
	for control_list_index in control_list.item_count:
		var constant_name: String = _get_constant_name(control_list.get_item_text(control_list_index))
		var constant_value: InputEvent = _get_default_value(constant_name)
		var constant_icon_path: String = InputSprite.get_sprite(constant_value).resource_path
		var icon_path: String = control_list.get_item_icon(control_list_index).resource_path
		if constant_icon_path != icon_path:
			var mapped_keycode: int = InputSprite.INPUT_ICONS.find_key(icon_path)
			if mapped_keycode != null:
				var mapped_event: InputEvent = InputEventLibrary.convert_keycode_to_input_event(mapped_keycode)
				var control_setting: ControlSetting = InputEventLibrary.convert_event_to_control_setting(mapped_event)
				var control_dictionary: Dictionary = InputEventLibrary.convert_controlsetting_to_dictionary(control_setting)
				control_settings[constant_name] = control_dictionary
				Logger.debug(_CONTROL_REMAPPED_LOG, [constant_name, constant_value.as_text(), control_setting.input_description], self)
			else:
				Logger.error(_NO_KEYCODE_ICON_STRING, [icon_path], self)


func _reset_variables(active_tab: int) -> void:
	save_settings_dictionary.clear()
	control_settings.clear()
	camera_settings.clear()
	display_settings.clear()
	control_list.deselect_all()
	option_tab_container.current_tab = active_tab
	

func _on_fov_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		camera_settings[CONSTANTS.PLAYER_FOV] = fov_slider.value

func _on_fov_slider_value_changed(value: float) -> void:
	fov_value.text = str(value)

func _on_v_inversion_toggle_toggled(toggled_on: bool) -> void:
	camera_settings[CONSTANTS.INVERT_VERTICAL] = toggled_on

func _on_h_inversion_toggle_toggled(toggled_on: bool) -> void:
	camera_settings[CONSTANTS.INVERT_HORIZONTAL] = toggled_on

func _on_performance_display_check_toggled(toggled_on: bool) -> void:
	display_settings[CONSTANTS.PERFORMANCE] = toggled_on

func _on_vertical_aim_sensitivity_slider_value_changed(value: float) -> void:
	vertical_aim_sensitivity_value.text = str(value)

func _on_vertical_aim_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		camera_settings[CONSTANTS.VERTICAL_AIM_SENSITIVITY] = vertical_aim_sensitivity_slider.value

func _on_horizontal_aim_sensitivity_slider_value_changed(value: float) -> void:
	horizontal_aim_sensitivity_value.text = str(value)

func _on_horizontal_aim_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		camera_settings[CONSTANTS.HORIZONTAL_AIM_SENSITIVITY] = horizontal_aim_sensitivity_slider.value

func _on_vertical_look_sensitivity_slider_value_changed(value: float) -> void:
	vertical_look_sensitivity_value.text = str(value)

func _on_vertical_look_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		camera_settings[CONSTANTS.VERTICAL_LOOK_SENSITIVITY] = vertical_look_sensitivity_slider.value

func _on_horizontal_look_sensitivity_slider_value_changed(value: float) -> void:
	horizontal_look_sensitivity_value.text = str(value)

func _on_horizontal_look_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		camera_settings[CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY] = horizontal_look_sensitivity_slider.value

func _open_control_select_menu(index: int, _click_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		control_select_menu.open_menu(control_list.get_item_text(index))
		process_mode = Node.PROCESS_MODE_DISABLED

func _control_select_closed() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _control_select_set(control_to_update: String, selected_input: ControlSetting) -> void:
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	Logger.debug(_UPDATE_CONTROL_LOG, [control_to_update, selected_input.input_description], self)
	var new_texture: Texture2D = load(InputSprite.INPUT_ICONS.get(selected_input.keycode, InputSprite.UNKNOWN_PATH))
	if new_texture != InputSprite.UNKNOWN_TEXTURE:
		var selected_icons: PackedInt32Array = control_list.get_selected_items()
		if selected_icons.size() == 1:
			_unbind_input(selected_input)
			_update_selected_icons(new_texture)
		else:
			Logger.error(_SELECT_ERROR_LOG, [str(selected_icons.size())], self)

# Updates selected icons in control_list to the passed in texture
func _update_selected_icons(new_icon: Texture2D) -> void:
	var selected_icons: PackedInt32Array = control_list.get_selected_items()
	for i in selected_icons.size():
		control_list.set_item_icon(selected_icons[i], new_icon)

# Unbinds the control with the matching keycode
func _unbind_input(selected_input: ControlSetting) -> void:
	# Check control list for matching items and unbind
	var incoming_input_path: String = InputSprite.INPUT_ICONS.get(selected_input.keycode)
	for control_list_index in control_list.item_count:
		var icon_path: String = control_list.get_item_icon(control_list_index).resource_path
		if icon_path == incoming_input_path:
			var input_description: String = control_list.get_item_text(control_list_index)
			Logger.debug(_UNBIND_LOG, [input_description], self)
			_assign_blank_keycap(control_list_index)

# Applys blank keycap texture to the passed in index of control_list
func _assign_blank_keycap(index: int) -> void:
	control_list.set_item_icon(index, InputSprite.UNKNOWN_TEXTURE)

# Converts the itemText to its assoicated GLOBAL_SETTINGS input name
func _get_constant_name(item_text: String) -> String:
	var constant_value: String = CONSTANTS.INPUT_LABEL.get(item_text, "")
	if constant_value == "":
		Logger.error(_MISSING_CONSTANT_LOG, [item_text, constant_value], self)
	return constant_value

# Checks control dictionaries for stored value of constantName
# If not found returns UNKNOWN_KEY InputEvent
func _get_constant_value(constant_name: String) -> InputEvent:
	# Check GlobalSettings for control constant with matching name
	var mapped_value: InputEvent = GlobalSettings.CONTROLS.get(constant_name, InputEventLibrary.UNKNOWN_KEY)
	if mapped_value == InputEventLibrary.UNKNOWN_KEY:
		# Log key is not bound and return UKNOWN value
		Logger.debug(_UNBOUND_INPUT_LOG, [constant_name], self)
	return mapped_value

# Checks default control dictionaries for stored value of constantName
# If not found returns UNKNOWN_KEY InputEvent
func _get_default_value(constant_name: String) -> InputEvent:
	# Check GlobalSettings for control constant with matching name
	var mapped_value: InputEvent = GlobalSettings.CONTROL_DEFAULTS.get(constant_name, InputEventLibrary.UNKNOWN_KEY)
	if mapped_value == InputEventLibrary.UNKNOWN_KEY:
		# Log key is not bound and return UKNOWN value
		Logger.debug(_UNBOUND_INPUT_LOG, [constant_name], self)
	return mapped_value

# Returns the index in control_list for the provided GLOBAL_SETTINGS name
# If not found returns INT32_MAX
func _get_control_index(constant_name: String) -> int:
	var constant_item_text: String = CONSTANTS.INPUT_LABEL.find_key(constant_name)
	for control_setting in control_list.item_count:
		var item_text: String = control_list.get_item_text(control_setting)
		if item_text == constant_item_text:
			return control_setting
	return CONSTANTS.INT32_MAX
