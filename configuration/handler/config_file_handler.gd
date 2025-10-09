extends Node
class_name ConfigFileHandler

# Log messages
const _CATEGORY_ERASED: String = "Category %s has been erased from file %s"
const _MISSING_CATEGORY: String = "File %s was missing category %s"
const _NOT_DELETING: String = "Not deleting requested file type \"%s\" and category \"%s\""
const _FILE_NOT_FOUND: String = "Requested file %s was not found"
const _NO_OVERRIDE_RESULTS: String = "No supported override results could be found for incoming setting dictionary \"%s\""
const _NOT_SUPPORTED_KEY: String = "Incoming key \"%s\" is currently not suported for %s settings"
const _OVERRIDE: String = "override"
const _USER_SETTING: String = "user_setting"
const _LOAD_FAIL: String = "Failure loading from path %s"
# File pathways
const BASE_PATH: String = "user://"
const SAVE_DIR: String = BASE_PATH + "settings/"
const OVERRIDE_FILE: String = SAVE_DIR + "override.cfg"
const USER_SETTINGS_FILE: String = SAVE_DIR + "user_settings.cfg"
# Application configs
const _MAX_FPS: String = "run/max_fps"

enum FILE_TYPE {
	OVERRIDE,
	USER_SETTING
}

const PATH_LIBRARY = {
	FILE_TYPE.OVERRIDE: OVERRIDE_FILE,
	FILE_TYPE.USER_SETTING: USER_SETTINGS_FILE
}

func _ready() -> void:
	# Create game file structures
	var base_dir = DirAccess.open(BASE_PATH)
	base_dir.make_dir(SAVE_DIR)

## Appends incoming settings to exsting user_settings.cfg
## Deletes existing category data if parameter requesting it is passed in
static func save_to_user_settings(incoming_settings: Dictionary) -> void:
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
	# Get supported libraries
	var camera_library: Dictionary = CameraConfig.CONFIG_LIBRARY
	var input_library: Dictionary = InputConfig.CONFIG_LIBRARY
	# Process given keys and match it to supported categories
	var incoming_keys: Array = incoming_settings.keys()
	for incoming_key in incoming_keys:
		var incoming_value = incoming_settings.get(incoming_key)
		if camera_library.has(incoming_key):
			var camera_command: String = camera_library.get(incoming_key)
			user_settings_file.set_value(CameraConfig.NAME, camera_command, incoming_value)
		elif input_library.has(incoming_key):
			var input_command: String = input_library.get(incoming_key)
			user_settings_file.set_value(InputConfig.NAME, input_command, incoming_value)
		else:
			Log.debug(_NOT_SUPPORTED_KEY, [incoming_key, _USER_SETTING], null)
	# See if user_settings file has any generated data
	var has_camera: bool = user_settings_file.has_section(CameraConfig.NAME)
	var has_input: bool = user_settings_file.has_section(InputConfig.NAME)
	if has_camera or has_input:
		user_settings_file.save(USER_SETTINGS_FILE)
	else:
		Log.debug(_NO_OVERRIDE_RESULTS, [str(incoming_settings)], null)

## Appends incoming settings to existing override.cfg
static func save_to_override(incoming_settings: Dictionary) -> void:
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
	var application_library: Dictionary = ApplicationConfig.CONFIG_LIBRARY
	var debug_library: Dictionary = DebugConfig.CONFIG_LIBRARY
	var display_library: Dictionary = DisplayConfig.CONFIG_LIBRARY
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
			Log.debug(_NOT_SUPPORTED_KEY, [incoming_key, _OVERRIDE], null)
	# Check if override file generated any output
	var has_application: bool = override_file.has_section(ApplicationConfig.NAME)
	var has_debug: bool = override_file.has_section(DebugConfig.NAME)
	var has_display: bool = override_file.has_section(DisplayConfig.NAME)
	if has_application or has_debug or has_display:
		# Save new configuration as override
		override_file.save(OVERRIDE_FILE)
	else:
		Log.debug(_NO_OVERRIDE_RESULTS, [str(incoming_settings)], null)

## Loads and returns the override.cfg file
## Returns null if no file exists
static func get_override_file() -> ConfigFile:
	return _load_file(OVERRIDE_FILE)

## Loads and returns the user_settings.cfg file
static func get_user_setting_file() -> ConfigFile:
	return _load_file(USER_SETTINGS_FILE)

static func _load_file(file_path: String) -> ConfigFile:
	var return_file: ConfigFile = ConfigFile.new()
	if FileAccess.file_exists(file_path):
		var error: Error = return_file.load(file_path)
		if error != OK:
			Log.error(_LOAD_FAIL, [file_path], null)
	else:
		var formatted_string: String = _FILE_NOT_FOUND + Log.LOG_SEPARATOR + Log.RETURNING_NULL_LOG
		Log.debug(formatted_string, [file_path], null)
	return return_file

## Deletes the given category from the desired file if it exists
static func delete_file_category(file_type: FILE_TYPE, file_category: String) -> void:
	var updating_file: ConfigFile
	match file_type:
		FILE_TYPE.OVERRIDE:
			updating_file = get_override_file()
		FILE_TYPE.USER_SETTING:
			updating_file = get_user_setting_file()
	if updating_file != null:
		if updating_file.has_section(file_category):
			updating_file.erase_section(file_category)
			updating_file.save(PATH_LIBRARY.get(file_type))
			Log.debug(_CATEGORY_ERASED, [file_category, str(file_type)], null)
		else:
			var formatted_string: String = _MISSING_CATEGORY + Log.LOG_SEPARATOR + _NOT_DELETING
			Log.debug(formatted_string, [str(file_type), file_category, str(file_type), file_category], null)
	else:
		var formatted_string: String = _FILE_NOT_FOUND + Log.LOG_SEPARATOR + _NOT_DELETING
		Log.debug(formatted_string, [str(file_type), str(file_type), file_category], null)
