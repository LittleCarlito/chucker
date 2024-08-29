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

func debug(log: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.DEBUG:
		_print(log, params)

func info(log: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.INFO:
		_print(log, params)

func warn(log: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.WARN:
		_print(log, params)

func error(log: String, params: Array) -> void:
	if LOG_LEVEL <= LEVEL.ERROR:
		_print(log, params)

func _print(log: String, params: Array) -> void:
	var logString: String = log % params
	print(logString)
