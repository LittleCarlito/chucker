extends Resource
class_name HoleData

@export var hole_number: int
var total_hole_distance: float
var node_count: int

# TODO Will need to add _local_to_scene call thing using shared method to make this data an instance in each node instead of a shared singleton
