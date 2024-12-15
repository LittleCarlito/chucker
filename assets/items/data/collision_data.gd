extends Resource
class_name CollisionData

var owner_rid: RID
var colliding_object_rid: RID
var collision_global_location: Vector3
var owner_flight_data: FlightData
var owner_item_data: ItemData

static func create_collision_data(incoming_rid: RID, incoming_colliding_rid: RID, incoming_global_location: Vector3, incoming_flight_data: FlightData = null, incoming_item_data: ItemData = null) -> CollisionData:
	var return_data: CollisionData = CollisionData.new()
	return_data.owner_rid = incoming_rid
	return_data.colliding_object_rid = incoming_colliding_rid
	return_data.collision_global_location = incoming_global_location
	if incoming_flight_data != null:
		return_data.owner_flight_data = incoming_flight_data
	if incoming_item_data != null:
		return_data.owner_item_data = incoming_item_data
	return return_data
