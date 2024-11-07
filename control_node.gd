extends Node3D

@onready var scorecard: ScorecardView = $ScorecardView
@onready var pauseMenu: PauseMenu = $PauseMenu
var SAVE_PATH: String = "user://settings/user_settings.json"

signal apply_settings
signal disable_movement
signal enable_movement

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO Get logic working so settings can be loaded at scene startup
	#self.load_settings()
	pass

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

func _on_pause_menu_save_settings(saveSettings: Array[Dictionary]) -> void:
	self.save_to_settings(saveSettings)
	self.load_settings()

func save_to_settings(saveSettings: Array[Dictionary]) -> void:
	# TODO Get logic going to have this
	#		Create when no file found
	#		Update existing settings when file found
	#			Should only be updating fields in saveSettings Dictionary
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var saveJson: String = JSON.stringify(saveSettings)
	if saveJson != null:
		file.store_string(saveJson)

func load_settings() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file != null:
		var content: String = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var dataReceived: Dictionary = json.data
			var expectedType: Variant.Type = TYPE_ARRAY
			if typeof(dataReceived) == expectedType:
				# Control settings
				var controlSettings: Dictionary = dataReceived.get(CONSTANTS.Controls)
				if controlSettings != null:
					# TODO Redo all refs to be floats
					var aimSenseValue: float = controlSettings.get(CONSTANTS.HORIZONTAL_SENSITIVITY)
					if aimSenseValue != null:
						GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.HORIZONTAL_SENSITIVITY)
						GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.HORIZONTAL_SENSITIVITY, aimSenseValue)
					var lookSenseValue: float = controlSettings.get(CONSTANTS.VERTICAL_SENSITIVITY)
					if lookSenseValue != null:
						GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.VERTICAL_SENSITIVITY)
						GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.VERTICAL_SENSITIVITY, lookSenseValue)
					var vInversion: bool = controlSettings.get(CONSTANTS.INVERT_VERTICAL)
					if vInversion != null:
						GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.INVERT_VERTICAL)
						GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.INVERT_VERTICAL, vInversion)
					var hInversion: bool = controlSettings.get(CONSTANTS.INVERT_HORIZONTAL)
					if hInversion != null:
						GLOBAL_SETTINGS.CONTROLS.erase(CONSTANTS.INVERT_VERTICAL)
						GLOBAL_SETTINGS.CONTROLS.get_or_add(CONSTANTS.INVERT_VERTICAL, hInversion)
				# Camera settings
				var cameraSettings: Dictionary = dataReceived.get(CONSTANTS.Camera)
				if cameraSettings != null:
					var fovValue: int = cameraSettings.get(CONSTANTS.FOV)
					if fovValue != null:
						GLOBAL_SETTINGS.CAMERA.erase(CONSTANTS.FOV)
						GLOBAL_SETTINGS.CAMERA.get_or_add(CONSTANTS.FOV, fovValue)
				# Display settings
				var displaySettings: Dictionary = dataReceived.get(CONSTANTS.Display)
				if displaySettings != null:
					var performanceDisplay: bool = displaySettings.get(CONSTANTS.PERFORMANCE)
					if performanceDisplay != null:
						GLOBAL_SETTINGS.DISPLAY.erase(CONSTANTS.PERFORMANCE)
						GLOBAL_SETTINGS.DISPLAY.get_or_add(CONSTANTS.PERFORMANCE, performanceDisplay)
			else:
				Logger.error("%s in unexected format; Expected %s; File content: %s", [SAVE_PATH, expectedType, content], self)
		else:
			Logger.error("JSON Parse Error: %s in %s at line %s for file %s", [json.get_error_message(), content, json.get_error_line(), SAVE_PATH], self)
	self._apply_settings()

func _apply_settings() -> void:
	apply_settings.emit()
