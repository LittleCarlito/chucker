extends Node

const NO_MATCH_FOUND_LOG: String = "Matching icon for input \"%s\" could not be found"
const _EXTRACT_KEYCODE: String = "extract_keycode"

const DISK = {
	"SCENE": "res://assets/items/ForceDisk.tscn",
	"PATH_SCENE": "res://assets/items/PathDisk.tscn"
}

const MESH = {
	"CHARGE_SCENE": "res://assets/items/ChargeDisk.tscn",
	"PULL_SCENE": "res://assets/items/PullDisk.tscn"
}

const CAMERA = {
	# This needs to match the camera node name in ChuckTee scene
	"TEE_CAMERA": "TeeboxCamera"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func extract_keycode(event: InputEvent) -> int:
	var return_value: int
	if event is InputEventMouseButton:
		return_value = event.button_index
	elif event is InputEventKey:
		return_value = event.physical_keycode
	else:
		Logger.error(CONSTANTS.UNSUPPORTED_TYPE_LOG, [_EXTRACT_KEYCODE, str(event)], self)
	return return_value
