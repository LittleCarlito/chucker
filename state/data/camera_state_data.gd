extends StateData

class_name CameraStateData

const _MISSING_GUID: String = "Incoming associated rig \"%s\" is missing a GUID"

var focused_guid: String
var is_focused: bool
var freelook_pitch: float
var freelook_yaw: float
var _min_height_warn: bool = false
var _is_sprinting: bool
var _is_idle_roatating: bool

func _init(associated_rig: CameraRig) -> void:
	if associated_rig != null and associated_rig.has_meta(GroupData.GUID):
		super._init(associated_rig.get_meta(GroupData.GUID), associated_rig.name)
	elif associated_rig != null:
		Logger.error(self._MISSING_GUID, [associated_rig.name], self)

func duplicate() -> CameraStateData:
	var copy := CameraStateData.new(null) # skip init with rig
	copy._owner_guid = _owner_guid
	copy._owner_name = _owner_name
	copy.focused_guid = focused_guid
	copy.is_focused = is_focused
	copy.freelook_pitch = freelook_pitch
	copy.freelook_yaw = freelook_yaw
	copy._min_height_warn = _min_height_warn
	copy._is_sprinting = _is_sprinting
	copy._is_idle_roatating = _is_idle_roatating
	return copy

func print_details() -> void:
	Logger.debug("CameraStateData \"%s\" Focused: \"%s\" IsFocused: \"%s\" Pitch: \"%.2f\" Yaw: \"%.2f\" Sprinting: \"%s\"", [_owner_name, focused_guid, is_focused, freelook_pitch, freelook_yaw, _is_sprinting], self)
