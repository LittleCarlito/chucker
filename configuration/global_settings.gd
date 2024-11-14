extends Node

# TODO Switch from class to global singleton
class_name GLOBAL_SETTINGS

# TODO add typing to dictionaries

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
	"MAX_OFFSET": 400
}

# TODO Need to get all logic using changed dictionaries fixed
#		Contorl Setting will need to sort through multiple dictionaries to find what it wants now
#			Or maybe there is a way to make a ditionary reference for the location/input type of each control so it knows where to look immediately
#				A lookup table of sorts
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
	CONSTANTS.USER_INPUT.MAIN: InputEventLibrary.ESCAPE_KEY,
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
	"CHARGE": Color.RED,
	"PATH": Color.BLUE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
