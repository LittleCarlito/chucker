extends LocalResource
class_name FlightData

@export var flight_speed: float
@export var flight_angle: float
@export var flight_path: Array[Vector3]
@export var focus_flight: bool
@export var flight_ready: bool

static func create_flight_data(incoming_speed: float, incoming_angle: float, incoming_path: Array[Vector3] = [], incoming_focus: bool = false) -> FlightData:
	var return_data: FlightData = FlightData.new()
	return_data.flight_speed = incoming_speed
	return_data.flight_angle = incoming_angle
	return_data.flight_path = incoming_path
	return_data.focus_flight = incoming_focus
	return_data._setup_local_to_scene()
	return return_data

func reset_flight_data() -> void:
	flight_speed = 0.0
	flight_angle = 0.0
	flight_path = []
	focus_flight = false
	flight_ready = false
