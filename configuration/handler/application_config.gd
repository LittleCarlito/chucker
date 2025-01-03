extends Node
class_name ApplicationConfig

const NAME: String = "application"
const FPS_LOCK: String = "FPS_Lock"
const _MAX_FPS: String = "run/max_fps"

const CONFIG_LIBRARY: Dictionary = {
	FPS_LOCK: _MAX_FPS
}

const DEFAULTS: Dictionary = {
	FPS_LOCK = 0
}
