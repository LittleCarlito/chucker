extends Area3D
class_name ChuckHole

@export var hole_node_data: HoleNodeData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # Replace with function body.

func _on_body_entered(_body: Node3D) -> void:
	queue_free()

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
