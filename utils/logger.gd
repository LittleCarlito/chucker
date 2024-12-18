extends Node3D

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
	var formatted_log: String = format_string % [level_string, time_stamp, caller.get("name"), log_string]
	print(formatted_log)
	if incoming_log_level == LEVEL.WARN:
		push_warning(formatted_log)
	elif incoming_log_level == LEVEL.ERROR:
		push_error(formatted_log)
