extends Node
class_name GameConfig

const RUN_SPEED: String = "run_speed"
const SPRINT_SPEED: String = "sprint_speed"
const JUMP_FORCE: String = "jump_force"
const MAX_LAUNCH_ROTATION: String = "max_launch_rotation"
const MIN_LAUNCH_ROTATION: String = "min_launch_rotation"
const LAUNCH_SPEED: String = "launch_speed"
const MAX_HOLD: String = "max_hold"
const HOLD_MULTIPLIER: String = "hold_multiplier"
const GRAVITY_MULTIPLIER: String = "gravity_multiplier"
const MAX_PULL: String = "max_pull"
const MIN_PULL: String = "min_pull"
const MAX_OFFSET: String = "max_offset"
const ROTATE_ADJUST: String = "rotate_adjust"
const MAX_SPEED_REDUCE: String = "max_speed_reduce"
const FORCE_COLOR: String = "force"
const PATH_COLOR: String = "path"
const SCROLL_COLOR: String = "scroll"
const COLOR: String = "color"
const ITEM: String = "item"
const GROUP: String = "group"

const DEFAULTS: Dictionary = {
	# Player values
	RUN_SPEED: 5.0,
	SPRINT_SPEED: 4.0,
	JUMP_FORCE: 4.5, 
	MAX_LAUNCH_ROTATION: 67,
	MIN_LAUNCH_ROTATION: -25,
	# Disk values
	LAUNCH_SPEED: 10,
	MAX_HOLD: 2,
	HOLD_MULTIPLIER: 1.5,
	GRAVITY_MULTIPLIER: .009,
	MAX_PULL: 200,
	MIN_PULL: 15,
	MAX_OFFSET: 400,
	ROTATE_ADJUST: .1,
	MAX_SPEED_REDUCE: .75,
	ITEM: AssetData.TYPE.FORCE,
	GROUP: GroupData.ENVIRONMENT,
	# Color values
	FORCE_COLOR: Color.RED,
	PATH_COLOR: Color.BLUE,
	SCROLL_COLOR: Color(0.686, 0.608, 0.439, 0.624),
	COLOR: Color.CHARTREUSE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
