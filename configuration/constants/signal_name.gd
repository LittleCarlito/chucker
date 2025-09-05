class_name SIGNAL_NAME

const ZOOM_IN: String = "zoom_in"
const ZOOM_OUT: String = "zoom_out"
const TURN_HORIZONTAL: String = "turn_horizontal"
const TIMEOUT: String = "timeout"
const ROTATE: String = "rotate" # rotation_axis: Vector3, rotation_amount: float
const HOLD_HEIGHT: String = "hold_height" # min_height: float
const PRIMARY_ACTION: String = "primary_action"
const PRIMARY_HOLD: String = "primary_hold" # delta: float
const PRIMARY_RELEASE: String = "primary_release"
# TODO Rename users of this to primary_motion
const PRIMARY_MOTION: String = "primary_movement" # v_motion: float, h_motion: float
const SECONDARY_ACTION: String = "secondary_action"
const SECONDARY_HOLD: String = "secondary_hold" # delta: float
const SECONDARY_RELEASE: String = "secondary_release"
# TODO Rename users of this to secondary_motion
const SECONDARY_MOTION: String = "secondary_movement" # v_motion: float, h_motion: float
const DUO_ACTION: String = "duo_action"
const DUO_HOLD: String = "duo_hold" # delta: float
const DUO_RELEASE: String = "duo_release"
# TODO Rename users of this to duo_motion
const DUO_MOTION:String = "duo_movement" # v_motion: float, h_motion: float
const FREELOOK_MOTION: String = "freelook_movement" # v_motion: float, h_motion:float
const PAUSE_ACTION: String = "pause_action"
const PAUSE_HOLD: String = "pause_hold"
const PAUSE_RELEASE: String = "pause_release"
const TAB_ACTION: String = "tab_action"
const TAB_HOLD: String = "tab_hold"
const TAB_RELEASE: String = "tab_release"
# Movement
const JUMP_ACTION: String = "jump_action"
const JUMP_HOLD: String = "jump_hold"
const JUMP_RELEASE: String = "jump_release"
const CROUCH_ACTION: String = "crouch_action"
const CROUCH_HOLD: String = "crouch_hold"
const CROUCH_RELEASE: String = "crouch_release"
const SPRINT_ACTION: String = "sprint_action"
const SPRINT_HOLD: String = "sprint_hold"
const SPRINT_RELEASE: String = "sprint_release"
const LEFT_ACTION: String = "left_action"
const LEFT_HOLD: String = "left_hold" # delta: float
const LEFT_RELEASE: String = "left_release"
const ALT_LEFT_ACTION: String = "alt_left_action"
const ALT_LEFT_HOLD: String = "alt_left_hold" # delta
const ALT_LEFT_RELEASE: String = "alt_left_release"
const RIGHT_ACTION: String = "right_action"
const RIGHT_HOLD: String = "right_hold" # delta: float
const RIGHT_RELEASE: String = "right_release"
const ALT_RIGHT_ACTION: String = "alt_right_action"
const ALT_RIGHT_HOLD: String = "alt_right_hold"
const ALT_RIGHT_RELEASE: String = "alt_right_release"
const UP_ACTION: String = "up_action"
const UP_HOLD: String = "up_hold" # delta: float
const UP_RELEASE: String = "up_release"
const DOWN_ACTION: String = "down_action"
const DOWN_HOLD: String = "down_hold" # delta: float
const DOWN_RELEASE: String = "down_release"
const WQSE_INPUT_DIRECTION: String = "wqse_input_direction" # incoming_direction Vector2
const WASD_INPUT_DIRECTION: String = "wasd_input_direction" # incoming_direction Vector2

# Global camera controller
const REQUEST_CAMERA: String = "request_camera" # new_node: Node3D
const CHANGE_MODE: String = "change_mode" # new_mode: GlobalCameraController.TrackingMode
const IS_FOCUSING: String = "is_focusing" # incoming_focus: bool
const IS_IDLING: String = "is_idling" # incoming_value: bool
