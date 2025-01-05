extends Node

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

# TODO USER_INPUT should be migrated to INPUT_LABEL and they should be renamed to INPUT_LIBRARY
#			Move all this to InputConfig
# Keys are how it is handled in code
# Values are how project settings handle those behaviors
const USER_INPUT: Dictionary = {
	"FORWARD": "move_forward",
	"BACKWARD": "move_backward",
	"ROTATE_LEFT": "rotate_left",
	"STRAFE_LEFT": "move_left",
	"ROTATE_RIGHT": "rotate_right",
	"STRAFE_RIGHT": "move_right",
	"ROTATE_UP": "rotate_up",
	"ROTATE_DOWN": "rotate_down",
	"JUMP": "move_jump",
	"CROUCH": "move_crouch",
	"SPRINT": "move_sprint",
	"INTERACT": "player_interact",
	"PRIMARY": "player_primary",
	"SECONDARY": "player_secondary",
	"SCORE": "menu_score",
	"PAUSE": "menu_pause",
	"DEBUG": "admin_debug"
}

# Keys are how we display input type on UI
# Values are how project settings handle those behaviors
const INPUT_LABEL: Dictionary = {
	# Menu labels
	"Scorecard": USER_INPUT.SCORE,
	"Pause": USER_INPUT.PAUSE,
	# Action labels
	"Primary Action": USER_INPUT.PRIMARY,
	"Secondary Action": USER_INPUT.SECONDARY,
	"Pick Up": USER_INPUT.INTERACT,
	# Rotate labels
	"Rotate Left": USER_INPUT.ROTATE_LEFT,
	"Rotate Right": USER_INPUT.ROTATE_RIGHT,
	"Rotate Up": USER_INPUT.ROTATE_UP,
	"Rotate Down": USER_INPUT.ROTATE_DOWN,
	# Control labels
	"Forward": USER_INPUT.FORWARD,
	"Backward": USER_INPUT.BACKWARD,
	"Strafe Left": USER_INPUT.STRAFE_LEFT,
	"Strafe Right": USER_INPUT.STRAFE_RIGHT,
	"Jump": USER_INPUT.JUMP, 
	"Crouch": USER_INPUT.CROUCH,
	"Sprint": USER_INPUT.SPRINT
}


func _ready() -> void:
	add_to_group(GroupData.CONFIG_HANDLER)
	call_deferred("reload_project_settings")

## Reloads Project input settings using GlobalSettings
func reload_project_settings() -> void:
	# Get user settings file
	var input_dictionary: Dictionary = UserSettingData.get_category(NAME)
	# Iterate through existing settings and apply controls
	if !input_dictionary.is_empty():
		var update_controls: Array = input_dictionary.keys()
		for update_control in update_controls:
			var bound_input: InputEvent = input_dictionary.get(update_control)
			InputMap.action_erase_events(update_control)
			InputMap.action_add_event(update_control, bound_input)
	else:
		Logger.debug(_NO_FILE_FOUND, [], self)

func get_unknown_key() -> InputEventKey:
	var unknown_key: InputEventKey = InputEventKey.new()
	unknown_key.physical_keycode = KEY_UNKNOWN
	return unknown_key
