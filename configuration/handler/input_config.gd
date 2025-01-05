extends Node

signal reload_values

const _NO_FILE_FOUND: String = "No user_settings file found; Using default controls"

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
var UNKNOWN_KEY: InputEventKey = InputEventKey.new()

func _ready() -> void:
	UNKNOWN_KEY.physical_keycode = KEY_UNKNOWN
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
