extends Node

# TODO Convert this file to a cfg or something

# TODO Get the rest of these to user_settings.cfg and a config handler

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
	"GROUP": GroupData.ENVIRONMENT
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
