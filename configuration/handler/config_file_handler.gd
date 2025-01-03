extends Node
class_name ConfigFileHandler

# Log messages
const _FILE_NOT_FOUND: String = "File %s not found"
const _NO_OVERRIDE_RESULTS: String = "No supported override results could be found for incoming setting dictionary \"%s\""
const _NOT_SUPPORTED_KEY: String = "Incoming key \"%s\" is currently not suported for %s settings"
const _OVERRIDE: String = "override"
const _USER_SETTING: String = "user_setting"
const _LOAD_FAIL: String = "Failure loading from path %s"
# File pathways
const BASE_PATH: String = "user://"
const SAVE_DIR: String = BASE_PATH + "settings/"
const JSON_SAVE_FILE: String = SAVE_DIR + "user_settings.json"
const OVERRIDE_FILE: String = SAVE_DIR + "override.cfg"
const USER_SETTINGS_FILE: String = SAVE_DIR + "user_settings.cfg"
# Application configs
const _MAX_FPS: String = "run/max_fps"
# Debug configs
const _DISPLAY_PERFORMANCE: String = "settings/stdout/print_fps"
# Display configs
const _WINDOW_MODE:String = "window/size/mode"
const _WINDOW_SCALE: String = "window/stretch/scale"
const _WINDOW_BORDERLESS: String = "window/size/borderless"
const _WINDOW_INITIAL_POSITION: String = "window/size/initial_position_type" # 2 is centered on other screen; 1 is centered on Primary screen
const _WINDOW_INITIAL_SCREEN: String = "window/size/initial_screen" # INTIIAL_POSITION MUST but 2 for this to work; Determines what screen window is on

const CONFIG_LIBRARY: Dictionary = {
	ApplicationConfig.NAME: {
		ApplicationConfig.FPS_LOCK: _MAX_FPS
		},
	DebugConfig.NAME: {
		DebugConfig.PERFORMANCE: _DISPLAY_PERFORMANCE
		},
	DisplayConfig.NAME: {
		DisplayConfig.WINDOW_MODE: _WINDOW_MODE,
		DisplayConfig.UI_SCALE: _WINDOW_SCALE,
		DisplayConfig.WINDOW_BORDERLESS: _WINDOW_BORDERLESS,
		DisplayConfig.WINDOW_INITIAL_POSITION: _WINDOW_INITIAL_POSITION,
		DisplayConfig.WINDOW_INITIAL_SCREEN: _WINDOW_INITIAL_SCREEN
	},
	CameraConfig.NAME: {
		CameraConfig.PLAYER_FOV: CameraConfig.PLAYER_FOV,
		CameraConfig.INVERT_VERTICAL: CameraConfig.INVERT_VERTICAL,
		CameraConfig.INVERT_HORIZONTAL: CameraConfig.INVERT_HORIZONTAL,
		CameraConfig.VERTICAL_AIM_SENSITIVITY: CameraConfig.VERTICAL_AIM_SENSITIVITY,
		CameraConfig.HORIZONTAL_AIM_SENSITIVITY: CameraConfig.HORIZONTAL_AIM_SENSITIVITY,
		CameraConfig.VERTICAL_LOOK_SENSITIVITY: CameraConfig.VERTICAL_LOOK_SENSITIVITY,
		CameraConfig.HORIZONTAL_LOOK_SENSITIVITY: CameraConfig.HORIZONTAL_LOOK_SENSITIVITY
	}
}


## Appends incoming settings to exsting user_settings.cfg
static func _save_to_user_settings(incoming_settings: Dictionary) -> void:
	# See if file exists
	var user_settings_file: ConfigFile = ConfigFile.new()
	if FileAccess.file_exists(USER_SETTINGS_FILE):
		var file: FileAccess = FileAccess.open(USER_SETTINGS_FILE, FileAccess.READ)
		if file != null:
			# Use existing data or delete and reset if parse fails
			var error: Error = user_settings_file.parse(file.get_as_text())
			if error != OK:
				user_settings_file = ConfigFile.new()
				DirAccess.remove_absolute(USER_SETTINGS_FILE)
	var camera_library: Dictionary = CONFIG_LIBRARY.get(CameraConfig.NAME) as Dictionary
	var incoming_keys: Array = incoming_settings.keys()
	for incoming_key in incoming_keys:
		var incoming_value = incoming_settings.get(incoming_key)
		if camera_library.has(incoming_key):
			var camera_command: String = camera_library.get(incoming_key)
			user_settings_file.set_value(CameraConfig.NAME, camera_command, incoming_value)
		else:
			Logger.debug(_NOT_SUPPORTED_KEY, [incoming_key, _USER_SETTING], null)
	var has_camera: bool = user_settings_file.has_section(CameraConfig.NAME)
	if has_camera:
		user_settings_file.save(USER_SETTINGS_FILE)
	else:
		Logger.debug(_NO_OVERRIDE_RESULTS, [str(incoming_settings)], null)

## Appends incoming settings to existing override.cfg
static func _save_to_override(incoming_settings: Dictionary) -> void:
	# See if file exists
	var override_file: ConfigFile = ConfigFile.new()
	if FileAccess.file_exists(OVERRIDE_FILE):
		var file: FileAccess = FileAccess.open(OVERRIDE_FILE, FileAccess.READ)
		if file != null:
			# Use existing data or delete and reset if parse fails
			var error: Error = override_file.parse(file.get_as_text())
			if error != OK:
				override_file = ConfigFile.new()
				DirAccess.remove_absolute(OVERRIDE_FILE)
	# Get supported override categories and their keys
	var application_library: Dictionary = CONFIG_LIBRARY.get(ApplicationConfig.NAME) as Dictionary
	var debug_library: Dictionary = CONFIG_LIBRARY.get(DebugConfig.NAME) as Dictionary
	var display_library: Dictionary = CONFIG_LIBRARY.get(DisplayConfig.NAME) as Dictionary
	# Compare incoming keys to supported library keys
	var incoming_keys: Array = incoming_settings.keys()
	for incoming_key in incoming_keys:
		var incoming_value = incoming_settings.get(incoming_key)
		if debug_library.has(incoming_key):
			# Save the incoming key and value to the debug section of config file
			var debug_command: String = debug_library.get(incoming_key)
			override_file.set_value(DebugConfig.NAME, debug_command, incoming_value)
		elif application_library.has(incoming_key):
			# Save the incoming key and value to the application section of config file
			var application_command: String = application_library.get(incoming_key)
			override_file.set_value(ApplicationConfig.NAME, application_command, incoming_value)
		elif display_library.has(incoming_key):
			# Save the incoming key and value to the application section of config file
			var display_command: String = display_library.get(incoming_key)
			override_file.set_value(DisplayConfig.NAME, display_command, incoming_value)
		else:
			# Log that given key isn't currently supported and won't be saved to override
			Logger.debug(_NOT_SUPPORTED_KEY, [incoming_key, _OVERRIDE], null)
	var has_application: bool = override_file.has_section(ApplicationConfig.NAME)
	var has_debug: bool = override_file.has_section(DebugConfig.NAME)
	var has_display: bool = override_file.has_section(DisplayConfig.NAME)
	if has_application or has_debug or has_display:
		# Save new configuration as override
		override_file.save(OVERRIDE_FILE)
	else:
		Logger.debug(_NO_OVERRIDE_RESULTS, [str(incoming_settings)], null)

## Loads and returns the override.cfg file
## Returns null if no file exists
static func get_override_file() -> ConfigFile:
	return _load_file(OVERRIDE_FILE)

## Loads and returns the user_settings.cfg file
static func get_user_setting_file() -> ConfigFile:
	return _load_file(USER_SETTINGS_FILE)

static func _load_file(file_path: String) -> ConfigFile:
	var return_file: ConfigFile
	if FileAccess.file_exists(file_path):
		return_file = ConfigFile.new()
		var error: Error = return_file.load(file_path)
		if error != OK:
			Logger.error(_LOAD_FAIL, [file_path], null)
	else:
		var formatted_string: String = _FILE_NOT_FOUND + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
		Logger.debug(formatted_string, [file_path], null)
	return return_file
