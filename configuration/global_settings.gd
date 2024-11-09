extends Node

class_name GLOBAL_SETTINGS

const PLAYER = {
	"RUN_SPEED": 5.0,
	"SPRINT_SPEED": 4.0,
	"JUMP_FORCE": 4.5, 
	"MAX_LAUNCH_ROTATION": 67,
	"MIN_LAUNCH_ROTATION": -25
}

const DISK = {
	"LAUNCH_SPEED": 10,
	"MAX_HOLD": 2,
	"HOLD_MULTIPLIER": 1.5,
	"GRAVITY_MULTIPLIER": .009,
	"MAX_PULL": 200,
	"MIN_PULL": 15,
	"MAX_OFFSET": 400
}

const CAMERA_DEFAULTS = {
	"PAN_SPEED": .15,
	"ROTATE_SPEED": 4,
	"IDLE_ROTATE_SPEED": 25.0,
	"MIN_HEIGHT": 4,
	"SHOT_WATCH_TIME": 5,
	CONSTANTS.FOV: 90,
	CONSTANTS.IN_ADJUST: 20,
	CONSTANTS.OUT_ADJUST: 5
}
static var CAMERA = CAMERA_DEFAULTS.duplicate()

const CONTROLS_DEFAULTS =  {
	CONSTANTS.HORIZONTAL_AIM_SENSITIVITY: 1.5,
	CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY: 1.5,
	CONSTANTS.VERTICAL_AIM_SENSITIVITY: .5,
	CONSTANTS.VERTICAL_LOOK_SENSITIVITY: .5,
	CONSTANTS.INVERT_HORIZONTAL: false,
	CONSTANTS.INVERT_VERTICAL: false
}
static var CONTROLS: Dictionary = CONTROLS_DEFAULTS.duplicate()

const DISPLAY_DEFAULTS = {
	CONSTANTS.PERFORMANCE: false
}
static var DISPLAY = DISPLAY_DEFAULTS.duplicate()

const MENU = {
	"SCORECARD": {
		"PLAYER_PIXEL_SIZE": .003,
		"TEEBOX_PIXEL_SIZE": .0023
	}
}

const COLOR = {
	"CHARGE": Color.RED,
	"PATH": Color.BLUE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
