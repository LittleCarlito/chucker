extends StateData
class_name CameraStateData

const _MISSING_GUID: String = "Incoming associated rig \"%s\" is missing a GUID"

var focused_guid: String
var freelook_pitch: float
var freelook_yaw: float
var _is_focused: bool
var _is_sprinting: bool
var _is_idle_roatating: bool
var _is_height_held: bool
var _min_height_warn: bool = false


func set_focus(incoming_guid: String) -> void:
	self.focused_guid = incoming_guid

func set_is_focused(incoming_value: bool) -> void:
	self._is_focused = incoming_value

func is_focused() -> bool:
	return self._is_focused

func log(incoming_message: String, incoming_level: Logger.LEVEL) -> void:
	var is_min_log: bool = self._min_log_detect(incoming_message)
	if is_min_log and not _min_height_warn:
		super.log(incoming_message, incoming_level)
		self._min_height_warn = true
	else:
		super.log(incoming_message, incoming_level)

func print_details() -> void:
	Logger.debug("CameraStateData \"%s\" Focused: \"%s\" IsFocused: \"%s\" Pitch: \"%.2f\" Yaw: \"%.2f\" Sprinting: \"%s\"", [_owner_name, focused_guid, is_focused, freelook_pitch, freelook_yaw, _is_sprinting], self)

func _min_log_detect(incoming_message: String) -> bool:
	var regex = RegEx.new()
	var pattern = CameraRig._MIN_HEIGHT_WARN.replace("%f", ".*")
	regex.compile(pattern)
	return regex.search(incoming_message) != null
