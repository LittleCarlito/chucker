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

func debug(debugLog: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.DEBUG:
		_print(debugLog, params)

func info(infoLog: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.INFO:
		_print(infoLog, params)

func warn(warnLog: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.WARN:
		_print(warnLog, params)

func error(errorLog: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.ERROR:
		_print(errorLog, params)

func _print(printLog: String, params: Array) -> void:
	var logString: String = printLog % params
	print(logString)

# TODO Need ability to identify callers and format logs to make it clear who says what
# TODO Need to set project settings to output to a file
# TODO Need to have this util manage that file output and keep it tidy
#		Including creating new files and cleaning up old
# TODO Figure out how to handle exceptions and crash during certain ones
