extends Node3D
class_name HoleNode

@export var hole_node_data: HoleNodeData
var asset_data: AssetData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _pick_up() -> void:
	# TODO Log that Hole node is being picked up
	pass

func _increase_node_number(hole_number: int, incoming_node_number: int) -> void:
	if hole_node_data != null:
		if hole_node_data.hole_data.hole_number == hole_number and hole_node_data.node_number > incoming_node_number:
			hole_node_data.node_number = hole_node_data.node_number + 1
	else:
		var formatted_string: String = Logger.NOT_FOUND_LOG + Logger.LOG_SEPARATOR + Logger.FOR_METHOD_LOG
		Logger.error(formatted_string, [Logger.HOLE_NODE_DATA, Logger.INCREASE_NODE_NUMBER], self)

func _decrease_node_number(hole_number: int, incoming_node_number: int) -> void:
	if hole_node_data != null:
		if hole_node_data.hole_data.hole_number == hole_number and hole_node_data.node_number > incoming_node_number:
			hole_node_data.node_number = hole_node_data.node_number - 1
	else:
		var formatted_string: String = Logger.NOT_FOUND_LOG + Logger.LOG_SEPARATOR + Logger.FOR_METHOD_LOG
		Logger.error(formatted_string, [Logger.HOLE_NODE_DATA, Logger.DECREASE_NODE_NUMBER], self)

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data

# TODO Don't think below is needed; TeeBox should have Array of all these objects and can update them in order to simplify flow
# TODO Implement to
#		Update distance to next node in the hole
#		Update distance to node previous in the hole to it
### Method for handling update state requests in General group
#func _update_state() -> void:
	#pass
