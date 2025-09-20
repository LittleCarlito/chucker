extends StateData
class_name CameraStateData

# TODO This class and CameraStorage probably don't need to exist
# TODO		Come up with some clever generic way to store warnings and their detection shit
#				Really should just move flipping to where it is sent from and get rid of regex hack
#					Then this class should be good to remove

const _NOT_FOCUSED: String = "Not focused returning empty string"


# TODO Two below should be based off state not these bools
var _is_idle_roatating: bool
# TODO Could make extra STATES for holding/not holding height
var _is_height_held: bool
var _min_height_warn: bool = false

func log(incoming_message: String, incoming_level: Logger.LEVEL) -> void:
	var is_min_log: bool = self._min_log_detect(incoming_message)
	if is_min_log and not _min_height_warn:
		super.log(incoming_message, incoming_level)
		self._min_height_warn = true
	else:
		super.log(incoming_message, incoming_level)

func print_details() -> void:
	Logger.debug("CameraStateData \"%s\" Sprinting: \"%s\"", [_owner_name, _is_sprinting], self)

func _min_log_detect(incoming_message: String) -> bool:
	var regex = RegEx.new()
	var pattern = CameraRig._MIN_HEIGHT_WARN.replace("%f", ".*")
	regex.compile(pattern)
	return regex.search(incoming_message) != null
