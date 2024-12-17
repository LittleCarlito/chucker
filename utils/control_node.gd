extends Node3D
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
const SAVE_FILE: String = SAVE_DIR + "user_settings.json"

@onready var scorecard: ScorecardView = $ScorecardView
@onready var pause_menu: PauseMenu = $PauseMenu

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
	load_settings()

# Deletes existing setting save file and saves recieved dictionary to new file
func save_to_settings(save_settings: Dictionary) -> void:
	# If settings file already exists delete it
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	if !save_settings.is_empty():
		# Convert settings Dictionary to JSON
		var setting_json: String = JSON.stringify(save_settings)
		# Write to settings file
		var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
		if file != null:
			file.store_string(setting_json)
			file.close()
		else:
			var saveError: Error = FileAccess.get_open_error()
			Logger.error(_UNABLE_TO_OPEN_LOG, [SAVE_FILE, saveError], self)
	else:
		Logger.error(_EMPTY_SAVE_LOG,[save_settings], self)

# TODO From a glance this seems like it needs to be refactored
# Loads from settings file or default dictionaries if no file/setting
func load_settings() -> void:
	var user_settings: Array[String] = GlobalSettings.CONFIGURABLE_SETTINGS
	var data_received: Dictionary = _get_settings_dictionary()
	for user_setting in user_settings:
		var setting_category: String = GlobalSettings.extract_category(user_setting)
		if setting_category != CONSTANTS.Unknown:
			if data_received.has(setting_category):
				if setting_category == CONSTANTS.Controls:
					var recieved_category: Dictionary = data_received.get(setting_category)
					if recieved_category.has(user_setting):
						var setting_value = recieved_category.get(user_setting)
						var control_setting := setting_value as ControlSetting
						var control_input: InputEvent = InputEventLibrary.convert_control_setting_to_input_event(control_setting)
						var global_category: Dictionary = GlobalSettings.get_category(setting_category)
						global_category.erase(user_setting)
						global_category.get_or_add(user_setting, control_input)
					else:
						load_default(user_setting, setting_category)
				else:
					var recieved_category: Dictionary = data_received.get(setting_category)
					if recieved_category.has(user_setting):
						var setting_value = recieved_category.get(user_setting)
						var global_category: Dictionary = GlobalSettings.get_category(setting_category)
						global_category.erase(user_setting)
						global_category.get_or_add(user_setting, setting_value)
					else:
						load_default(user_setting, setting_category)
			else:
				load_default(user_setting, setting_category)
		else:
			Logger.error(_NO_CATEGORY_LOG, [user_setting], self)

# Retrieves the settings file from User:// or returns an empty dictionary if an error occured
func _get_settings_dictionary() -> Dictionary:
	var returnDictionary: Dictionary = {}
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file != null:
		var json: JSON = JSON.new()
		var error: Error = json.parse(file.get_as_text())
		if error == OK:
			var retirevedData = json.data
			var expectedType: Variant.Type = TYPE_DICTIONARY
			if typeof(retirevedData) == expectedType:
				var incomingControlSettings: Dictionary = retirevedData.get(CONSTANTS.Controls, {})
				var incomingCameraSettings: Dictionary = retirevedData.get(CONSTANTS.Camera, {})
				var incomingDisplaySettings: Dictionary = retirevedData.get(CONSTANTS.Display, {})
				if !incomingControlSettings.is_empty():
					var controlSettings: Dictionary = {}
					var controlKeys: Array = incomingControlSettings.keys()
					for controlKey in controlKeys:
						var convertedSetting: ControlSetting = InputEventLibrary.convert_dictionary_to_control_setting(incomingControlSettings.get(controlKey))
						controlSettings.get_or_add(controlKey, convertedSetting)
					returnDictionary.get_or_add(CONSTANTS.Controls, controlSettings)
				if !incomingCameraSettings.is_empty():
					returnDictionary.get_or_add(CONSTANTS.Camera, incomingCameraSettings)
				if !incomingDisplaySettings.is_empty():
					returnDictionary.get_or_add(CONSTANTS.Display, incomingDisplaySettings)
			else:
				Logger.error(_UNEXPTECTED_TYPE_LOG, [], self)
	# 7 is could not open error
	elif FileAccess.get_open_error() != 7:
		var saveError: Error = FileAccess.get_open_error()
		Logger.error(_UNABLE_TO_OPEN_LOG, [SAVE_FILE, saveError], self)
	return returnDictionary

# Loads preconfigured default value for the given setting
func load_default(settingName: String, settingCategory: String) -> void:
	var globalDefaultCateogry: Dictionary = GlobalSettings.get_default_category(settingCategory)
	if settingCategory == CONSTANTS.Controls:
		var defaultSetting: InputEvent = globalDefaultCateogry.get(settingName)
		if defaultSetting != null:
			var globalCategory: Dictionary = GlobalSettings.get_category(settingCategory)
			globalCategory.erase(settingName)
			globalCategory.get_or_add(settingName, defaultSetting)
		else:
			Logger.error(_NO_DEFAULT_LOG, [settingName, settingCategory], self)
	else:
		var defaultValue = globalDefaultCateogry.get(settingName)
		if defaultValue != null:
			var globalCategory: Dictionary = GlobalSettings.get_category(settingCategory)
			globalCategory.erase(settingName)
			globalCategory.get_or_add(settingName, defaultValue)
		else:
			Logger.error(_NO_DEFAULT_LOG, [settingName, settingCategory], self)

# Reloads Project input settings using GlobalSettings
func reload_project_settings() -> void:
	var userInputs: Array = GlobalSettings.CONTROLS.keys()
	for userInput in userInputs:
		var boundKey: InputEvent = GlobalSettings.CONTROLS.get(userInput)
		if boundKey != null:
			InputMap.action_erase_events(userInput)
			InputMap.action_add_event(userInput, boundKey)
		else:
			Logger.error(_BAD_USER_INPUT_LOG, [userInput], self)

func _apply_settings() -> void:
	apply_settings.emit()
