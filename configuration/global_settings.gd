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
	"ROTATE_ADJUST": .1
}

const CAMERA_DEFAULTS: Dictionary = {
	"PAN_SPEED": .15,
	"ROTATE_SPEED": 4,
	"IDLE_ROTATE_SPEED": 25.0,
	"MIN_HEIGHT": 4,
	"SHOT_WATCH_TIME": 5,
	CONSTANTS.FOV: 90,
	CONSTANTS.IN_ADJUST: 20,
	CONSTANTS.OUT_ADJUST: 5,
	CONSTANTS.HORIZONTAL_AIM_SENSITIVITY: 1.5,
	CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY: 1.5,
	CONSTANTS.VERTICAL_AIM_SENSITIVITY: .5,
	CONSTANTS.VERTICAL_LOOK_SENSITIVITY: .5,
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

const CONFIGURABLE_SETTINGS: Array[String] = [CONSTANTS.FOV, CONSTANTS.IN_ADJUST, CONSTANTS.OUT_ADJUST, CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, CONSTANTS.VERTICAL_AIM_SENSITIVITY, CONSTANTS.VERTICAL_LOOK_SENSITIVITY, CONSTANTS.INVERT_HORIZONTAL, CONSTANTS.INVERT_VERTICAL, CONSTANTS.PERFORMANCE, CONSTANTS.USER_INPUT.ROTATE_LEFT, CONSTANTS.USER_INPUT.ROTATE_RIGHT, CONSTANTS.USER_INPUT.FORWARD, CONSTANTS.USER_INPUT.BACKWARD, CONSTANTS.USER_INPUT.STRAFE_LEFT, CONSTANTS.USER_INPUT.STRAFE_RIGHT, CONSTANTS.USER_INPUT.JUMP, CONSTANTS.USER_INPUT.CROUCH, CONSTANTS.USER_INPUT.SPRINT, CONSTANTS.USER_INPUT.INTERACT, CONSTANTS.USER_INPUT.SCORE, CONSTANTS.USER_INPUT.PAUSE, CONSTANTS.USER_INPUT.DEBUG, CONSTANTS.USER_INPUT.PRIMARY, CONSTANTS.USER_INPUT.SECONDARY, CONSTANTS.USER_INPUT.ROTATE_UP, CONSTANTS.USER_INPUT.ROTATE_DOWN]

func extract_category(settingName: String) -> String:
	var returnString: String
	if CAMERA.has(settingName):
		returnString = CONSTANTS.Camera
	elif DISPLAY.has(settingName):
		returnString = CONSTANTS.Display
	elif CONTROLS.has(settingName):
		returnString = CONSTANTS.Controls
	else:
		returnString = CONSTANTS.Unknown
		Logger.error(MISSING_CATEGORY_LOG, [settingName, _EXTRACT_CATEGORY, returnString], self)
	return returnString

func get_category(categoryName: String) -> Dictionary:
	var returnDictionary: Dictionary
	match categoryName:
		CONSTANTS.Camera:
			returnDictionary = self.CAMERA
		CONSTANTS.Controls:
			returnDictionary = self.CONTROLS
		CONSTANTS.Display:
			returnDictionary = self.DISPLAY
		_:
			returnDictionary = {}
			Logger.error(MISSING_CATEGORY_LOG, [categoryName, _GET_CATEGORY, returnDictionary], self)
	return returnDictionary

func get_default_category(categoryName: String) -> Dictionary:
	var returnDictionary: Dictionary
	match categoryName:
		CONSTANTS.Camera:
			returnDictionary = self.CAMERA_DEFAULTS
		CONSTANTS.Controls:
			returnDictionary = self.CONTROL_DEFAULTS
		CONSTANTS.Display:
			returnDictionary = self.DISPLAY_DEFAULTS
		_:
			returnDictionary = {}
			Logger.error(MISSING_CATEGORY_LOG, [categoryName, _GET_DEFAULT_CATEGORY, returnDictionary], self)
	return returnDictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
