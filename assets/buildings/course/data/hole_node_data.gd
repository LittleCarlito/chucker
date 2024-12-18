extends Resource
class_name HoleNodeData

const _HOLE_DATA_NOT_SET: String = "Hole data not set; Cannot %s"
const _GET_HOLE_NUMBER: String = "get_hole_number"

# TODO Will need to add _local_to_scene call thing using shared method to make this data an instance in each node instead of a shared singleton
# TODO make sure all HoleNodeDatas refer to the same instance of HoleData and that it isn't recreated a bunch of times that all need to be updated
@export var hole_data: HoleData
@export var node_number: int
# TODO use raycasting to see if there is an unobstructed view of hole and if so how far
#			If not set to inf
#@export var visible_distance_to_hole: float
var distance_to_next_node: float
var distance_to_previous_node: float

func get_hole_number() -> int:
	var hole_number = 0
	if hole_data != null:
		hole_number = hole_data.hole_number
	else:
		var formattedString: String = _HOLE_DATA_NOT_SET + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_ZERO_LOG
		Logger.warn(formattedString, [_GET_HOLE_NUMBER], self)
	return hole_number
