extends OptionTab
class_name ControlsTab

signal value_selected(selected_item: String)

const _UNBOUND_INPUT_LOG: String = "\"%s\" is not bound to an input"
const _MISSING_CONSTANT_LOG: String = "No constant could be found for input \"%s\"; Returning \"%s\""
const _CONTROL_REMAPPED_LOG: String = "Control \"%s\" has been remapped from \"%s\" to \"%s\""
const _NO_KEYCODE_ICON_STRING: String = "Path \"%s\" could not be mapped back to a keycode; Not persisting input change"
const _UPDATE_CONTROL_LOG: String = "Updating control \"%s\" to input \"%s\""
const _UNBIND_LOG: String = "Input \"%s\" key has been rebound"
const _SELECT_ERROR_LOG: String = "Incorrect number of items selected to change control input; \"%s\" items selected"

@export var control_list: ItemList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	font_update_list = [
		control_list
	]
	initialize_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func initialize_ui() -> void:
	# Load in icons for set controls
	for i in control_list.item_count:
		var constant_name: String = _get_constant_name(control_list.get_item_text(i))
		var mapped_input: InputEvent = _get_constant_value(constant_name)
		var mapped_texture: Texture2D = InputSprite.get_sprite(mapped_input)
		control_list.set_item_icon(i, mapped_texture)
	super()

## What to do when user selects one of the control items
func _open_control_select_menu(index: int, _click_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		value_selected.emit(control_list.get_item_text(index))

## Sets ControlList item to desired control value
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

 ## Unbinds the control with the matching keycode
func _unbind_input(selected_input: ControlSetting) -> void:
	# Check control list for matching items and unbind
	var incoming_input_path: String = InputSprite.INPUT_ICONS.get(selected_input.keycode)
	for control_list_index in control_list.item_count:
		var icon_path: String = control_list.get_item_icon(control_list_index).resource_path
		if icon_path == incoming_input_path:
			var input_description: String = control_list.get_item_text(control_list_index)
			Logger.debug(_UNBIND_LOG, [input_description], self)
			_assign_blank_keycap(control_list_index)

## Updates selected icons in control_list to the passed in texture
func _update_selected_icons(new_icon: Texture2D) -> void:
	var selected_icons: PackedInt32Array = control_list.get_selected_items()
	for i in selected_icons.size():
		control_list.set_item_icon(selected_icons[i], new_icon)

## Applys blank keycap texture to the passed in index of control_list
func _assign_blank_keycap(index: int) -> void:
	control_list.set_item_icon(index, InputSprite.UNKNOWN_TEXTURE)

## Compares control_list items to set controls and saves the updated controls to ControlSetting
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
				var new_entry: Dictionary = {constant_name: control_dictionary}
				value_updated.emit(UIData.TYPE.CONTROL, new_entry)
				Logger.debug(_CONTROL_REMAPPED_LOG, [constant_name, constant_value.as_text(), control_setting.input_description], self)
			else:
				Logger.error(_NO_KEYCODE_ICON_STRING, [icon_path], self)

## Returns the index in control_list for the provided GLOBAL_SETTINGS name
## If not found returns INT32_MAX
func _get_control_index(constant_name: String) -> int:
	var constant_item_text: String = CONSTANTS.INPUT_LABEL.find_key(constant_name)
	for control_setting in control_list.item_count:
		var item_text: String = control_list.get_item_text(control_setting)
		if item_text == constant_item_text:
			return control_setting
	return CONSTANTS.INT32_MAX

## Checks default control dictionaries for stored value of constantName
## If not found returns UNKNOWN_KEY InputEvent
func _get_default_value(constant_name: String) -> InputEvent:
	# Check GlobalSettings for control constant with matching name
	var mapped_value: InputEvent = GlobalSettings.CONTROL_DEFAULTS.get(constant_name, InputEventLibrary.UNKNOWN_KEY)
	if mapped_value == InputEventLibrary.UNKNOWN_KEY:
		# Log key is not bound and return UKNOWN value
		Logger.debug(_UNBOUND_INPUT_LOG, [constant_name], self)
	return mapped_value

## Converts the itemText to its assoicated GLOBAL_SETTINGS input name
func _get_constant_name(item_text: String) -> String:
	var constant_value: String = CONSTANTS.INPUT_LABEL.get(item_text, "")
	if constant_value == "":
		Logger.warn(_MISSING_CONSTANT_LOG, [item_text, constant_value], self)
	return constant_value

## Checks control dictionaries for stored value of constantName
## If not found returns UNKNOWN_KEY InputEvent
func _get_constant_value(constant_name: String) -> InputEvent:
	# Check GlobalSettings for control constant with matching name
	var mapped_value: InputEvent = GlobalSettings.CONTROLS.get(constant_name, InputEventLibrary.UNKNOWN_KEY)
	if mapped_value == InputEventLibrary.UNKNOWN_KEY:
		# Log key is not bound and return UKNOWN value
		Logger.debug(_UNBOUND_INPUT_LOG, [constant_name], self)
	return mapped_value

func _reset_variables() -> void:
	control_list.deselect_all()
