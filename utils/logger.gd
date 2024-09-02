extends Node3D

enum LEVEL {
	DEBUG,
	INFO,
	WARN,
	ERROR
}

var LOG_LEVEL: LEVEL = LEVEL.INFO

func set_log_level(level: LEVEL) -> void:
	self.LOG_LEVEL = level

func debug(debugLog: String, params: Array, caller: Object) -> void:
	if LOG_LEVEL <= LEVEL.DEBUG:
		_print(debugLog, params, caller)

func info(infoLog: String, params: Array, caller: Object) -> void:
	if LOG_LEVEL <= LEVEL.INFO:
		_print(infoLog, params, caller)

func warn(warnLog: String, params: Array, caller: Object) -> void:
	if LOG_LEVEL <= LEVEL.WARN:
		_print(warnLog, params, caller)

func error(errorLog: String, params: Array, caller: Object) -> void:
	if LOG_LEVEL <= LEVEL.ERROR:
		_print(errorLog, params, caller)

func _print(printLog: String, params: Array, caller: Object) -> void:
	var timeStamp: String = Time.get_datetime_string_from_system()
	var logString: String = printLog % params
	var formatString: String =  "%s - %s: %s"
	var formattedLogString: String = formatString % [timeStamp, caller.get("name"), logString]
	print(formattedLogString)

# TODO Need to set project settings to output to a file
# TODO Need to have this util manage that file output and keep it tidy
#		Including creating new files and cleaning up old
# TODO Figure out how to handle exceptions and crash during certain ones
