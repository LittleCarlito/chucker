extends Node3D
class_name HoleNode

@export var hole_node_data: HoleNodeData
var asset_data: AssetData

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

func _increase_node_number(hole_number: int, incoming_node_number: int) -> void:
	if hole_node_data != null:
		if hole_node_data.hole_data.hole_number == hole_number and hole_node_data.node_number > incoming_node_number:
			hole_node_data.node_number = hole_node_data.node_number + 1
	else:
		var formatted_string: String = CONSTANTS.NOT_FOUND_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.FOR_METHOD_LOG
		Logger.error(formatted_string, [CONSTANTS.HOLE_NODE_DATA, CONSTANTS.INCREASE_NODE_NUMBER], self)

func _decrease_node_number(hole_number: int, incoming_node_number: int) -> void:
	if hole_node_data != null:
		if hole_node_data.hole_data.hole_number == hole_number and hole_node_data.node_number > incoming_node_number:
			hole_node_data.node_number = hole_node_data.node_number - 1
	else:
		var formatted_string: String = CONSTANTS.NOT_FOUND_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.FOR_METHOD_LOG
		Logger.error(formatted_string, [CONSTANTS.HOLE_NODE_DATA, CONSTANTS.DECREASE_NODE_NUMBER], self)

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data
