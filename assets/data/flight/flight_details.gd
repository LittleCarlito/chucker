class_name FlightDetails

var flight_basis: Basis
var flight_power: float
var flight_aim: float
var focus_flight: bool
var flight_speed: float
var flight_spin: float

func _init(
	incoming_power: float = 0, 
	incoming_aim: float = 0, 
	incoming_basis: Basis = Basis.from_euler(Vector3(0, 0, 0)), 
	is_focused: bool = false, 
	incoming_speed: float = 0,
	incoming_spin: float = 0
	) -> void:
	flight_power = incoming_power
	flight_aim = incoming_aim
	flight_basis = incoming_basis
	focus_flight = is_focused
	flight_speed = incoming_speed
	flight_spin = incoming_spin

func print_details() -> void:
	Log.debug("\nFlight details:\nFlight power: %03f\nFlight aim: %03f\nFlight spin: %03f", [flight_power, flight_aim, flight_spin], self)
