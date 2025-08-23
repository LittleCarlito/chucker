class_name FlightData

var flight_speed: float
var flight_basis: Basis
var flight_details: FlightDetails
var flight_path: FlightPath
var focus_flight: bool

func _init(
	incoming_speed: float = 0, 
	incoming_basis: Basis = Basis.from_euler(Vector3(0, 0, 0)), 
	incoming_details: FlightDetails = FlightDetails.new(),
	incoming_path: FlightPath = FlightPath.new(), 
	incoming_focus: bool = false
	) -> void:
	self.flight_speed = incoming_speed
	self.flight_basis = incoming_basis
	self.flight_details = incoming_details
	self.flight_path = incoming_path
	self.focus_flight = incoming_focus

## Returns the roll intensity at the given % into the flight path
## Given as whole number example: 60.6 == 60.6%; .606 = .606%
func roll_intensity_at(incoming_percent: float) -> float:
	return flight_path.roll_intensity_at(incoming_percent)

func set_flight_details(incoming_details: FlightDetails) -> void:
	self.flight_details = incoming_details

func set_flight_path(incoming_path: FlightPath) -> void:
	self.flight_path = incoming_path

func set_flight_basis(incoming_basis: Basis) -> void:
	self.flight_basis = incoming_basis

func print_details() -> void:
	Logger.debug("\n[FlightData details]\nFlight speed: %d\nFocus flight: %s\nFlight basis: %s", [self.flight_speed, self.focus_flight, self.flight_basis], self)
	flight_path.print_details()
