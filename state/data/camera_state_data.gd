extends StateData
class_name CameraStateData

const _NOT_FOCUSED: String = "Not focused returning empty string"

# TODO MOVE THIS TO STATE DATA
# TODO MAKE IT PRIVATE
var focused_guid: String


var freelook_pitch: float
var freelook_yaw: float
# TODO Two below should be based off state not these bools
var _is_idle_roatating: bool
# TODO Could make extra STATES for holding/not holding height
var _is_height_held: bool
var _min_height_warn: bool = false

func get_focus_guid() -> String:
	if self.focused_guid == null or self.focused_guid.strip_edges().is_empty():
		Logger.warn(self._NOT_FOCUSED, [], self)
		return GroupData.EMPTY
	else:
		return self.focused_guid

func set_focus(incoming_guid: String) -> void:
	self.focused_guid = incoming_guid

func log(incoming_message: String, incoming_level: Logger.LEVEL) -> void:
	var is_min_log: bool = self._min_log_detect(incoming_message)
	if is_min_log and not _min_height_warn:
		super.log(incoming_message, incoming_level)
		self._min_height_warn = true
	else:
		super.log(incoming_message, incoming_level)

func print_details() -> void:
	Logger.debug("CameraStateData \"%s\" Focused: \"%s\" Pitch: \"%.2f\" Yaw: \"%.2f\" Sprinting: \"%s\"", [_owner_name, focused_guid, freelook_pitch, freelook_yaw, _is_sprinting], self)

func _min_log_detect(incoming_message: String) -> bool:
	var regex = RegEx.new()
	var pattern = CameraRig._MIN_HEIGHT_WARN.replace("%f", ".*")
	regex.compile(pattern)
	return regex.search(incoming_message) != null
