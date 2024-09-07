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
	"GRAVITY_MULTIPLIER": .009
}

const CAMERA = {
	"PAN_SPEED": .15,
	"ROTATE_SPEED": 4,
	"IDLE_ROTATE_SPEED": 25.0,
	"MIN_HEIGHT": 4,
	"SHOT_WATCH_TIME": 5,
	"FOV": 90,
	"IN_ADJUST": 20,
	"OUT_ADJUST": 5
}

const CONTROLS =  {
	"HORIZONTAL_SENSITIVITY": 1.5,
	"VERTICAL_SENSITIVITY": .5,
	"INVERT_HORIZONTAL": -1,
	"INVERT_VERTICAL": -1
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
