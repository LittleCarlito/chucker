class_name FlightData

var flight_details: FlightDetails
var flight_path: FlightPath

func _init(incoming_details: FlightDetails = FlightDetails.new(), incoming_path: FlightPath = FlightPath.new()) -> void:
	flight_details = incoming_details
	flight_path = incoming_path

## Returns the roll intensity at the given % into the flight path
## Given as whole number example: 60.6 == 60.6%; .606 = .606%
func roll_intensity_at(incoming_percent: float) -> float:
	return flight_path.roll_intensity_at(incoming_percent)

func set_flight_details(incoming_details: FlightDetails) -> void:
	flight_details = incoming_details

func get_flight_details() -> FlightDetails:
	return flight_details

func get_flight_path() -> FlightPath:
	return flight_path

func get_actual_path() -> Array[FlightPoint]:
	return flight_path.path

func set_flight_path(incoming_path: FlightPath) -> void:
	flight_path = incoming_path

func set_flight_basis(incoming_basis: Basis) -> void:
	flight_details.flight_basis = incoming_basis

func get_flight_power() -> float:
	return flight_details.flight_power

func set_flight_power(incoming_power: float) -> void:
	flight_details.flight_power = incoming_power

func get_flight_aim() -> float:
	return flight_details.flight_aim

func set_flight_aim(incoming_aim: float) -> void:
	flight_details.flight_aim = incoming_aim

func set_is_focused(incoming_focus: bool) -> void:
	flight_details.focus_flight = incoming_focus

func is_focus_flight() -> bool:
	return flight_details.focus_flight

func get_max_offset() -> float:
	return flight_path.get_max_offset()

func get_flight_speed() -> float:
	return flight_details.flight_speed

func set_flight_speed(incoming_speed: float) -> void:
	flight_details.flight_speed = incoming_speed

func get_flight_basis() -> Basis:
	return flight_details.flight_basis

func get_flight_spin() -> float:
	return flight_details.flight_spin

func set_flight_spin(incoming_spin: float) -> void:
	flight_details.flight_spin = incoming_spin

func print_details() -> void:
	flight_details.print_details()
	flight_path.print_details()
