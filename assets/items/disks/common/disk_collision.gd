extends CollisionShape3D
class_name DiskCollision

@export var collision_data: Array[CollisionData] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func store_collision(incoming_owner_rid: RID, incoming_collider_rid: RID, incoming_collision_location: Vector3, incoming_flight_data: FlightData = null, incoming_item_data: ItemData = null) -> void:
	# TODO Create CollisionData and store it in the array
	var new_collision_data: CollisionData = CollisionData.create_collision_data(incoming_owner_rid, incoming_collider_rid, incoming_collision_location, incoming_flight_data, incoming_item_data)
	collision_data.append(new_collision_data)

func get_collision_count() -> int:
	return collision_data.size()
