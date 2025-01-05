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
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func initialize_ui() -> void:
	# Load in icons for set controls
	for i in control_list.item_count:
		var constant_name: String = InputConfig.INPUT_LABEL.get(control_list.get_item_text(i))
		var mapped_texture: Texture2D = InputSprite.get_sprite(InputMap.action_get_events(constant_name)[0])
		control_list.set_item_icon(i, mapped_texture)

## What to do when user selects one of the control items
func _open_control_select_menu(index: int, _click_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		var constant_name: String = InputConfig.INPUT_LABEL.get(control_list.get_item_text(index))
		value_selected.emit(constant_name)

## Sets ControlList item to desired control value
func _control_select_set(control_to_update: String, selected_input: InputEvent, input_texture: Texture2D) -> void:
	_unbind_input(input_texture.resource_path)
	_update_selected_icons(input_texture)
	applied_changes[control_to_update] = selected_input

## Unbinds the control with the matching keycode
func _unbind_input(incoming_icon_path: String) -> void:
	# Check control list for matching items and unbind
	for control_list_index in control_list.item_count:
		var icon_path: String = control_list.get_item_icon(control_list_index).resource_path
		if icon_path == incoming_icon_path:
			var input_description: String = control_list.get_item_text(control_list_index)
			Logger.debug(_UNBIND_LOG, [input_description], self)
			_assign_blank_keycap(control_list_index)
	# Check applied_changes for matching items and unbind
	var applied_keys: Array = applied_changes.keys()
	for applied_key in applied_keys:
		var applied_input: InputEvent = applied_changes.get(applied_key) as InputEvent
		var applied_keycode: int = InputSprite.extract_keycode(applied_input)
		var applied_path: String = InputSprite.INPUT_ICONS[applied_keycode]
		if applied_path == incoming_icon_path:
			applied_changes.erase(applied_key)

## Updates selected icons in control_list to the passed in texture
func _update_selected_icons(new_icon: Texture2D) -> void:
	var selected_icons: PackedInt32Array = control_list.get_selected_items()
	for i in selected_icons.size():
		control_list.set_item_icon(selected_icons[i], new_icon)

## Applys blank keycap texture to the passed in index of control_list
func _assign_blank_keycap(index: int) -> void:
	var constant_name: String = InputConfig.INPUT_LABEL.get(control_list.get_item_text(index))
	applied_changes[constant_name] = InputConfig.get_unknown_key()
	control_list.set_item_icon(index, InputSprite.UNKNOWN_TEXTURE)

func _reset_variables() -> void:
	control_list.deselect_all()

func full_reset() -> void:
	_reset_variables()
	super()
