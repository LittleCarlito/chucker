extends Resource
class_name ThrowableData

@export var item_data: ItemData
@export var flight_data: FlightData

# TODO Can't make signals in Resources; Should use groups instead
#			Have disk send signal or call method on all group members
#				Standard disk group behavior is to deactivate and queue_free
#				Standard PlayableCharacter is to enable movement and camera
signal lose_focus

static func create_throwable_data() -> ThrowableData:
	var new_throwable_data: ThrowableData = ThrowableData.new()
	var new_item_data: ItemData = ItemData.new()
	var new_flight_data: FlightData = FlightData.new()
	new_throwable_data.item_data = new_item_data
	new_throwable_data.flight_data = new_flight_data
	return new_throwable_data

func set_flight_data(incoming_speed: float, incoming_angle: float, incoming_path: Array[Vector3] = [], incoming_focus: bool = false) -> void:
	flight_data = FlightData.create_flight_data(incoming_speed, incoming_angle, incoming_path, incoming_focus)

func set_item_data(incoming_internal: ItemData.TYPE, incoming_create: ItemData.TYPE = ItemData.TYPE.UNKNOWN) -> void:
	item_data = ItemData.create_item_type(incoming_internal, incoming_create)
