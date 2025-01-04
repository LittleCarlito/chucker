extends Node

const MISSING_CATEGORY_LOG: String = "Name \"%s\" could not be mapped to a category in method \"%s\"; Returning \"%s\""
const _EXTRACT_CATEGORY: String = "extract_category"
const _GET_CATEGORY: String = "get_category"
const _GET_DEFAULT_CATEGORY: String = "get_default_category"

# TODO Need to move all this to appropriate existing locations

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

# TODO Refactor FORCE and PATH to use existing ENUMS
const COLOR: Dictionary = {
	"FORCE": Color.RED,
	"PATH": Color.BLUE,
	"SCROLL": Color(0.686, 0.608, 0.439, 0.624)
}

# General Default configs
# TODO Refactor these to be to an enum
const DEFAULTS: Dictionary = {
	"COLOR": Color.CHARTREUSE,
	"ITEM": AssetData.TYPE.FORCE,
	"GROUP": CONSTANTS.ENVIRONMENT
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
