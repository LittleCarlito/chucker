class_name FlightDetails

var flight_power: float
var flight_aim: float

func _init(incoming_power: float = 0, incoming_aim: float = 0) -> void:
	self.flight_power = incoming_power
	self.flight_aim = incoming_aim

func log_details() -> void:
	Logger.debug("\nFlight details:\nFlight power: %03f\nFlight aim: %03f", [self.flight_power, self.flight_aim], self)
