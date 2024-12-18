extends Node3D
class_name HoleNode

@export var hole_data: HoleNodeData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Method for handling update state requests in General group
func _update_state() -> void:
	# TODO update all the hole data based off the hole_number stored in HoleData
	# TODO Should join a group for the hole number
	# TODO Should do regex group name check to see if it belongs to a tee-box group
	#		if doesn't should add itself to the teebox group associated with its set hole
	#			if can't find the group log warning saying teebox group for hole number doesn't exist
	var hole
	pass

func _pick_up() -> void:
	# TODO Log that Hole node is being picked up
	pass
