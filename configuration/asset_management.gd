extends Node

class_name ASSET_MANAGEMENT 

const DISK = {
	"SCENE": "res://assets/items/ChuckDisk.tscn",
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
