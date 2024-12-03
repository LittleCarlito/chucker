extends Node3D
class_name ControlNode

const UNABLE_TO_OPEN_LOG: String = "Unable to open %s; Error: %s"
const EMPTY_SAVE_LOG:String = "Must provide settings to be saved; Input: %s"
const UNEXPTECTED_TYPE_LOG: String = "Save file object was not expected type"
const BAD_USER_INPUT_LOG: String = "Value from USER_INPUT \"%s\" could not be mapped to a GLOBAL_SETTING"
const NO_DEFAULT_LOG: String = "Global default value for settingName \"%s\" in category \"%s\" could not be found; Not updating control"
const NO_CATEGORY_LOG: String = "Category could not be extracted for \"%s\"; No control is being updated"

@onready var scorecard: ScorecardView = $ScorecardView
@onready var pauseMenu: PauseMenu = $PauseMenu
var BASE_PATH: String = "user://"
var SAVE_DIR: String = BASE_PATH + "settings/"
var SAVE_FILE: String = SAVE_DIR + "user_settings.json"

signal apply_settings
signal disable_movement
signal enable_movement

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create game file structures
	var baseDir = DirAccess.open(self.BASE_PATH)
	baseDir.make_dir(self.SAVE_DIR)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.PAUSE):
		self.pauseMenu.visible = true
		self.get_tree().paused = true
		self.set_process_input(false)
	if event.is_action_pressed(CONSTANTS.USER_INPUT.SCORE):
		disable_movement.emit()
		# Determine what camera is active so we know how big to make the scorecard
		var currentCamera: Camera3D = self.get_tree().root.get_camera_3d()
		if(currentCamera.name == CONSTANTS.TEE_CAMERA):
			self.scorecard.set_pixel_size(CONSTANTS.MENU.SCORECARD.TEEBOX_PIXEL_SIZE)
		else:
			self.scorecard.set_pixel_size(CONSTANTS.MENU.SCORECARD.PLAYER_PIXEL_SIZE)
		self.scorecard.scorecardSprite.visible = true
		self.get_viewport().get_camera_3d().look_at(scorecard.scorecardSprite.global_position)
	if event.is_action_released(CONSTANTS.USER_INPUT.SCORE):
		enable_movement.emit()
		self.scorecard.scorecardSprite.visible = false
		self.get_viewport().get_camera_3d().rotation = Vector3.ZERO

# Handling close menu signals
func _close_menu() -> void:
	self.pauseMenu.visible = false
	self.get_tree().paused = false
	self.set_process_input(true)

# Handling of save setting signals from sub menus
func _on_pause_menu_save_settings(saveSettings: Dictionary) -> void:
	self.save_to_settings(saveSettings)
	self.load_settings()

# Deletes existing setting save file and saves recieved dictionary to new file
func save_to_settings(saveSettings: Dictionary) -> void:
	# If settings file already exists delete it
	if FileAccess.file_exists(self.SAVE_FILE):
		DirAccess.remove_absolute(self.SAVE_FILE)
	if !saveSettings.is_empty():
		# Convert settings Dictionary to JSON
		var settingJson: String = JSON.stringify(saveSettings)
		# Write to settings file
		var file = FileAccess.open(self.SAVE_FILE, FileAccess.WRITE)
		if file != null:
			file.store_string(settingJson)
			file.close()
		else:
			var saveError: Error = FileAccess.get_open_error()
			Logger.error(self.UNABLE_TO_OPEN_LOG, [self.SAVE_FILE, saveError], self)
	else:
		Logger.error(self.EMPTY_SAVE_LOG,[saveSettings], self)

# Loads from settings file or default dictionaries if no file/setting
func load_settings() -> void:
	var userSettings: Array[String] = GlobalSettings.CONFIGURABLE_SETTINGS
	var dataReceived: Dictionary = self._get_settings_dictionary()
	for userSetting in userSettings:
		var settingCategory: String = GlobalSettings.extract_category(userSetting)
		if settingCategory != CONSTANTS.Unknown:
			if dataReceived.has(settingCategory):
				if settingCategory == CONSTANTS.Controls:
					var recievedCategory: Dictionary = dataReceived.get(settingCategory)
					if recievedCategory.has(userSetting):
						var settingValue = recievedCategory.get(userSetting)
						var controlSetting := settingValue as ControlSetting
						var controlInput: InputEvent = InputEventLibrary.convert_control_setting_to_input_event(controlSetting)
						var globalCategory: Dictionary = GlobalSettings.get_category(settingCategory)
						globalCategory.erase(userSetting)
						globalCategory.get_or_add(userSetting, controlInput)
					else:
						self.load_default(userSetting, settingCategory)
				else:
					var recievedCategory: Dictionary = dataReceived.get(settingCategory)
					if recievedCategory.has(userSetting):
						var settingValue = recievedCategory.get(userSetting)
						var globalCategory: Dictionary = GlobalSettings.get_category(settingCategory)
						globalCategory.erase(userSetting)
						globalCategory.get_or_add(userSetting, settingValue)
					else:
						self.load_default(userSetting, settingCategory)
			else:
				self.load_default(userSetting, settingCategory)
		else:
			Logger.error(NO_CATEGORY_LOG, [userSetting], self)

# Retrieves the settings file from User:// or returns an empty dictionary if an error occured
func _get_settings_dictionary() -> Dictionary:
	var returnDictionary: Dictionary = {}
	var file = FileAccess.open(self.SAVE_FILE, FileAccess.READ)
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
				Logger.error(UNEXPTECTED_TYPE_LOG, [], self)
	# 7 is could not open error
	elif FileAccess.get_open_error() != 7:
		var saveError: Error = FileAccess.get_open_error()
		Logger.error(self.UNABLE_TO_OPEN_LOG, [self.SAVE_FILE, saveError], self)
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
			Logger.error(NO_DEFAULT_LOG, [settingName, settingCategory], self)
	else:
		var defaultValue = globalDefaultCateogry.get(settingName)
		if defaultValue != null:
			var globalCategory: Dictionary = GlobalSettings.get_category(settingCategory)
			globalCategory.erase(settingName)
			globalCategory.get_or_add(settingName, defaultValue)
		else:
			Logger.error(NO_DEFAULT_LOG, [settingName, settingCategory], self)

# Reloads Project input settings using GlobalSettings
func reload_project_settings() -> void:
	var userInputs: Array = GlobalSettings.CONTROLS.keys()
	for userInput in userInputs:
		var boundKey: InputEvent = GlobalSettings.CONTROLS.get(userInput)
		if boundKey != null:
			InputMap.action_erase_events(userInput)
			InputMap.action_add_event(userInput, boundKey)
		else:
			Logger.error(BAD_USER_INPUT_LOG, [userInput], self)

func _apply_settings() -> void:
	apply_settings.emit()
