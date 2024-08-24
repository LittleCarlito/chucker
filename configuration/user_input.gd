extends Node

class_name USER_INPUT

const MOVE = {
	"FORWARD": "move_forward",
	"BACKWARD": "move_backward",
	"LEFT": "move_left",
	"RIGHT": "move_right",
	"JUMP": "move_jump",
	"CROUCH": "move_crouch",
	"SPRINT": "move_sprint"
}

const ROTATE = {
	"LEFT": "rotate_left",
	"RIGHT": "rotate_right",
	"UP": "rotate_up",
	"DOWN": "rotate_down"
}

const ACTION = {
	"INTERACT": "player_interact",
	"PRIMARY": "player_primary",
	"SECONDARY": "player_secondary"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
