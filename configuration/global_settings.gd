extends Node

class_name GLOBAL_SETTINGS

const PLAYER = {
	"RUN_SPEED": 5.0,
	"JUMP_FORCE": 4.5
}

const DISK = {
	"LAUNCH_SPEED": 10,
	"EMPOWER_FACTOR": 20,
	"MAX_HOLD": 3
}

const CAMERA = {
	"PAN_SPEED": .15,
	"ROTATE_SPEED": 4
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
