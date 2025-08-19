extends LocalResource
class_name FlightData

@export var flight_speed: float
@export var flight_basis: Basis
@export var flight_path: Array[Vector3]
@export var focus_flight: bool

func _init(incoming_speed: float = 0, incoming_basis: Basis = Basis.from_euler(Vector3(0, 0, 0)), incoming_path: Array[Vector3] = [], incoming_focus: bool = false) -> void:
	self.flight_speed = incoming_speed
	self.flight_basis = incoming_basis
	self.flight_path = incoming_path
	self.focus_flight = incoming_focus
	self._setup_local_to_scene()

func set_flight_path(incoming_path: Array[Vector3]) -> void:
	self.flight_path = incoming_path

func set_flight_basis(incoming_basis: Basis) -> void:
	self.flight_basis = incoming_basis
