class_name FlightPath
var path: Array[FlightPoint]
var path_type: PATH_TYPE
var max_offset: float

enum PATH_TYPE {
	STRAIGHT,
	LEFT,
	RIGHT,
	EMPTY
}

func _init(incoming_path: Array[FlightPoint] = []):
	self.path = incoming_path
	FlightPath.analyze_path_offset(self)

## Returns the roll intensity at the given % into the flight path
## Given as decimal between 0.0 and 1.0, example: 0.606 == 60.6%
func roll_intensity_at(incoming_percent: float) -> float:
	if path.size() <= 1:
		return 0.0
	else:
		# Use percent directly (0.0 to 1.0) multiplied by size
		var desired_index: int = int(path.size() * incoming_percent)
		# Safety clamp to avoid indexing out of range
		desired_index = clamp(desired_index, 0, path.size() - 1)
		return path[desired_index].roll_intensity

func get_max_offset() -> float:
	return self.max_offset

func get_path() -> Array[FlightPoint]:
	return self.path

func is_empty() -> bool:
	return self.path.is_empty()

func size() -> int:
	return self.path.size()

func get_point(incoming_index: int) -> FlightPoint:
	return self.path[incoming_index]

func print_details() -> void:
	var flight_type_string: String = self._get_type_string(path_type)
	Log.debug("\n[FlightPath data]\nNumber of points: %d\nFlight type %s\nMax offset : %03f", [path.size(), flight_type_string, max_offset], self)
	if GameConfig.DEFAULTS.extra_detail:
		for i in range(path.size()):
			var fp: FlightPoint = path[i]
			Log.debug("Point %d: Roll Intensity: %.3f", [i, fp.roll_intensity], self)

func _get_type_string(incoming_type: PATH_TYPE) -> String:
	match incoming_type:
		PATH_TYPE.STRAIGHT:
			return "straight"
		PATH_TYPE.LEFT:
			return "hook"
		PATH_TYPE.RIGHT:
			return "slice"
		_:
			return "empty"

## Analyzes the incoming path for max offset point
static func analyze_path_offset(flight_path: FlightPath) -> void:
	if flight_path.is_empty() or flight_path.size() < 3:
		flight_path.max_offset = 0.0
		FlightPath.analyze_path_type(flight_path)
		return
	var first_point = Vector2(flight_path.get_point(0).point_position.x, flight_path.get_point(0).point_position.z)
	var last_point = Vector2(flight_path.get_point(flight_path.size() - 1).point_position.x, flight_path.get_point(flight_path.size() - 1).point_position.z)
	var baseline = last_point - first_point
	var baseline_length = baseline.length()
	if baseline_length < 0.001:
		flight_path.max_offset = 0.0
		FlightPath.analyze_path_type(flight_path)
		return
	var max_offset = 0.0
	var max_offset_magnitude = 0.0
	for i in range(1, flight_path.size() - 1):
		var current_point = Vector2(flight_path.get_point(i).point_position.x, flight_path.get_point(i).point_position.z)
		var to_point = current_point - first_point
		var projection_length = to_point.dot(baseline) / baseline_length
		var projection_point = first_point + baseline.normalized() * projection_length
		var offset_vector = current_point - projection_point
		var distance = offset_vector.length()
		if distance > max_offset_magnitude:
			max_offset_magnitude = distance
			var cross_product = baseline.x * offset_vector.y - baseline.y * offset_vector.x
			max_offset = sign(cross_product) * distance
	flight_path.max_offset = max_offset
	FlightPath.analyze_path_type(flight_path)

## Analyzes the incoming path for curvature
static func analyze_path_type(flight_path: FlightPath) -> void:
	if flight_path.is_empty():
		flight_path.path_type = PATH_TYPE.EMPTY
		return
	if flight_path.size() < 3:
		flight_path.path_type = PATH_TYPE.STRAIGHT
		return
	if flight_path.max_offset > 0.001:
		flight_path.path_type = PATH_TYPE.RIGHT
	elif flight_path.max_offset < -0.001:
		flight_path.path_type = PATH_TYPE.LEFT
	else:
		flight_path.path_type = PATH_TYPE.STRAIGHT

## Converts a path of 3D points into a FlightPath with roll intensity calculations
## roll_intensity: 0.0 = straight, positive = right turn (slice), negative = left turn (hook)
## Higher absolute values indicate sharper curves, in radians (≈ -3.14 … +3.14)
static func convert(incoming_line: Array[Vector3]) -> FlightPath:
	var flight_points: Array[FlightPoint] = []
	# Handle empty array
	if incoming_line.size() == 0:
		return FlightPath.new(flight_points)
	# Handle single point - create FlightPoint with no roll
	if incoming_line.size() == 1:
		var flight_point = FlightPoint.new()
		flight_point.point_position = incoming_line[0]
		flight_point.roll_intensity = 0.0
		flight_points.append(flight_point)
		return FlightPath.new(flight_points)
	# Process each point in the path (2 or more points)
	for i in range(incoming_line.size()):
		var flight_point = FlightPoint.new()
		flight_point.point_position = incoming_line[i]
		# Calculate roll intensity based on curvature at this point
		if i == 0 or i == incoming_line.size() - 1:
			# First and last points have no roll (no curve data available)
			flight_point.roll_intensity = 0.0
		else:
			var point_a = incoming_line[i - 1]
			var point_current = incoming_line[i]
			var point_c = incoming_line[i + 1]
			flight_point.roll_intensity = calculate_roll_intensity(point_a, point_current, point_c)
		flight_points.append(flight_point)
	var flight_path = FlightPath.new(flight_points)
	return flight_path

## Calculates roll intensity for three consecutive points
## roll_intensity: 0.0 = straight, positive = right turn (slice), negative = left turn (hook)
## Higher absolute values indicate sharper curves, in radians (≈ -3.14 … +3.14)
static func calculate_roll_intensity(point_a: Vector3, point_b: Vector3, point_c: Vector3) -> float:
	# Create vectors (ignoring Y for left/right analysis)
	var vector_ab = Vector2(point_b.x - point_a.x, point_b.z - point_a.z)
	var vector_bc = Vector2(point_c.x - point_b.x, point_c.z - point_b.z)
	var len_ab = vector_ab.length()
	var len_bc = vector_bc.length()
	
	if len_ab > 0.001 and len_bc > 0.001:
		vector_ab = vector_ab / len_ab
		vector_bc = vector_bc / len_bc
		# Dot = cos(theta), Cross = sin(theta)
		var dot_product = clamp(vector_ab.dot(vector_bc), -1.0, 1.0)
		var cross_product = vector_ab.x * vector_bc.y - vector_ab.y * vector_bc.x
		# Actual angle between vectors (0 = straight, π = 180° turn)
		var angle = acos(dot_product)
		# Roll intensity = signed angle
		return -sign(cross_product) * angle
	else:
		return 0.0
