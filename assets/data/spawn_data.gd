extends LocalResource

class_name SpawnData

@export var asset_data: AssetData
@export var spawn_location: Vector3
var spawn_parent: Node3D

func _init(incoming_data: AssetData, incoming_location: Vector3, incoming_parent: Node3D = null) -> void:
	asset_data = incoming_data
	spawn_location = incoming_location
	if(incoming_parent != null):
		spawn_parent = incoming_parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
