extends Node

const MISSING_CATEGORY_LOG: String = "Name \"%s\" could not be mapped to a category in method \"%s\"; Returning \"%s\""
const _EXTRACT_CATEGORY: String = "extract_category"
const _GET_CATEGORY: String = "get_category"
const _GET_DEFAULT_CATEGORY: String = "get_default_category"

const PLAYER: Dictionary = {
	"RUN_SPEED": 5.0,
	"SPRINT_SPEED": 4.0,
	"JUMP_FORCE": 4.5, 
	"MAX_LAUNCH_ROTATION": 67,
	"MIN_LAUNCH_ROTATION": -25
}

const DISK: Dictionary = {
	"LAUNCH_SPEED": 10,
	"MAX_HOLD": 2,
	"HOLD_MULTIPLIER": 1.5,
	"GRAVITY_MULTIPLIER": .009,
	"MAX_PULL": 200,
	"MIN_PULL": 15,
	"MAX_OFFSET": 400,
	"ROTATE_ADJUST": .1,
	"MAX_SPEED_REDUCE": .75
}

const CAMERA_DEFAULTS: Dictionary = {
	"PAN_SPEED": .15,
	"ROTATE_SPEED": 4,
	"IDLE_ROTATE_SPEED": 25.0,
	"MIN_HEIGHT": 4,
	"SHOT_WATCH_TIME": 5,
	CONSTANTS.MAX_HORIZONTAL_ROTATION: 1,
	CONSTANTS.MIN_HORIZONTAL_ROTATION: -1,
	CONSTANTS.MAX_VERTICAL_ROTATION: .15,
	CONSTANTS.MIN_VERTICAL_ROTATION: -.85,
	CONSTANTS.FOV: 90,
	CONSTANTS.IN_ADJUST: 20,
	CONSTANTS.OUT_ADJUST: 5,
	CONSTANTS.HORIZONTAL_AIM_SENSITIVITY: .3,
	CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY: 1.5,
	CONSTANTS.VERTICAL_AIM_SENSITIVITY: .3,
	CONSTANTS.VERTICAL_LOOK_SENSITIVITY: 1.5,
	CONSTANTS.INVERT_HORIZONTAL: false,
	CONSTANTS.INVERT_VERTICAL: false
}
static var CAMERA = CAMERA_DEFAULTS.duplicate()

var CONTROL_DEFAULTS: Dictionary = {
	CONSTANTS.USER_INPUT.ROTATE_LEFT: InputEventLibrary.A_KEY,
	CONSTANTS.USER_INPUT.ROTATE_RIGHT: InputEventLibrary.D_KEY,
	CONSTANTS.USER_INPUT.FORWARD: InputEventLibrary.W_KEY,
	CONSTANTS.USER_INPUT.BACKWARD: InputEventLibrary.S_KEY,
	CONSTANTS.USER_INPUT.STRAFE_LEFT: InputEventLibrary.Q_KEY,
	CONSTANTS.USER_INPUT.STRAFE_RIGHT: InputEventLibrary.E_KEY,
	CONSTANTS.USER_INPUT.JUMP: InputEventLibrary.SPACE_KEY,
	CONSTANTS.USER_INPUT.CROUCH: InputEventLibrary.CTRL_KEY,
	CONSTANTS.USER_INPUT.SPRINT: InputEventLibrary.SHIFT_KEY,
	CONSTANTS.USER_INPUT.INTERACT: InputEventLibrary.F_KEY,
	CONSTANTS.USER_INPUT.SCORE: InputEventLibrary.TAB_KEY,
	CONSTANTS.USER_INPUT.PAUSE: InputEventLibrary.ESCAPE_KEY,
	CONSTANTS.USER_INPUT.DEBUG: InputEventLibrary.PAGEDOWN_KEY,
	CONSTANTS.USER_INPUT.PRIMARY: InputEventLibrary.LEFT_MOUSE_BUTTON,
	CONSTANTS.USER_INPUT.SECONDARY: InputEventLibrary.RIGHT_MOUSE_BUTTON,
	CONSTANTS.USER_INPUT.ROTATE_UP: InputEventLibrary.UP_MOUSE_BUTTON,
	CONSTANTS.USER_INPUT.ROTATE_DOWN: InputEventLibrary.DOWN_MOUSE_BUTTON
}
var CONTROLS: Dictionary = CONTROL_DEFAULTS.duplicate()

const DISPLAY_DEFAULTS: Dictionary = {
	CONSTANTS.PERFORMANCE: false
}
static var DISPLAY = DISPLAY_DEFAULTS.duplicate()

const COLOR: Dictionary = {
	"FORCE": Color.RED,
	"PATH": Color.BLUE
}

const DEFAULTS: Dictionary = {
	"COLOR": Color.CHARTREUSE,
	"ITEM": ItemData.TYPE.FORCE
}

const CONFIGURABLE_SETTINGS: Array[String] = [CONSTANTS.FOV, CONSTANTS.IN_ADJUST, CONSTANTS.OUT_ADJUST, CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, CONSTANTS.VERTICAL_AIM_SENSITIVITY, CONSTANTS.VERTICAL_LOOK_SENSITIVITY, CONSTANTS.INVERT_HORIZONTAL, CONSTANTS.INVERT_VERTICAL, CONSTANTS.PERFORMANCE, CONSTANTS.USER_INPUT.ROTATE_LEFT, CONSTANTS.USER_INPUT.ROTATE_RIGHT, CONSTANTS.USER_INPUT.FORWARD, CONSTANTS.USER_INPUT.BACKWARD, CONSTANTS.USER_INPUT.STRAFE_LEFT, CONSTANTS.USER_INPUT.STRAFE_RIGHT, CONSTANTS.USER_INPUT.JUMP, CONSTANTS.USER_INPUT.CROUCH, CONSTANTS.USER_INPUT.SPRINT, CONSTANTS.USER_INPUT.INTERACT, CONSTANTS.USER_INPUT.SCORE, CONSTANTS.USER_INPUT.PAUSE, CONSTANTS.USER_INPUT.DEBUG, CONSTANTS.USER_INPUT.PRIMARY, CONSTANTS.USER_INPUT.SECONDARY, CONSTANTS.USER_INPUT.ROTATE_UP, CONSTANTS.USER_INPUT.ROTATE_DOWN]

func extract_category(setting_name: String) -> String:
	var return_string: String
	if CAMERA.has(setting_name):
		return_string = CONSTANTS.Camera
	elif DISPLAY.has(setting_name):
		return_string = CONSTANTS.Display
	elif CONTROLS.has(setting_name):
		return_string = CONSTANTS.Controls
	else:
		return_string = CONSTANTS.Unknown
		Logger.error(MISSING_CATEGORY_LOG, [setting_name, _EXTRACT_CATEGORY, return_string], self)
	return return_string

func get_category(category_name: String) -> Dictionary:
	var return_dictionary: Dictionary
	match category_name:
		CONSTANTS.Camera:
			return_dictionary = CAMERA
		CONSTANTS.Controls:
			return_dictionary = CONTROLS
		CONSTANTS.Display:
			return_dictionary = DISPLAY
		_:
			return_dictionary = {}
			Logger.error(MISSING_CATEGORY_LOG, [category_name, _GET_CATEGORY, return_dictionary], self)
	return return_dictionary

func get_default_category(category_name: String) -> Dictionary:
	var return_dictionary: Dictionary
	match category_name:
		CONSTANTS.Camera:
			return_dictionary = CAMERA_DEFAULTS
		CONSTANTS.Controls:
			return_dictionary = CONTROL_DEFAULTS
		CONSTANTS.Display:
			return_dictionary = DISPLAY_DEFAULTS
		_:
			return_dictionary = {}
			Logger.error(MISSING_CATEGORY_LOG, [category_name, _GET_DEFAULT_CATEGORY, return_dictionary], self)
	return return_dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
