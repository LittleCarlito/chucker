class_name FlightData

var flight_details: FlightDetails
var flight_path: FlightPath
var state_config: ItemStateConfig

func _init(
			item_type: AssetData.TYPE = AssetData.TYPE.UNKNOWN,
			incoming_details: FlightDetails = FlightDetails.new(), 
			incoming_path: FlightPath = FlightPath.new()
			) -> void:
	self.flight_details = incoming_details
	self.flight_path = incoming_path
	# Only have to call once; Path + Charge are static and Planned knows path before creating its final FlightData
	self.state_config = ItemStateConfig.get_default_config(item_type)


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

func set_flight_power(incoming_power: float) -> void:
	self.flight_details.flight_power = incoming_power

func get_flight_aim() -> float:
	return self.flight_details.flight_aim

func set_flight_aim(incoming_aim: float) -> void:
	self.flight_details.flight_aim = incoming_aim

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
