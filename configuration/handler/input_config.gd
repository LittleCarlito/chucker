extends Node

signal reload_values

const _MISSING_INPUT: String = "user_settings.cfg doesn't have \"%s\", \"%s\" category, key combination"
const _NO_FILE_FOUND: String = "No user_settings file found; Using default controls"
const _NO_MATCH_FOUND: String = "No input keycode match found for incoming input \"%s\""

const NAME: String = "input"
const ADMIN_DEBUG: String = "admin_debug"
const MENU_SCORE: String = "menu_score"
const MENU_PAUSE: String = "menu_pause"
const ROTATE_LEFT: String = "rotate_left"
const ROTATE_RIGHT: String = "rotate_right"
const ROTATE_UP: String = "rotate_up"
const ROTATE_DOWN: String = "rotate_down"
const MOVE_FORWARD: String = "move_forward"
const MOVE_BACKWARD: String = "move_backward"
const MOVE_LEFT: String = "move_left"
const MOVE_RIGHT: String = "move_right"
const MOVE_JUMP: String = "move_jump"
const PLAYER_INTERACT: String = "player_interact"
const PLAYER_PRIMARY: String = "player_primary"
const PLAYER_SECONDARY: String = "player_secondary"
const MOVE_CROUCH: String = "move_crouch"
const MOVE_SPRINT: String = "move_sprint"

const DEFAULTS: Dictionary = {
	ROTATE_LEFT: KEY_A,
	ROTATE_RIGHT: KEY_D,
	MOVE_FORWARD: KEY_W,
	MOVE_BACKWARD: KEY_S,
	MOVE_LEFT: KEY_Q,
	MOVE_RIGHT: KEY_E,
	MOVE_JUMP: KEY_SPACE,
	MOVE_CROUCH: KEY_CTRL,
	MOVE_SPRINT: KEY_SHIFT,
	PLAYER_INTERACT: KEY_F,
	MENU_SCORE: KEY_TAB,
	MENU_PAUSE: KEY_ESCAPE,
	ADMIN_DEBUG: KEY_PAGEDOWN,
	PLAYER_PRIMARY: MOUSE_BUTTON_LEFT,
	PLAYER_SECONDARY: MOUSE_BUTTON_RIGHT,
	ROTATE_UP: MOUSE_BUTTON_WHEEL_UP,
	ROTATE_DOWN: MOUSE_BUTTON_WHEEL_DOWN
}

const CONFIG_LIBRARY: Dictionary = {
	ROTATE_LEFT: ROTATE_LEFT,
	ROTATE_RIGHT: ROTATE_RIGHT,
	MOVE_FORWARD: MOVE_FORWARD,
	MOVE_BACKWARD: MOVE_BACKWARD,
	MOVE_LEFT: MOVE_LEFT,
	MOVE_RIGHT: MOVE_RIGHT,
	MOVE_JUMP: MOVE_JUMP,
	MOVE_CROUCH: MOVE_CROUCH,
	MOVE_SPRINT: MOVE_SPRINT,
	PLAYER_INTERACT: PLAYER_INTERACT,
	MENU_SCORE: MENU_SCORE,
	MENU_PAUSE: MENU_PAUSE,
	ADMIN_DEBUG: ADMIN_DEBUG,
	PLAYER_PRIMARY: PLAYER_PRIMARY,
	PLAYER_SECONDARY: PLAYER_SECONDARY,
	ROTATE_UP: ROTATE_UP,
	ROTATE_DOWN: ROTATE_DOWN
}

var _user_settings: ConfigFile

func _ready() -> void:
	add_to_group(CONSTANTS.CONFIG_HANDLER)
	reload_project_settings()

## Reloads Project input settings using GlobalSettings
func reload_project_settings() -> void:
	# Get user settings file
	_user_settings = ConfigFileHandler.get_user_setting_file()
	# Iterate through existing settings and apply controls
	if _user_settings.has_section(InputConfig.NAME):
		var update_controls: Array = _user_settings.get_section_keys(InputConfig.NAME)
		for update_control in update_controls:
			var bound_input: InputEvent = _user_settings.get_value(InputConfig.NAME, update_control)
			InputMap.action_erase_events(update_control)
			InputMap.action_add_event(update_control, bound_input)
		# TODO Need to tell ConfigHandlers to reload data
		reload_values.emit()
	else:
		Logger.debug(_NO_FILE_FOUND, [], self)

## Returns the mapped keycode for the given input
## If InputMap is returning null returns user_setting.cfg value; otherwise the default value
## Returns INT16_MAX if not match found
func get_mapped_keycode(incoming_input: String, surpress_logs: bool = false) -> int:
	var mapped_input_keycode: int = CONSTANTS.INT16_MAX
	var input_map_value: InputEvent
	if InputMap.has_action(incoming_input):
		input_map_value = InputMap.get(incoming_input)
		if input_map_value != null:
			mapped_input_keycode = InputSprite.extract_keycode(input_map_value)
		else:
			input_map_value = _get_user_mapped_input(incoming_input, surpress_logs)
			if input_map_value != null:
				mapped_input_keycode = InputSprite.extract_keycode(input_map_value)
			else:
				if DEFAULTS.has(incoming_input):
					mapped_input_keycode = DEFAULTS.get(incoming_input)
	else:
		input_map_value = _get_user_mapped_input(incoming_input, surpress_logs)
		if input_map_value != null:
			mapped_input_keycode = InputSprite.extract_keycode(input_map_value)
		else:
			if DEFAULTS.has(incoming_input):
					mapped_input_keycode = DEFAULTS.get(incoming_input)
	if mapped_input_keycode == CONSTANTS.INT16_MAX and !surpress_logs:
		var formatted_string: String = _NO_MATCH_FOUND + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_INT16_MAX
		Logger.debug(formatted_string, [incoming_input], self)
	return mapped_input_keycode

## Checks user_settings.cfg for incoming_input mapped value and returns keycode
## Returns null if no match found
func _get_user_mapped_input(incoming_input: String, surpress_logs: bool = false) -> InputEvent:
	var user_mapped_input: InputEvent
	if _user_settings.has_section_key(NAME, incoming_input):
		_user_settings.get_value(NAME, incoming_input)
	elif !surpress_logs:
		var formatted_string: String = _MISSING_INPUT + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
		Logger.debug(formatted_string, [NAME, incoming_input], self)
	return user_mapped_input
