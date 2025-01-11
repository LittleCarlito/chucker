extends LocalResource
class_name FlightData

@export var flight_speed: float
@export var flight_basis: Basis
@export var flight_path: Array[Vector3]
@export var focus_flight: bool

static func create_flight_data(incoming_speed: float, incoming_basis: Basis, incoming_path: Array[Vector3] = [], incoming_focus: bool = false) -> FlightData:
	var return_data: FlightData = FlightData.new()
	return_data.flight_speed = incoming_speed
	return_data.flight_basis = incoming_basis
	return_data.flight_path = incoming_path
	return_data.focus_flight = incoming_focus
	return_data._setup_local_to_scene()
	return return_data

func set_flight_path(incoming_path: Array[Vector3]) -> void:
	self.flight_path = incoming_path

func set_flight_basis(incoming_basis: Basis) -> void:
	self.flight_basis = incoming_basis
