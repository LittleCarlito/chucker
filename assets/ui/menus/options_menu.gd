extends Control

@onready var fovSlider: HSlider = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Controls/ControlsRows/TopOptionColumns/TopSliderColumns/TopSliderRows/FoVSliderPanel/FovLabelRows/FovSliderColumns/FovSliderContainer/FovSlider
@onready var aimSensitivitySlider: HSlider = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Controls/ControlsRows/TopOptionColumns/TopSliderColumns/TopSliderRows/AimSensitivityPanel/AimSensitivityRows/AimSensitivityColumns/AimSensitvitySliderContainer/AimSensitivitySlider
@onready var lookSensitivitySlider: HSlider = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Controls/ControlsRows/TopOptionColumns/TopSliderColumns/TopSliderRows/LookSensitivityPanel/LookSensitivityRows/LookSensitivityColumns/LookSensitvitySliderContainer/LookSensitivitySlider
@onready var vInversionToggle: CheckButton = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Controls/ControlsRows/TopOptionColumns/TopSelectColumns/TopSelectRows/VInversionToggle
@onready var hInversionToggle: CheckButton = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Controls/ControlsRows/TopOptionColumns/TopSelectColumns/TopSelectRows/HInversionToggle
@onready var motionBlurCheck: CheckBox = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Graphics/GraphicsColumns/GraphicsRows/GraphicCheckColumns/VisualCheckRows/MotionBlurCheck
@onready var bloomCheck: CheckBox = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Graphics/GraphicsColumns/GraphicsRows/GraphicCheckColumns/VisualCheckRows/BloomCheck
@onready var performanceDisplayCheck: CheckBox = $MainContainer/ContentBox/OptionRows/LowerOptionTabContainer/Graphics/GraphicsColumns/GraphicsRows/GraphicCheckColumns/DataCheckRows/PerformanceDisplayCheck

var cameraSettings: Dictionary = {}
var controlSettings: Dictionary = {}
var displaySettings: Dictionary = {}
var saveSettings: Dictionary

signal close_menu
signal back_menu
signal save_settings(updatedSettings)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO Break out horizontal and vertical sensitivity and fix these values to be what they should be
	# Set UI Values
	fovSlider.value = GLOBAL_SETTINGS.CAMERA.get(CONSTANTS.FOV, GLOBAL_SETTINGS.CAMERA_DEFAULTS.FOV)
	aimSensitivitySlider.value = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.HORIZONTAL_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.HORIZONTAL_SENSITIVITY)
	lookSensitivitySlider.value = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.VERTICAL_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.VERTICAL_SENSITIVITY)
	vInversionToggle.toggle_mode = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.INVERT_VERTICAL, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.INVERT_VERTICAL)
	hInversionToggle.toggle_mode = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.INVERT_HORIZONTAL, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.INVERT_HORIZONTAL)
	performanceDisplayCheck.toggle_mode = GLOBAL_SETTINGS.DISPLAY.get(CONSTANTS.PERFORMANCE, GLOBAL_SETTINGS.DISPLAY_DEFAULTS.PERFORMANCE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(USER_INPUT.MENU.MAIN) and self.visible:
		close_menu.emit()

func _on_close_menu() -> void:
	close_menu.emit()

func _on_back_menu() -> void:
	back_menu.emit()

# TODO Save settings locally in the control object that takes this signal
#			Work to use those saved values and get rid of duplicate constant values
#			https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
func _on_save_menu() -> void:
	if not controlSettings.is_empty():
		saveSettings.get_or_add(CONSTANTS.Controls, controlSettings)
	if not cameraSettings.is_empty():
		saveSettings.get_or_add(CONSTANTS.Camera, cameraSettings)
	if not displaySettings.is_empty():
		saveSettings.get_or_add(CONSTANTS.Display, displaySettings)
	if not saveSettings.is_empty():
		save_settings.emit(saveSettings)

func _on_fov_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		cameraSettings.get_or_add(CONSTANTS.FOV, fovSlider.value)

func _on_aim_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		controlSettings.get_or_add(CONSTANTS.HORIZONTAL_SENSITIVITY, aimSensitivitySlider.value)

func _on_look_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		controlSettings.get_or_add(CONSTANTS.VERTICAL_SENSITIVITY, lookSensitivitySlider.value)

func _on_v_inversion_toggle_toggled(toggledOn: bool) -> void:
	controlSettings.get_or_add(CONSTANTS.INVERT_VERTICAL, toggledOn)

func _on_h_inversion_toggle_toggled(toggledOn: bool) -> void:
	controlSettings.get_or_add(CONSTANTS.INVERT_HORIZONTAL, toggledOn)

func _on_performance_display_check_toggled(toggledOn: bool) -> void:
	controlSettings.get_or_add(CONSTANTS.PERFORMANCE, toggledOn)
