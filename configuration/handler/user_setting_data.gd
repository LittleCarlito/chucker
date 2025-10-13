extends Node

# TODO Refactor this and override to extend config-file_handler
#		put get get_category_value and get_category methods in the parent class
#		both then are responsible for saving/loading their respective files only

const _NO_CATEGORY_MATCH: String = "No configuration match or default match could be found for incoming category name \"%s\" and key \"%s\""
const _CATEGORY_NOT_FOUND: String = "Requested category \"%s\" was not found in user_settings.cfg"
const _NO_FILE_FOUND: String = "No user_settings file found; Using default controls"

var _user_data: ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(GroupData.CONFIG_HANDLER)
	_reload_data()
	call_deferred("reload_project_settings")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _reload_data() -> void:
	_user_data = ConfigFileHandler.get_user_setting_file()

## Returns the configured value for the category
func get_category_value(category_name: String, category_key: String):
	var category_value
	if _user_data.has_section_key(category_name, category_key):
		category_value = _user_data.get_value(category_name, category_key)
	else:
		var category_dictionary: Dictionary = DefaultLibrary.DEFAULTS.get(category_name, {}) as Dictionary
		if !category_dictionary.is_empty():
			if category_dictionary.has(category_key):
				category_value = category_dictionary.get(category_key)
	if category_value == null:
		var formatted_string: String = _NO_CATEGORY_MATCH + Log.LOG_SEPARATOR + Log.RETURNING_INT16_MAX
		Log.debug(formatted_string, [category_name, category_key], self)
	return category_value

## Returns the requested category as a Dictionary
func get_category(category_name: String, surpress_logs: bool = false) -> Dictionary:
	var category_dictionary: Dictionary = {}
	if _user_data.has_section(category_name):
		var category_keys: Array = _user_data.get_section_keys(category_name)
		for category_key in category_keys:
			var category_value = _user_data.get_value(category_name, category_key)
			category_dictionary[category_key] = category_value
	if category_dictionary.is_empty() and !surpress_logs:
		Log.debug(_CATEGORY_NOT_FOUND, [category_name], self)
	return category_dictionary

## Reloads Project input settings using user_settings
func reload_project_settings() -> void:
	# Get user settings file
	var input_dictionary: Dictionary = UserSettingData.get_category(InputConfig.NAME)
	# Iterate through existing settings and apply controls
	if !input_dictionary.is_empty():
		var update_controls: Array = input_dictionary.keys()
		for update_control in update_controls:
			var bound_input: InputEvent = input_dictionary.get(update_control)
			InputMap.action_erase_events(update_control)
			InputMap.action_add_event(update_control, bound_input)
	else:
		Log.debug(_NO_FILE_FOUND, [], self)
