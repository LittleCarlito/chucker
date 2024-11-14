extends Node3D
class_name ControlNode

const UNABLE_TO_OPEN_LOG: String = "Unable to open %s; Error: %s"
const EMPTY_SAVE_LOG:String = "Must provide settings to be saved; Input: %s"
const UNEXPTECTED_FORMAT_LOG: String = "%s in unexected format; Expected %s; File content: %s"
const JSON_ERROR_LOG: String = "JSON Parse Error: \"%s\" in \"%s\" at line \"%s\" for file \"%s\""
const BAD_USER_INPUT_LOG: String = "Value from USER_INPUT \"%s\" could not be mapped to a GLOBAL_SETTING"

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
	if event.is_action_pressed(CONSTANTS.USER_INPUT.MAIN):
		self.pauseMenu.visible = true
		self.get_tree().paused = true
		self.set_process_input(false)
	if event.is_action_pressed(CONSTANTS.USER_INPUT.SCORE):
		disable_movement.emit()
		# Determine what camera is active so we know how big to make the scorecard
		var currentCamera: Camera3D = self.get_tree().root.get_camera_3d()
		if(currentCamera.name == ASSET_MANAGEMENT.CAMERA.TEE_CAMERA):
			self.scorecard.set_pixel_size(CONSTANTS.MENU.SCORECARD.TEEBOX_PIXEL_SIZE)
		else:
			self.scorecard.set_pixel_size(CONSTANTS.MENU.SCORECARD.PLAYER_PIXEL_SIZE)
		self.scorecard.scorecardSprite.visible = true
		self.get_viewport().get_camera_3d().look_at(scorecard.scorecardSprite.global_position)
	if event.is_action_released(CONSTANTS.USER_INPUT.SCORE):
		enable_movement.emit()
		self.scorecard.scorecardSprite.visible = false
		self.get_viewport().get_camera_3d().rotation = Vector3.ZERO

func _close_menu() -> void:
	self.pauseMenu.visible = false
	self.get_tree().paused = false
	self.set_process_input(true)

func _on_pause_menu_save_settings(saveSettings: Dictionary) -> void:
	self.save_to_settings(saveSettings)
	self.load_settings()

func save_to_settings(saveSettings: Dictionary) -> void:
	if !saveSettings.is_empty():
		var finalSettings: Dictionary
		# If settings file already exists
		if FileAccess.file_exists(self.SAVE_FILE):
			finalSettings = self._update_settings(saveSettings)
		# If new save file
		else:
			finalSettings = saveSettings
		# Write to settings file
		var file = FileAccess.open(self.SAVE_FILE, FileAccess.WRITE)
		if file != null:
			var saveJson: String = JSON.stringify(finalSettings)
			file.store_string(saveJson)
		else:
			var saveError: Error = FileAccess.get_open_error()
			Logger.error(self.UNABLE_TO_OPEN_LOG, [self.SAVE_FILE, saveError], self)
	else:
		Logger.error(self.EMPTY_SAVE_LOG,[saveSettings], self)

func _update_settings(saveSettings: Dictionary) -> Dictionary:
	var settingsDictionary = self._get_settings_dictionary()
	var saveCategories: Array = saveSettings.keys()
	for category in saveCategories:
		# See if settings have primary setting category
		if settingsDictionary.has(category):
			var settingCategory: Dictionary = settingsDictionary.get(category)
			var saveAttributes: Dictionary = saveSettings.get(category)
			var saveAttributeKeys: Array = saveAttributes.keys()
			for attribute in saveAttributeKeys:
				# See if settings category contains the updated attribute
				if settingCategory.has(attribute):
					settingCategory.erase(attribute)
				settingCategory.get_or_add(attribute, saveAttributes.get(attribute))
		# If missing setting category add the entire thing
		else:
			settingsDictionary.get_or_add(category, saveSettings.get(category))
	return settingsDictionary

func load_settings() -> void:
	var dataReceived: Dictionary = self._get_settings_dictionary()	
	# Control settings
	if dataReceived.has(CONSTANTS.Controls):
		var controlSettings: Dictionary = dataReceived.get(CONSTANTS.Controls)
		for controlKey in GLOBAL_SETTINGS.CONTROLS.keys():
			if controlSettings.has(controlKey):
				var controlSettingValue: Variant = controlSettings.get(controlKey)
				GLOBAL_SETTINGS.CONTROLS.erase(controlKey)
				GLOBAL_SETTINGS.CONTROLS.get_or_add(controlKey, controlSettingValue)
	# Camera settings
	if dataReceived.has(CONSTANTS.Camera):
		var cameraSettings: Dictionary = dataReceived.get(CONSTANTS.Camera)
		for cameraKey in GLOBAL_SETTINGS.CAMERA.keys():
			if cameraSettings.has(cameraKey):
				var cameraSettingValue: Variant = cameraSettings.get(cameraKey)
				GLOBAL_SETTINGS.CAMERA.erase(cameraKey)
				GLOBAL_SETTINGS.CAMERA.get_or_add(cameraKey, cameraSettingValue)
	# Display settings
	if dataReceived.has(CONSTANTS.Display):
		var displaySettings: Dictionary = dataReceived.get(CONSTANTS.Display)
		for displayKey in GLOBAL_SETTINGS.DISPLAY.keys():
			if displaySettings.has(displayKey):
				var displaySettingValue: Variant = displaySettings.get(displayKey)
				GLOBAL_SETTINGS.DISPLAY.erase(displayKey)
				GLOBAL_SETTINGS.DISPLAY.get_or_add(displayKey, displaySettingValue)

# Retrieves the settings file from User:// or returns an empty dictionary if an error occured
func _get_settings_dictionary() -> Dictionary:
	var file = FileAccess.open(self.SAVE_FILE, FileAccess.READ)
	if file != null:
		var content: String = file.get_as_text()
		if not content.is_empty():
			var json = JSON.new()
			var error = json.parse(content)
			if error == OK:
				var dataReceived: Dictionary = json.data
				var expectedType: Variant.Type = TYPE_DICTIONARY
				if typeof(dataReceived) == expectedType:
					return dataReceived
				else:
					Logger.error(self.UNEXPTECTED_FORMAT_LOG, [self.SAVE_FILE, expectedType, content], self)
			else:
				Logger.error(self.JSON_ERROR_LOG, [json.get_error_message(), content, json.get_error_line(), self.SAVE_FILE], self)
		else:
			var saveError: Error = FileAccess.get_open_error()
			Logger.error(self.UNABLE_TO_OPEN_LOG, [self.SAVE_FILE, saveError], self)
	return {}

# TODO I don't think reloading Project_Settings is possible at runtime
# Reloads Project input settings using GLOBAL_SETTINGS
func reload_project_settings() -> void:
	# TODO Iterate over each USER_INPUT setting and get the associate project setting string
	#		Then get the GLOBAL_SETTING associated to that project setting
	#		Then overwrite the ProjectSetting for that key
	# TODO Ensure you are saving ProjectSetting and make is so the application doesn't have to be restarted
	var userInputs: Array = CONSTANTS.USER_INPUT.values()
	for userInput in userInputs:
		# TODO userInput should be the GLOBAL_SETTING version of the control
		var boundKeyCode: int = GLOBAL_SETTINGS.CONTROLS.get(userInput)
		if boundKeyCode != null:
			# TODO Get "input/" to a constant
			#ProjectSettings.set_setting("input/" + userInput, boundKeyCode)
			var inputEvent = InputEventKey.new()
			inputEvent.scancode = boundKeyCode
			InputMap.erase_action(userInput)
			InputMap.action_add_event(userInput, inputEvent)
		else:
			Logger.error(BAD_USER_INPUT_LOG, [userInput], self)
	#ProjectSettings.save()

func _apply_settings() -> void:
	apply_settings.emit()
