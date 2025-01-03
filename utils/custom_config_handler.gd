extends Object
class_name CustomConfigHandler

# File pathways
const BASE_PATH: String = "user://"
const SAVE_DIR: String = BASE_PATH + "settings/"
const JSON_SAVE_FILE: String = SAVE_DIR + "user_settings.json"
const OVERRIDE_FILE: String = SAVE_DIR + "override.cfg"
# Application configs
const _APPLICATION: String = "application"
const _MAX_FPS: String = "run/max_fps"
# Debug configs
const _DEBUG: String = "debug"
const _DISPLAY_PERFORMANCE: String = "settings/stdout/print_fps"
# Display configs
const _DISPLAY: String = "display"
const _WINDOW_MODE:String = "window/size/mode"
const _WINDOW_SCALE: String = "window/stretch/scale"
const _WINDOW_BORDERLESS: String = "window/size/borderless"
const _WINDOW_INITIAL_POSITION: String = "window/size/initial_position_type" # 2 is centered on other screen; 1 is centered on Primary screen
const _WINDOW_INITIAL_SCREEN: String = "window/size/initial_screen" # INTIIAL_POSITION MUST but 2 for this to work; Determines what screen window is on

const CONFIG_LIBRARY: Dictionary = {
	_APPLICATION: {
		CONSTANTS.FPS_LOCK: _MAX_FPS
		},
	_DEBUG: {
		CONSTANTS.PERFORMANCE: _DISPLAY_PERFORMANCE
		},
	_DISPLAY: {
		CONSTANTS.WINDOW_MODE: _WINDOW_MODE,
		CONSTANTS.UI_SCALE: _WINDOW_SCALE,
		CONSTANTS.WINDOW_BORDERLESS: _WINDOW_BORDERLESS,
		CONSTANTS.WINDOW_INITIAL_POSITION: _WINDOW_INITIAL_POSITION,
		CONSTANTS.WINDOW_INITIAL_SCREEN: _WINDOW_INITIAL_SCREEN
	}
}

# TODO For override.cfg to work
#		Need to make ConfigurationFileHandler static class
#		Method takes in dictionary of setting names and values
#		Creates new ConfigurationFile object
#		Cycles through array of keys getting values
#			Checks what key it is and writes key/value pair to correct category in ConfigurationFile
#		After cycling it saves the ConfigurationFile as user://setting/override.cfg
# TODO When setting to window mode going to need to override borderless as well
# TODO Start with just graphics settings for above
# TODO Then convert control settings to use this

# TODO OOOOOO
# TODO Need to append settings onto exising file
## Deletes existing override.cfg and creates a new one out of the incoming data
static func _save_to_override(incoming_settings:Dictionary) -> void:
	var config_file: ConfigFile = ConfigFile.new()
	if FileAccess.file_exists(OVERRIDE_FILE):
		var file = FileAccess.open(OVERRIDE_FILE, FileAccess.READ)
		if file != null:
			var error: Error = config_file.parse(file.get_as_text())
			if error != OK:
				config_file = ConfigFile.new()
				DirAccess.remove_absolute(OVERRIDE_FILE)
	else:
		config_file = ConfigFile.new()
	var application_library: Dictionary = CONFIG_LIBRARY.get(_APPLICATION) as Dictionary
	var debug_library: Dictionary = CONFIG_LIBRARY.get(_DEBUG) as Dictionary
	var display_library: Dictionary = CONFIG_LIBRARY.get(_DISPLAY) as Dictionary
	var incoming_keys: Array = incoming_settings.keys()
	for incoming_key in incoming_keys:
		var incoming_value = incoming_settings.get(incoming_key)
		if debug_library.has(incoming_key):
			# Save the incoming key and value to the debug section of config file
			var debug_command: String = debug_library.get(incoming_key)
			config_file.set_value(_DEBUG, debug_command, incoming_value)
		elif application_library.has(incoming_key):
			# Save the incoming key and value to the application section of config file
			var application_command: String = application_library.get(incoming_key)
			config_file.set_value(_APPLICATION, application_command, incoming_value)
		elif display_library.has(incoming_key):
			# Save the incoming key and value to the application section of config file
			var display_command: String = display_library.get(incoming_key)
			config_file.set_value(_DISPLAY, display_command, incoming_value)
		else:
			# Log that given key isn't currently supported and won't be saved to override
			const _NOT_SUPPORTED_KEY: String = "Incoming key \"%s\" is currently not suported for override settings"
			Logger.debug(_NOT_SUPPORTED_KEY, [incoming_key], null)
	var has_application: bool = config_file.has_section(_APPLICATION)
	var has_debug: bool = config_file.has_section(_DEBUG)
	var has_display: bool = config_file.has_section(_DISPLAY)
	if has_application or has_debug or has_display:
		# Save new configuration as override
		config_file.save(OVERRIDE_FILE)
	else:
		const _NO_OVERRIDE_RESULTS: String = "No supported override results could be found for incoming setting dictionary \"%s\""
		Logger.debug(_NO_OVERRIDE_RESULTS, [str(incoming_settings)], null)
