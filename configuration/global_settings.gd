extends Node

class_name GLOBAL_SETTINGS

const PLAYER = {
	"RUN_SPEED": 5.0,
	"JUMP_FORCE": 4.5, 
	"MAX_LAUNCH_ROTATION": 67,
	"MIN_LAUNCH_ROTATION": -25
}

const DISK = {
	"LAUNCH_SPEED": 10,
	"MAX_HOLD": 2,
	"HOLD_MULTIPLIER": 1.5,
	"GRAVITY_MULTIPLIER": .1
}

const CAMERA = {
	"PAN_SPEED": .15,
	"ROTATE_SPEED": 4,
	"MIN_HEIGHT": 1.5,
	"SHOT_WATCH_TIME": 2
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
