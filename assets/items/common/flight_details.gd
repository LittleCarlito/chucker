class_name FlightDetails

var flight_basis: Basis
var flight_power: float
var flight_aim: float
var focus_flight: bool
var flight_speed: float

func _init(
	incoming_power: float = 0, 
	incoming_aim: float = 0, 
	incoming_basis: Basis = Basis.from_euler(Vector3(0, 0, 0)), 
	is_focused: bool = false, 
	incoming_speed: float = 0
	) -> void:

	self.flight_power = incoming_power
	self.flight_aim = incoming_aim
	self.flight_basis = incoming_basis
	self.focus_flight = is_focused
	self.flight_speed = incoming_speed

func print_details() -> void:
	Logger.debug("\nFlight details:\nFlight power: %03f\nFlight aim: %03f", [self.flight_power, self.flight_aim], self)
