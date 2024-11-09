extends Control

@onready var fovSlider: HSlider = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopOptionColumns/TopSelectRows/FovLabelRows/FovSliderColumns/FovSliderContainer/FovSlider
@onready var fovValue: Label = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopOptionColumns/TopSelectRows/FovLabelRows/FovSliderColumns/FovValueCenter/FovValue
@onready var horizontalAimSensitivitySlider: HSlider = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/HorizontalAimSensitivityRows/HorizontalAimSensitivityColumns/HorizontalAimSensitvitySliderContainer/HorizontalAimSensitivitySlider
@onready var horizontalAimSensitivityValue: Label = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/HorizontalAimSensitivityRows/HorizontalAimSensitivityColumns/HorizontalAimSensitivityValueCenter/HorizontalAimSensitivityValue
@onready var verticalAimSensitivitySlider: HSlider = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/VerticalAimSensitivityRows/VerticalAimSensitivityColumns/VerticalAimSensitvitySliderContainer/VerticalAimSensitivitySlider
@onready var verticalAimSensitivityValue: Label = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/VerticalAimSensitivityRows/VerticalAimSensitivityColumns/VerticalAimSensitivityValueCenter/VerticalAimSensitivityValue
@onready var horizontalLookSensitivitySlider: HSlider = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/HorizontalLookSensitivityRows/HorizontalLookSensitivityColumns/HorizontalLookSensitvitySliderContainer/HorizontalLookSensitivitySlider
@onready var horizontalLookSensitivityValue: Label = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/HorizontalLookSensitivityRows/HorizontalLookSensitivityColumns/HorizontalLookSensitivityValueCenter/HorizontalLookSensitivityValue
@onready var verticalLookSensitivitySlider: HSlider = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/VerticalLookSensitivityRows/VerticalLookSensitivityColumns/VerticalLookSensitvitySliderContainer/VerticalLookSensitivitySlider
@onready var verticalLookSensitivityValue: Label = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopSensitivityColumns/TopSliderRows/VerticalLookSensitivityRows/VerticalLookSensitivityColumns/VerticalLookSensitivityValueCenter/VerticalLookSensitivityValue
@onready var vInversionToggle: CheckButton = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopOptionColumns/TopSelectRows/VInversionToggle
@onready var hInversionToggle: CheckButton = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General/ControlsRows/TopOptionColumns/TopOptionColumns/TopSelectRows/HInversionToggle
@onready var motionBlurCheck: CheckBox = $MainContainer/ContentBox/OptionRows/OptionTabContainer/Graphics/GraphicsColumns/GraphicsRows/GraphicCheckColumns/VisualCheckRows/MotionBlurCheck
@onready var bloomCheck: CheckBox = $MainContainer/ContentBox/OptionRows/OptionTabContainer/Graphics/GraphicsColumns/GraphicsRows/GraphicCheckColumns/VisualCheckRows/BloomCheck
@onready var performanceDisplayCheck: CheckBox = $MainContainer/ContentBox/OptionRows/OptionTabContainer/Graphics/GraphicsColumns/GraphicsRows/GraphicCheckColumns/DataCheckRows/PerformanceDisplayCheck

var cameraSettings: Dictionary
var controlSettings: Dictionary
var displaySettings: Dictionary
var saveSettings: Dictionary

signal close_menu
signal back_menu
signal save_settings(updatedSettings)
signal load_settings
signal apply_settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.initialize_ui()

func initialize_ui() -> void:
	load_settings.emit()
	fovSlider.value = GLOBAL_SETTINGS.CAMERA.get(CONSTANTS.FOV, GLOBAL_SETTINGS.CAMERA_DEFAULTS.FOV)
	fovValue.text = str(fovSlider.value)
	horizontalAimSensitivitySlider.value = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.HORIZONTAL_AIM_SENSITIVITY)
	horizontalAimSensitivityValue.text = str(horizontalAimSensitivitySlider.value)
	verticalAimSensitivitySlider.value = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.VERTICAL_AIM_SENSITIVITY)
	verticalAimSensitivityValue.text = str(verticalAimSensitivitySlider.value)
	horizontalLookSensitivitySlider.value = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
	horizontalLookSensitivityValue.text = str(horizontalLookSensitivitySlider.value)
	verticalLookSensitivitySlider.value = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.VERTICAL_LOOK_SENSITIVITY, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.VERTICAL_LOOK_SENSITIVITY)
	verticalLookSensitivityValue.text = str(verticalLookSensitivitySlider.value)
	vInversionToggle.button_pressed = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.INVERT_VERTICAL, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.INVERT_VERTICAL)
	hInversionToggle.button_pressed = GLOBAL_SETTINGS.CONTROLS.get(CONSTANTS.INVERT_HORIZONTAL, GLOBAL_SETTINGS.CONTROLS_DEFAULTS.INVERT_HORIZONTAL)
	performanceDisplayCheck.button_pressed = GLOBAL_SETTINGS.DISPLAY.get(CONSTANTS.PERFORMANCE, GLOBAL_SETTINGS.DISPLAY_DEFAULTS.PERFORMANCE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(USER_INPUT.MENU.MAIN) and self.visible:
		self._on_close_menu()

func _on_close_menu() -> void:
	close_menu.emit()
	self.initialize_ui()

func _on_back_menu() -> void:
	back_menu.emit()
	self.initialize_ui()

func _on_save_menu() -> void:
	if not controlSettings.is_empty():
		saveSettings.get_or_add(CONSTANTS.Controls, controlSettings)
	if not cameraSettings.is_empty():
		saveSettings.get_or_add(CONSTANTS.Camera, cameraSettings)
	if not displaySettings.is_empty():
		saveSettings.get_or_add(CONSTANTS.Display, displaySettings)
	if not saveSettings.is_empty():
		save_settings.emit(saveSettings)
		apply_settings.emit()
		self._reset_variables()

func _reset_variables() -> void:
	saveSettings.clear()
	controlSettings.clear()
	cameraSettings.clear()
	displaySettings.clear()

func _on_fov_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		cameraSettings.get_or_add(CONSTANTS.FOV, fovSlider.value)

func _on_fov_slider_value_changed(value: float) -> void:
	fovValue.text = str(value)

func _on_v_inversion_toggle_toggled(toggledOn: bool) -> void:
	controlSettings.get_or_add(CONSTANTS.INVERT_VERTICAL, toggledOn)

func _on_h_inversion_toggle_toggled(toggledOn: bool) -> void:
	controlSettings.get_or_add(CONSTANTS.INVERT_HORIZONTAL, toggledOn)

func _on_performance_display_check_toggled(toggledOn: bool) -> void:
	controlSettings.get_or_add(CONSTANTS.PERFORMANCE, toggledOn)

func _on_vertical_aim_sensitivity_slider_value_changed(value: float) -> void:
	verticalAimSensitivityValue.text = str(value)

func _on_vertical_aim_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		controlSettings.get_or_add(CONSTANTS.VERTICAL_AIM_SENSITIVITY, verticalAimSensitivitySlider.value)

func _on_horizontal_aim_sensitivity_slider_value_changed(value: float) -> void:
	horizontalAimSensitivityValue.text = str(value)

func _on_horizontal_aim_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		controlSettings.get_or_add(CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, horizontalAimSensitivitySlider.value)

func _on_vertical_look_sensitivity_slider_value_changed(value: float) -> void:
	verticalLookSensitivityValue.text = str(value)

func _on_vertical_look_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		controlSettings.get_or_add(CONSTANTS.VERTICAL_LOOK_SENSITIVITY, verticalLookSensitivitySlider.value)

func _on_horizontal_look_sensitivity_slider_value_changed(value: float) -> void:
	horizontalLookSensitivityValue.text = str(value)

func _on_horizontal_look_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		controlSettings.get_or_add(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, horizontalLookSensitivitySlider.value)
