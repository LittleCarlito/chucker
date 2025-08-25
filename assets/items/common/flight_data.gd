class_name FlightData

var flight_details: FlightDetails
var flight_path: FlightPath

# TODO Refactor this constructor to work better with FlightDetails
func _init(
	incoming_speed: float = 0, 
	incoming_basis: Basis = Basis.from_euler(Vector3(0, 0, 0)), 
	incoming_details: FlightDetails = FlightDetails.new(),
	incoming_path: FlightPath = FlightPath.new(), 
	incoming_focus: bool = false
	) -> void:
	# TODO Restructure this to work better within the constructor
	self.flight_details = incoming_details
	self.flight_details.flight_basis = incoming_basis
	self.flight_details.flight_speed = incoming_speed
	self.flight_details.focus_flight = incoming_focus

	self.flight_path = incoming_path

## Returns the roll intensity at the given % into the flight path
## Given as whole number example: 60.6 == 60.6%; .606 = .606%
func roll_intensity_at(incoming_percent: float) -> float:
	return flight_path.roll_intensity_at(incoming_percent)

func set_flight_details(incoming_details: FlightDetails) -> void:
	self.flight_details = incoming_details

func get_flight_details() -> FlightDetails:
	return self.flight_details

func get_flight_path() -> FlightPath:
	return self.flight_path

# TODO Fix all accessors to .flight_path.path
func get_actual_path() -> Array[FlightPoint]:
	return self.flight_path.path

func set_flight_path(incoming_path: FlightPath) -> void:
	self.flight_path = incoming_path

func set_flight_basis(incoming_basis: Basis) -> void:
	self.flight_details.flight_basis = incoming_basis

func print_details() -> void:
	flight_details.print_details()
	flight_path.print_details()

func get_flight_power() -> float:
	return self.flight_details.flight_power

func get_flight_aim() -> float:
	return self.flight_details.flight_aim

func set_is_focused(incoming_focus: bool) -> void:
	self.flight_details.focus_flight = incoming_focus

func is_focus_flight() -> bool:
	return self.flight_details.focus_flight

func get_flight_speed() -> float:
	return self.flight_details.flight_speed

func set_flight_speed(incoming_speed: float) -> void:
	self.flight_details.flight_speed = incoming_speed

func get_flight_basis() -> Basis:
	return self.flight_details.flight_basis
