class_name SIGNAL_NAME

const ZOOM_IN: String = "zoom_in"
const ZOOM_OUT: String = "zoom_out"
const TURN_HORIZONTAL: String = "turn_horizontal"
const TIMEOUT: String = "timeout"
const ROTATE: String = "rotate" # rotation_axis: Vector3, rotation_amount: float
const PRIMARY_ACTION: String = "primary_action"
const PRIMARY_RELEASE: String = "primary_release"
# TODO Rename users of this to primary_motion
const PRIMARY_MOTION: String = "primary_movement" # v_motion: float, h_motion: float
const SECONDARY_ACTION: String = "secondary_action"
const SECONDARY_RELEASE: String = "secondary_release"
# TODO Rename users of this to secondary_motion
const SECONDARY_MOTION: String = "secondary_movement" # v_motion: float, h_motion: float
const DUO_ACTION: String = "duo_action"
const DUO_RELEASE: String = "duo_release"
# TODO Rename users of this to duo_motion
const DUO_MOTION:String = "duo_movement" # v_motion: float, h_motion: float
const FREELOOK_MOTION: String = "freelook_movement" # v_motion: float, h_motion:float
const PAUSE_ACTION: String = "pause_action"
const PAUSE_RELEASE: String = "pause_release"
const TAB_ACTION: String = "tab_action"
const TAB_RELEASE: String = "tab_release"

# Global camera controller
const REQUEST_CAMERA: String = "request_camera" # new_node: Node3D
const CHANGE_MODE: String = "change_mode" # new_mode: GlobalCameraController.TrackingMode
