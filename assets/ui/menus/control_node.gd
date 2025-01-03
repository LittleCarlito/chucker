extends Node3D
# TOOD Rename to MenuControlNode
class_name ControlNode

# TODO Refactor out reading/writing logic to a Global utility script

const _UNABLE_TO_OPEN_LOG: String = "Unable to open %s; Error: %s"
const _EMPTY_SAVE_LOG:String = "Must provide settings to be saved; Input: %s"
const _UNEXPTECTED_TYPE_LOG: String = "Save file object was not expected type"
const _BAD_USER_INPUT_LOG: String = "Value from USER_INPUT \"%s\" could not be mapped to a GLOBAL_SETTING"
const _NO_DEFAULT_LOG: String = "Global default value for settingName \"%s\" in category \"%s\" could not be found; Not updating control"
const _NO_CATEGORY_LOG: String = "Category could not be extracted for \"%s\"; No control is being updated"
# TODO Move to file utility
const BASE_PATH: String = "user://"
const SAVE_DIR: String = BASE_PATH + "settings/"
const JSON_SAVE_FILE: String = SAVE_DIR + "user_settings.json"
const OVERRIDE_FILE: String = SAVE_DIR + "override.cfg"

@export var scorecard: ScorecardView
@export var pause_menu: PauseMenu

signal apply_settings
signal disable_movement
signal disable_rotation
signal enable_movement
signal enable_rotation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create game file structures
	var base_dir = DirAccess.open(BASE_PATH)
	base_dir.make_dir(SAVE_DIR)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.PAUSE):
		pause_menu.visible = true
		self.get_tree().paused = true
		self.set_process_input(false)
	if event.is_action_pressed(CONSTANTS.USER_INPUT.SCORE):
		disable_movement.emit()
		disable_rotation.emit()
		# Determine what camera is active so we know how big to make the scorecard
		var current_camera: Camera3D = self.get_tree().root.get_camera_3d()
		if(current_camera.name == CONSTANTS.TEE_CAMERA):
			scorecard.set_pixel_size(CONSTANTS.MENU.SCORECARD.TEEBOX_PIXEL_SIZE)
		else:
			scorecard.set_pixel_size(CONSTANTS.MENU.SCORECARD.PLAYER_PIXEL_SIZE)
		scorecard.scorecardSprite.visible = true
		self.get_viewport().get_camera_3d().look_at(scorecard.scorecardSprite.global_position)
	if event.is_action_released(CONSTANTS.USER_INPUT.SCORE):
		enable_movement.emit()
		enable_rotation.emit()
		scorecard.scorecardSprite.visible = false
		self.get_viewport().get_camera_3d().rotation = Vector3.ZERO

# Handling close menu signals
func _close_menu() -> void:
	pause_menu.visible = false
	self.get_tree().paused = false
	self.set_process_input(true)

# Handling of save setting signals from sub menus
func _on_pause_menu_save_settings(save_settings: Dictionary) -> void:
	save_to_settings(save_settings)

# Deletes existing setting save file and saves recieved dictionary to new file
func save_to_settings(save_settings: Dictionary) -> void:
	var display_settings: Dictionary = save_settings.get(DisplayConfig.NAME, {}) as Dictionary
	if !display_settings.is_empty():
		save_settings.erase(DisplayConfig.NAME)
	# If settings file already exists delete it
	if FileAccess.file_exists(JSON_SAVE_FILE):
		DirAccess.remove_absolute(JSON_SAVE_FILE)
	if !save_settings.is_empty():
		# Convert settings Dictionary to JSON
		var setting_json: String = JSON.stringify(save_settings)
		# Write to settings file
		var file = FileAccess.open(JSON_SAVE_FILE, FileAccess.WRITE)
		if file != null:
			file.store_string(setting_json)
			file.close()
		else:
			var saveError: Error = FileAccess.get_open_error()
			Logger.debug(_UNABLE_TO_OPEN_LOG, [JSON_SAVE_FILE, saveError], self)
	else:
		Logger.debug(_EMPTY_SAVE_LOG,[save_settings], self)

## Loads from settings file or default dictionaries if no file/setting
func load_settings() -> void:
	var user_settings: Array[String] = GlobalSettings.CONFIGURABLE_SETTINGS
	var data_received: Dictionary = _get_settings_dictionary()
	for user_setting in user_settings:
		var setting_category: String = GlobalSettings.extract_category(user_setting)
		if setting_category != CONSTANTS.Unknown:
			if data_received.has(setting_category):
				# Controls loading handling
				if setting_category == CONSTANTS.Controls:
					var recieved_category: Dictionary = data_received.get(setting_category)
					if recieved_category.has(user_setting):
						var setting_value = recieved_category.get(user_setting)
						var control_setting := setting_value as ControlSetting
						var control_input: InputEvent = InputEventLibrary.convert_control_setting_to_input_event(control_setting)
						var global_category: Dictionary = GlobalSettings.get_category(setting_category)
						global_category.erase(user_setting)
						global_category[user_setting] = control_input
					else:
						load_default(user_setting, setting_category)
				# Display loading handling
				elif setting_category == DisplayConfig.NAME:
					var recieved_category: Dictionary = data_received.get(setting_category)
					if recieved_category.has(user_setting):
						var setting_value = recieved_category.get(user_setting)
						match user_setting:
							DisplayConfig.UI_SCALE:
								get_tree().root.set_content_scale_factor(setting_value)
							DisplayConfig.WINDOW_MODE:
								get_window().set_mode(setting_value)
							ApplicationConfig.FPS_LOCK:
								Engine.set_max_fps(setting_value)
							DisplayConfig.WINDOW_INITIAL_SCREEN:
								var current_window: Window = get_window()
								var previous_mode: Window.Mode = current_window.mode
								current_window.set_mode(Window.MODE_WINDOWED)
								DisplayServer.window_set_current_screen(setting_value, current_window.get_window_id())
								current_window.set_mode(previous_mode)
							DebugConfig.PERFORMANCE:
								# TODO Implement some display for this
								pass
					else:
						load_default(user_setting, setting_category)
				else:
					var recieved_category: Dictionary = data_received.get(setting_category)
					if recieved_category.has(user_setting):
						var setting_value = recieved_category.get(user_setting)
						var global_category: Dictionary = GlobalSettings.get_category(setting_category)
						global_category.erase(user_setting)
						global_category[user_setting] = setting_value
					else:
						load_default(user_setting, setting_category)
			else:
				load_default(user_setting, setting_category)
		else:
			Logger.error(_NO_CATEGORY_LOG, [user_setting], self)
	reload_project_settings()
	pause_menu.reload_ui()

# Retrieves the settings file from User:// or returns an empty dictionary if an error occured
func _get_settings_dictionary() -> Dictionary:
	var return_dictionary: Dictionary = {}
	var file = FileAccess.open(JSON_SAVE_FILE, FileAccess.READ)
	if file != null:
		var json: JSON = JSON.new()
		var error: Error = json.parse(file.get_as_text())
		if error == OK:
			var retireved_data = json.data
			var expected_type: Variant.Type = TYPE_DICTIONARY
			if typeof(retireved_data) == expected_type:
				var incoming_control_settings: Dictionary = retireved_data.get(CONSTANTS.Controls, {})
				var incoming_camera_settings: Dictionary = retireved_data.get(CONSTANTS.Camera, {})
				var incoming_display_settings: Dictionary = retireved_data.get(DisplayConfig.NAME, {})
				if !incoming_control_settings.is_empty():
					var control_settings: Dictionary = {}
					var control_keys: Array = incoming_control_settings.keys()
					for control_key in control_keys:
						var convertedSetting: ControlSetting = InputEventLibrary.convert_dictionary_to_control_setting(incoming_control_settings.get(control_key))
						control_settings[control_key] = convertedSetting
					return_dictionary[CONSTANTS.Controls] = control_settings
				if !incoming_camera_settings.is_empty():
					return_dictionary[CONSTANTS.Camera] = incoming_camera_settings
				if !incoming_display_settings.is_empty():
					return_dictionary[DisplayConfig.NAME] = incoming_display_settings
			else:
				Logger.error(_UNEXPTECTED_TYPE_LOG, [], self)
	# 7 is could not open error
	elif FileAccess.get_open_error() != 7:
		var save_error: Error = FileAccess.get_open_error()
		Logger.error(_UNABLE_TO_OPEN_LOG, [JSON_SAVE_FILE, save_error], self)
	return return_dictionary

# Loads preconfigured default value for the given setting
func load_default(setting_name: String, setting_category: String) -> void:
	var global_default_cateogry: Dictionary = GlobalSettings.get_default_category(setting_category)
	if setting_category == CONSTANTS.Controls:
		var default_setting: InputEvent = global_default_cateogry.get(setting_name)
		if default_setting != null:
			var global_category: Dictionary = GlobalSettings.get_category(setting_category)
			global_category.erase(setting_name)
			global_category[setting_name] = default_setting
		else:
			Logger.error(_NO_DEFAULT_LOG, [setting_name, setting_category], self)
	else:
		var default_value = global_default_cateogry.get(setting_name)
		if default_value != null:
			var global_category: Dictionary = GlobalSettings.get_category(setting_category)
			global_category.erase(setting_name)
			global_category[setting_name] = default_value
		else:
			Logger.error(_NO_DEFAULT_LOG, [setting_name, setting_category], self)

## Reloads Project input settings using GlobalSettings
func reload_project_settings() -> void:
	var user_inputs: Array = GlobalSettings.CONTROLS.keys()
	for user_input in user_inputs:
		var bound_key: InputEvent = GlobalSettings.CONTROLS.get(user_input) as InputEvent
		if bound_key != null:
			InputMap.action_erase_events(user_input)
			InputMap.action_add_event(user_input, bound_key)
		else:
			Logger.error(_BAD_USER_INPUT_LOG, [user_input], self)

func _apply_settings() -> void:
	apply_settings.emit()
