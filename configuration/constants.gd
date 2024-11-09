extends Node
class_name CONSTANTS

const Camera: String = "Camera"
const FOV: String = "FOV"
const IN_ADJUST: String = "IN_ADJUST"
const OUT_ADJUST: String = "OUT_ADJUST"

const Controls: String = "Controls"
const HORIZONTAL_AIM_SENSITIVITY: String = "HORIZONTAL_AIM_SENSITIVITY"
const HORIZONTAL_LOOK_SENSITIVITY: String = "HORIZONTAL_LOOK_SENSITIVITY"
const VERTICAL_AIM_SENSITIVITY: String = "VERTICAL_AIM_SENSITIVITY"
const VERTICAL_LOOK_SENSITIVITY: String = "VERTICAL_LOOK_SENSITIVITY"
const INVERT_HORIZONTAL: String = "INVERT_HORIZONTAL"
const INVERT_VERTICAL: String = "INVERT_VERTICAL"

const Display: String = "Display"
const PERFORMANCE: String = "PERFORMANCE"

const SETTING_LABELS: Array[String] = [CONSTANTS.Camera, CONSTANTS.Controls, CONSTANTS.Display]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
