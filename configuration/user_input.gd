extends Node

class_name USER_INPUT

# TODO Going from "move_forward" or "menu_score" to the proper CONSTANT_NAME from saved files isn't possible unless they're all in the same dictionary
#			Either do multileveled and have a complex recursive lookup
#			Or do single level; rename it to USER_INPUT and everything that can be input is first level with unique name

const MOVE: Dictionary  = {
	"FORWARD": "move_forward",
	"BACKWARD": "move_backward",
	"ROTATE_LEFT": "rotate_left",
	"STRAFE_LEFT": "move_left",
	"ROTATE_RIGHT": "rotate_right",
	"STRAFE_RIGHT": "move_right",
	"ROTATE_UP": "rotate_up",
	"ROTATE_DOWN": "rotate_down",
	"JUMP": "move_jump",
	"CROUCH": "move_crouch",
	"SPRINT": "move_sprint"
}

const ACTION: Dictionary  = {
	"INTERACT": "player_interact",
	"PRIMARY": "player_primary",
	"SECONDARY": "player_secondary"
}

const MENU: Dictionary  = {
	"SCORE": "menu_score",
	# TODO Refactor this to be menu_pause "PAUSE"
	"MAIN": "menu_main"
}

const ADMIN: Dictionary  = {
	"DEBUG": "admin_debug"
}

const INPUT_LABEL: Dictionary = {
	# Menu labels
	"Scorecard": self.MENU.SCORE,
	"Pause": self.MENU.MAIN,
	# Action labels
	"Primary Action": self.ACTION.PRIMARY,
	"Secondary Action": self.ACTION.SECONDARY,
	"Pick Up": self.ACTION.INTERACT,
	# Rotate labels
	"Rotate Left": self.MOVE.ROTATE_LEFT,
	"Rotate Right": self.MOVE.ROTATE_RIGHT,
	"Rotate Up": self.MOVE.ROTATE_UP,
	"Rotate Down": self.MOVE.ROTATE_DOWN,
	# Control labels
	"Forward": self.MOVE.FORWARD,
	"Backward": self.MOVE.BACKWARD,
	"Strafe Left": self.MOVE.STRAFE_LEFT,
	"Strafe Right": self.MOVE.STRAFE_RIGHT,
	"Jump": self.MOVE.JUMP, 
	"Crouch": self.MOVE.CROUCH,
	"Sprint": self.MOVE.SPRINT
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
