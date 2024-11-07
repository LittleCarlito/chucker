extends Node3D
class_name ControlNode

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
	var baseDir = DirAccess.open(BASE_PATH)
	baseDir.make_dir(SAVE_DIR)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(USER_INPUT.MENU.MAIN):
		pauseMenu.visible = true
		get_tree().paused = true
		set_process_input(false)
	if event.is_action_pressed(USER_INPUT.MENU.SCORE):
		disable_movement.emit()
		# Determine what camera is active so we know how big to make the scorecard
		var currentCamera: Camera3D = get_tree().root.get_camera_3d()
		if(currentCamera.name == ASSET_MANAGEMENT.CAMERA.TEE_CAMERA):
			scorecard.set_pixel_size(GLOBAL_SETTINGS.MENU.SCORECARD.TEEBOX_PIXEL_SIZE)
		else:
			scorecard.set_pixel_size(GLOBAL_SETTINGS.MENU.SCORECARD.PLAYER_PIXEL_SIZE)
		scorecard.scorecardSprite.visible = true
		get_viewport().get_camera_3d().look_at(scorecard.scorecardSprite.global_position)
	if event.is_action_released(USER_INPUT.MENU.SCORE):
		enable_movement.emit()
		scorecard.scorecardSprite.visible = false
		get_viewport().get_camera_3d().rotation = Vector3.ZERO

func _close_menu() -> void:
	pauseMenu.visible = false
	get_tree().paused = false
	set_process_input(true)

func _on_pause_menu_save_settings(saveSettings: Dictionary) -> void:
	self.save_to_settings(saveSettings)
	self.load_settings()

func save_to_settings(saveSettings: Dictionary) -> void:
	if !saveSettings.is_empty():
		var finalSettings: Dictionary
		# If settings file already exists
		if FileAccess.file_exists(SAVE_FILE):
			finalSettings = self._update_settings(saveSettings)
		# If new save file
		else:
			finalSettings = saveSettings
		# Write to settings file
		var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
		if file != null:
			var saveJson: String = JSON.stringify(finalSettings)
			file.store_string(saveJson)
		else:
			var saveError: Error = FileAccess.get_open_error()
			var saveErrorString: String = "Unable to open %s; Error: %s"
			Logger.error(saveErrorString, [SAVE_FILE, saveError], self)
	else:
		var emptySaveErrorMessage = "Must provide settings to be saved; Input: %s"
		Logger.error(emptySaveErrorMessage,[saveSettings], self)

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
		if controlSettings.has(CONSTANTS.HORIZONTAL_SENSITIVITY):
			# TODO Make sure all sensitivity refs are floats and not ints
			var aimSenseValue: float = controlSettings.get(CONSTANTS.HORIZONTAL_SENSITIVITY)
			GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.HORIZONTAL_SENSITIVITY)
			GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.HORIZONTAL_SENSITIVITY, aimSenseValue)
		if controlSettings.has(CONSTANTS.VERTICAL_SENSITIVITY):
			var lookSenseValue: float = controlSettings.get(CONSTANTS.VERTICAL_SENSITIVITY)
			GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.VERTICAL_SENSITIVITY)
			GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.VERTICAL_SENSITIVITY, lookSenseValue)
		if controlSettings.has(CONSTANTS.INVERT_VERTICAL):
			var vInversion: bool = controlSettings.get(CONSTANTS.INVERT_VERTICAL)
			GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.INVERT_VERTICAL)
			GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.INVERT_VERTICAL, vInversion)
		if controlSettings.has(CONSTANTS.INVERT_HORIZONTAL):
			var hInversion: bool = controlSettings.get(CONSTANTS.INVERT_HORIZONTAL)
			GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.INVERT_VERTICAL)
			GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.INVERT_VERTICAL, hInversion)
	# Camera settings
	if dataReceived.has(CONSTANTS.Camera):
		var cameraSettings: Dictionary = dataReceived.get(CONSTANTS.Camera)
		var fovValue: int = cameraSettings.get(CONSTANTS.FOV)
		if fovValue != null:
			GLOBAL_SETTINGS.CAMERA.erase(CONSTANTS.FOV)
			GLOBAL_SETTINGS.CAMERA.get_or_add(CONSTANTS.FOV, fovValue)
	# Display settings
	if dataReceived.has(CONSTANTS.Display):
		var displaySettings: Dictionary = dataReceived.get(CONSTANTS.Display)
		var performanceDisplay: bool = displaySettings.get(CONSTANTS.PERFORMANCE)
		if performanceDisplay != null:
			GLOBAL_SETTINGS.DISPLAY.erase(CONSTANTS.PERFORMANCE)
			GLOBAL_SETTINGS.DISPLAY.get_or_add(CONSTANTS.PERFORMANCE, performanceDisplay)

# Retrieves the settings file from User:// or returns an empty dictionary if an error occured
func _get_settings_dictionary() -> Dictionary:
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
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
					Logger.error("%s in unexected format; Expected %s; File content: %s", [SAVE_FILE, expectedType, content], self)
			else:
				Logger.error("JSON Parse Error: \"%s\" in \"%s\" at line \"%s\" for file \"%s\"", [json.get_error_message(), content, json.get_error_line(), SAVE_FILE], self)
		else:
			var saveError: Error = FileAccess.get_open_error()
			var saveErrorString: String = "Unable to open %s; Error: %s"
			Logger.error(saveErrorString, [SAVE_FILE, saveError], self)
	return {}

func _apply_settings() -> void:
	apply_settings.emit()
