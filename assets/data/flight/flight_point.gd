class_name FlightPoint

var point_position: Vector3
var roll_intensity: float

func _init(incoming_location: Vector3 = Vector3.INF, incoming_intensity: float = 0):
	if incoming_location != Vector3.INF:
		point_position = incoming_location
	roll_intensity = incoming_intensity
