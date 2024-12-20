extends Resource
class_name HoleNodeData

const _HOLE_DATA_NOT_SET: String = "Hole data not set; Cannot %s"
const _GET_HOLE_NUMBER: String = "get_hole_number"

# TODO Need to add local_to_scene stuff so this isn't shared

# TODO Need to ensure only zero to positive values are set here
@export var node_number: int
# TODO use raycasting to see if there is an unobstructed view of hole and if so how far
#			If not set to inf
#@export var visible_distance_to_hole: float
var distance_to_next_node: float
var distance_to_previous_node: float
