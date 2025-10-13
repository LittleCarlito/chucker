extends Object
class_name GroupData

# General method names
const GUID: String = "guid"
const UNKNOWN: String = "unknown"
const EMPTY: String  = ""
const TRUE: String = "true"
const FALSE: String = "false"
const LOG_OUTPUT: String = "log_output"
const GET_ASSET_STATE: String = "get_asset_state"
const SET_ASSET_STATE: String = "set_asset_state"
# TODO Need to implement this method in all assets that contain CameraContainer
const SET_CAMERA: String = "set_camera" # (incoming_camera: Camera3D, focus_point: Vector3 = Vecotr3.INF)
const HAS_CAMERA: String = "has_camera"
const LOSE_FOCUS: String = "lose_focus"
# TODO Need to implement this in objects that will initiate transferring of cameras (ChuckChucker, PathDisk)
const GIVE_CAMERA: String = "_give_camera" # (requesting_owner: Node3D)
# TODO CameraContainer needs to implement this to attempt to give ones of its instances of itself to the requesting_owner
#			Will need to update in the future to ask for specific camera
const REQUEST_CAMERA: String = "_request_camera" # (requesting_owner: Node3D)
const TRANSFER_AND_ENABLE: String = "_transfer_and_enable" # (incoming_camera: Camera3D)
# TODO Implement this method in all assets that can be picked up and have a camera transferred to them
const GET_CAMERA_CONTAINER: String = "_get_camera_container"
# TODO All holders of AssetData need getters and setters created
const SET_ASSET_DATA: String = "_set_asset_data" # (incoming_data: AssetData)
# TODO All holders of FlightData need getters and setters created
const SET_FLIGHT_DATA: String = "_set_flight_data" # (incoming_data: FlightData)
const GET_FLIGHT_DATA: String = "_get_flight_data"
# TODO All assets that need the ability to launch must implement below
# TODO Make sure to look at flight data if set to set camera to focused if containing camera and flight data is focused launch
const LAUNCH: String = "_launch"

const GET_MESH: String = "get_mesh"
const GET_PATH_FOLLOW: String = "get_path_follow"

# Group names
const ENVIRONMENT: String = "Environment"
const PLAYER: String = "Player"
const DISK: String = "Disk"
const GENERAL: String = "General"
const GRAPHICS: String = "Graphics"
const CONTROLS: String = "Controls"
const COURSE: String = "Course"
const TEE_BOX: String = "TeeBox"
const CAMERA_CONTAINER: String = "CameraContainer"
const CONFIG_HANDLER: String = "ConfigHandler"
# Group methods
const HOLD_ACTION: String = "hold_action"
const RELEASE_ACTION: String = "release_action"
const DISABLE_MOVEMENT: String = "disable_movement"
const ENABLE_MOVEMENT: String = "enable_movement"
const DISABLE_ROTATION: String = "disable_rotation"
const ENABLE_ROTATION: String = "enable_rotation"
# TODO Implement this on items that use GlobalSettings for runtime logic; Not used but UI objects for update calls
const RELOAD_PROJECT_SETTINGS: String = "reload_project_settings"
const RELOAD_DATA: String = "_reload_data"
# TODO General items need to implement this for after launch attempts
const UPDATE_STATE: String = "_update_state"
# TODO Rework these to be ALTER_HOLE_NUMBER and ALTER_HOLE_NODE_NUMBER; These should only be on TeeBox assets
const ALTER_HOLE_NODE_NUMBERS: String = "_alter_hole_node_numbers" # (hole_number: int, update_data: Dictionary[old_value[int], new_value[int])
const ALTER_HOLE_NUMBERS: String = "_alter_hole_numbers" # (update_data: Dictionary[old_value[int], new_value[int])
const RELOAD_COURSE_DATA: String = "_reload_course_data" # (hole_number: int = GroupData.INT64_MAX)
# TODO Rework COURSE group members to not implement this; Will be handled through TeeBox
const INCREASE_NODE_NUMBER: String = "_increase_node_number"
# TODO Implement this in TEEBOX assets
const DECREASE_NODE_NUMBER: String = "_decrease_node_number"
# TODO Implement this in TEEBOX assets
const INCREASE_HOLE_NUMBER: String = "_increase_hole_number"
