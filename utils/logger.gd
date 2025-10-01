extends Node3D

const NULL_PARAMETER: String = "Null parameter given to %s"
const CANT_RETURN_LOG: String = "Missing asset data or camera container/camera to return camera to owner \"%s\""
const NOT_SUBMITTING: String = "Not submitting camera request"
const NO_GROUP_LOG: String = "No group name"
const MISSING_FLIGHT_DATA_LOG: String = "Launch parameters must be set before item can be launched"
const KEEPING_CAMERA: String = "Not transferring camera"
const NULL_PARAMETER_STRING: String = "Null parameter given"
const CANNOT_ACTION_STRING: String = "Cannot %s"
const ILLEGAL_STATE_STRING: String = "Illegal state has been reached %s"
const EXISTING_DATA_MISSING: String = "%s \"%s\" was expected to exist but returned null from %s"
const FOR_METHOD_LOG: String = "For method %s"
const METHOD_LOG: String = "\"%s\"; \"%s\""
const NULL_LOG: String = "\"%s\" is null"
const ITEM_OWNER_LOG: String = "item_owner \"%s\""
const UNIMPLEMENTED_LOG: String = "UNIMPLEMENTED METHOD; All %s Objects must implement \"%s\""
const UNSUPPORTED_TYPE_LOG: String = "%s recieved an unsupported type \"%s\""
const RETURNING_NULL_LOG: String = "Returning null"
const RETURNING_FALSE_LOG: String = "Returning false"
const RETURNING_ZERO_LOG: String = "Returning 0"
const NULL_CAMERA_LOG: String = "has no camera and cannot %s"
const ALREADY_EXISTS_LOG: String = "%s already exists"
const NOT_FOUND_LOG: String = "No %s could be found"
const HOLE_NODE_DATA: String = "HoleNodeData"
const TOGGLE_CAMERA: String = "toggle_camera"
const DISABLE_CAMERA: String = "disable_camera"
const ENABLE_CAMERA: String = "enable_camera"
const RESET_ZOOM: String = "reset_zoom"
const ZOOM_IN: String = "zoom_in"
const ZOOM_OUT: String = "zoom_out"
const GET_CAMERA: String = "get_camera"
const IS_CURRENT: String = "is_current"
const LOCATION_LOG: String = "\"%s\" global position \"%s\""
# TODO Refactor other users to use this instead
const RETURNING_UNKNOWN_LOG: String = "Returning unknown"
const RETURNING_INT16_MAX: String = "Returning INT16_MAX"
const PICKED_UP_LOG: String = "%s has been picked up"
const DEACTIVATE_LOG: String = "%s is deactivating"
const LOG_SEPARATOR: String = "; "
const OR_SEPARATOR: String = " OR "
const EITHER_STARTER: String = "Either "
const NO_METHOD_FOUND: String = "No method \"%s\" found on object \"%s\""
# TODO Make public
const _CANT_PERFORM: String = "\"%s\" could not be found; \"%s\" can not be performed"
const CALL_FAILED: String = "Call to function \"%s\" with parameters \"%s\" failed"

const BAD_ACTION_FORMAT: String = "Incoming action \"%s\" was missing property %s and could not be processed"

const LOG_LEVEL_TYPE: String = "LOG LEVEL TYPE"
enum LEVEL {
	DEBUG,
	INFO,
	WARN,
	ERROR
}

var log_level: LEVEL = LEVEL.DEBUG

func set_log_level(level: LEVEL) -> void:
	log_level = level

func debug(debug_log: String, params: Array, caller: Object) -> void:
	if log_level <= LEVEL.DEBUG:
		_print(debug_log, params, caller, LEVEL.DEBUG)

func info(info_log: String, params: Array, caller: Object) -> void:
	if log_level <= LEVEL.INFO:
		_print(info_log, params, caller, LEVEL.INFO)

func warn(warn_log: String, params: Array, caller: Object) -> void:
	if log_level <= LEVEL.WARN:
		_print(warn_log, params, caller, LEVEL.WARN)

func error(error_log: String, params: Array, caller: Object) -> void:
	if log_level <= LEVEL.ERROR:
		_print(error_log, params, caller, LEVEL.ERROR)

# TODO Run some bad logs through and see how catching their errors goes
#			Then print what you can about missing parameters or whatever for why blank logs
# TODO Need to add logging statements to all GlobalSetting.get()s that can use default values
#			Need to add warning when default is used to it can at leaste be looked at
func _print(print_log: String, params: Array, caller: Object, incoming_log_level: LEVEL) -> void:
	var time_stamp: String = Time.get_datetime_string_from_system()
	var log_string: String = print_log % params
	var format_string: String =  "[%s] %s - %s: %s"
	var level_string: String = LEVEL.keys()[incoming_log_level]
	var caller_string: String = "" if caller == null else str(caller.name) if caller is Node else ""
	var formatted_log: String = format_string % [level_string, time_stamp, caller_string, log_string]
	print(formatted_log)
	if incoming_log_level == LEVEL.WARN:
		push_warning(formatted_log)
	elif incoming_log_level == LEVEL.ERROR:
		push_error(formatted_log)
