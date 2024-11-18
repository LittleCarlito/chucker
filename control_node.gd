extends Node3D
class_name ControlNode

const UNABLE_TO_OPEN_LOG: String = "Unable to open %s; Error: %s"
const EMPTY_SAVE_LOG:String = "Must provide settings to be saved; Input: %s"
const UNEXPTECTED_TYPE_LOG: String = "Save file object was not expected type %s; Saved object type \"%s\""
const BAD_SAVE_FILE_LOG: String = "Save Dictionary contained more than the 1 expected item; Contained \"%d\" items"
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
	# TODO InputMap doesn't have actions; Either need to be added through code or code is removing them on accident
	#			Or "input/" needs to be appended when 

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
		if(currentCamera.name == AssetManagement.CAMERA.TEE_CAMERA):
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

# TODO Refactor this to use file.set_vars instead of using JSON
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
			# TODO If this works see if setting this to false works too
			#		Otherwise will need some kind of executable scanning because the loading of this could be used to inject code
			file.store_var(finalSettings, true)
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

# TODO Broken start here
func load_settings() -> void:
	var dataReceived: Dictionary = self._get_settings_dictionary()
	# Controls
	if dataReceived.has(CONSTANTS.Controls):
		var controlSettings: Dictionary = dataReceived.get(CONSTANTS.Controls)
		for controlKey in GlobalSettings.CONTROLS.keys():
			if controlSettings.has(controlKey):
				var controlInput: InputEvent = controlSettings.get(controlKey)
				GlobalSettings.CONTROLS.erase(controlKey)
				GlobalSettings.CONTROLS.get_or_add(controlKey, controlInput)
	# Camera settings
	if dataReceived.has(CONSTANTS.Camera):
		var cameraSettings: Dictionary = dataReceived.get(CONSTANTS.Camera)
		for cameraKey in GlobalSettings.CAMERA.keys():
			if cameraSettings.has(cameraKey):
				var cameraSettingValue: Variant = cameraSettings.get(cameraKey)
				GlobalSettings.CAMERA.erase(cameraKey)
				GlobalSettings.CAMERA.get_or_add(cameraKey, cameraSettingValue)
	# Display settings
	if dataReceived.has(CONSTANTS.Display):
		var displaySettings: Dictionary = dataReceived.get(CONSTANTS.Display)
		for displayKey in GlobalSettings.DISPLAY.keys():
			if displaySettings.has(displayKey):
				var displaySettingValue: Variant = displaySettings.get(displayKey)
				GlobalSettings.DISPLAY.erase(displayKey)
				GlobalSettings.DISPLAY.get_or_add(displayKey, displaySettingValue)

# Retrieves the settings file from User:// or returns an empty dictionary if an error occured
# TODO Will have to be refactored to not be get_var store_var because that is a security issue
#		Even if you add encryption its still unecessary and a risk if key got leaked
# TODO For the moment adding a key and encrypting it could be fun though
func _get_settings_dictionary() -> Dictionary:
	var file = FileAccess.open(self.SAVE_FILE, FileAccess.READ)
	if file != null:
		if file.get_reference_count() == 1:
			var storedObject = file.get_var(true)
			var expectedType: Variant.Type = TYPE_DICTIONARY
			var storedType: Variant.Type = typeof(storedObject)
			if typeof(storedObject) == expectedType:
				return storedObject
			else:
				Logger.error(UNEXPTECTED_TYPE_LOG, [expectedType, storedType], self)
		else:
			Logger.error(self.BAD_SAVE_FILE_LOG, [file.get_reference_count()], self)
	elif FileAccess.get_open_error() != 7:
		var saveError: Error = FileAccess.get_open_error()
		Logger.error(self.UNABLE_TO_OPEN_LOG, [self.SAVE_FILE, saveError], self)
	return {}

# Reloads Project input settings using GlobalSettings
func reload_project_settings() -> void:
	var userInputs: Array = GlobalSettings.CONTROLS.keys()
	for userInput in userInputs:
		var boundKey: InputEvent = GlobalSettings.CONTROLS.get(userInput)
		if boundKey != null:
			InputMap.erase_action(userInput)
			InputMap.action_add_event(userInput, boundKey)
		else:
			Logger.error(BAD_USER_INPUT_LOG, [userInput], self)

func _apply_settings() -> void:
	apply_settings.emit()
