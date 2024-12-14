extends RigidBody3D
class_name RigidDisk

signal picked_up

var item_type: CONSTANTS.DISK_TYPE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pick_up() -> void:
	picked_up.emit()

func set_type(incoming_type: CONSTANTS.DISK_TYPE) -> void:
	item_type = incoming_type

func get_item_type() -> CONSTANTS.DISK_TYPE:
	return item_type
