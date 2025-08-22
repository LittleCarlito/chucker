extends Node
class_name GameConfig

const NAME: String = "game"

const DEFAULTS: Dictionary = {
	# Player values
	"run_speed": 5.0,
	"sprint_multiplier": 2.0,
	"jump_force": 4.5, 
	"max_launch_rotation": 67,
	"min_launch_rotation": -25,
	"rotation_multiplier": 4,
	# Disk values
	"launch_speed": 10,
	"max_hold": 2,
	"hold_multiplier": 1.5,
	"gravity_multiplier": .009,
	"max_pull": 200,
	"min_pull": 15,
	"max_offset": 250,
	"rotate_adjust": .1,
	"max_speed_reduce": .75,
	"item": AssetData.TYPE.FORCE,
	"group": GroupData.ENVIRONMENT,
	# Color values
	"force_color": Color.RED,
	"path_color": Color.BLUE,
	"scroll_color": Color(0.686, 0.608, 0.439, 0.624),
	"color": Color.CHARTREUSE,
	# Location values
	"default_location": Vector3(0, 1, 0),
	"uknown_location": Vector3(NUMBERS.FLOAT16_MAX, NUMBERS.FLOAT16_MAX, NUMBERS.FLOAT16_MAX)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
