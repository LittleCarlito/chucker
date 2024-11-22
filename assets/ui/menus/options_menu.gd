extends Control
class_name OptionsMenu

const UPDATE_CONTROL_LOG: String = "Updating control \"%s\" to input \"%s\""
const SELECT_ERROR_LOG: String = "Incorrect number of items selected to change control input; \"%s\" items selected"
const UNBOUND_INPUT_LOG: String = "\"%s\" is not bound to an input"
const UNBIND_LOG: String = "Input \"%s\" key has been rebound"
const CONTROL_REMAPPED_LOG: String = "Control \"%s\" has been remapped from \"%s\" to \"%s\""
const NO_KEYCODE_ICON_STRING: String = "Path \"%s\" could not be mapped back to a keycode; Not persisting input change"

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
@onready var controlSelectMenu: ControlSelectMenu = $ControlSelectMenu
@onready var controlList: ItemList = $MainContainer/ContentBox/OptionRows/OptionTabContainer/Controls/ControlsRows/ControlList
@onready var general: Panel = $MainContainer/ContentBox/OptionRows/OptionTabContainer/General
@onready var optionTabContainer: TabContainer = $MainContainer/ContentBox/OptionRows/OptionTabContainer

enum SETTING_TABS {GENERAL, CONTROLS, GRAPHICS}
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
	self.controlSelectMenu.visible = false
	load_settings.emit()
	self.fovSlider.value = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV)
	self.fovValue.text = str(self.fovSlider.value)
	self.horizontalAimSensitivitySlider.value = GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_AIM_SENSITIVITY)
	self.horizontalAimSensitivityValue.text = str(self.horizontalAimSensitivitySlider.value)
	self.verticalAimSensitivitySlider.value = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_AIM_SENSITIVITY)
	self.verticalAimSensitivityValue.text = str(self.verticalAimSensitivitySlider.value)
	self.horizontalLookSensitivitySlider.value = GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
	self.horizontalLookSensitivityValue.text = str(self.horizontalLookSensitivitySlider.value)
	self.verticalLookSensitivitySlider.value = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_LOOK_SENSITIVITY)
	self.verticalLookSensitivityValue.text = str(self.verticalLookSensitivitySlider.value)
	self.vInversionToggle.button_pressed = GlobalSettings.CAMERA.get(CONSTANTS.INVERT_VERTICAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_VERTICAL)
	self.hInversionToggle.button_pressed = GlobalSettings.CAMERA.get(CONSTANTS.INVERT_HORIZONTAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_HORIZONTAL)
	self.performanceDisplayCheck.button_pressed = GlobalSettings.DISPLAY.get(CONSTANTS.PERFORMANCE, GlobalSettings.DISPLAY_DEFAULTS.PERFORMANCE)
	# Load in icons for set controls
	for i in self.controlList.item_count:
		var constantName: String = self._get_constant_name(self.controlList.get_item_text(i))
		var mappedInput: InputEvent = self._get_constant_value(constantName)
		var mappedTexture: Texture2D = InputSprite.get_sprite(mappedInput)
		self.controlList.set_item_icon(i, mappedTexture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.MAIN) and self.visible:
		self._on_back_menu()

func _on_close_menu() -> void:
	close_menu.emit()
	self._reset_variables(self.SETTING_TABS.GENERAL)
	self.initialize_ui()

func _on_back_menu() -> void:
	back_menu.emit()
	self._reset_variables(self.SETTING_TABS.GENERAL)
	self.initialize_ui()

func _on_save_menu() -> void:
	self._save_controls()
	if not self.controlSettings.is_empty():
		self.saveSettings.get_or_add(CONSTANTS.Controls, self.controlSettings)
	if not self.cameraSettings.is_empty():
		self.saveSettings.get_or_add(CONSTANTS.Camera, self.cameraSettings)
	if not self.displaySettings.is_empty():
		self.saveSettings.get_or_add(CONSTANTS.Display, self.displaySettings)
	if not self.saveSettings.is_empty():
		self.save_settings.emit(self.saveSettings)
		apply_settings.emit()
		self._reset_variables(self.optionTabContainer.current_tab)

# Compares ControlList items to set controls and saves the updated controls to ControlSetting
func _save_controls() -> void:
	for controlListIndex in self.controlList.item_count:
		var constantName: String = self._get_constant_name(self.controlList.get_item_text(controlListIndex))
		var constantValue: InputEvent = self._get_constant_value(constantName)
		var constantIconPath: String = InputSprite.get_sprite(constantValue).resource_path
		var iconPath: String = controlList.get_item_icon(controlListIndex).resource_path
		if constantIconPath != iconPath:
			var mappedKeycode: int = InputSprite.INPUT_ICONS.find_key(iconPath)
			if mappedKeycode != null:
				var mappedEvent: InputEvent = InputEventLibrary.convert_keycode_to_input_event(mappedKeycode)
				var controlSetting: ControlSetting = InputEventLibrary.convert_event_to_control_setting(mappedEvent)
				var controlDictionary: Dictionary = InputEventLibrary.convert_controlsetting_to_dictionary(controlSetting)
				controlSettings.get_or_add(constantName, controlDictionary)
				Logger.debug(CONTROL_REMAPPED_LOG, [constantName, constantValue.as_text(), controlSetting.inputDescription], self)
			else:
				Logger.error(NO_KEYCODE_ICON_STRING, [iconPath], self)


func _reset_variables(activeTab: int) -> void:
	self.saveSettings.clear()
	self.controlSettings.clear()
	self.cameraSettings.clear()
	self.displaySettings.clear()
	self.controlList.deselect_all()
	self.optionTabContainer.current_tab = activeTab
	

func _on_fov_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		self.cameraSettings.get_or_add(CONSTANTS.FOV, self.fovSlider.value)

func _on_fov_slider_value_changed(value: float) -> void:
	self.fovValue.text = str(value)

func _on_v_inversion_toggle_toggled(toggledOn: bool) -> void:
	self.cameraSettings.get_or_add(CONSTANTS.INVERT_VERTICAL, toggledOn)

func _on_h_inversion_toggle_toggled(toggledOn: bool) -> void:
	self.cameraSettings.get_or_add(CONSTANTS.INVERT_HORIZONTAL, toggledOn)

func _on_performance_display_check_toggled(toggledOn: bool) -> void:
	self.displaySettings.get_or_add(CONSTANTS.PERFORMANCE, toggledOn)

func _on_vertical_aim_sensitivity_slider_value_changed(value: float) -> void:
	self.verticalAimSensitivityValue.text = str(value)

func _on_vertical_aim_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		self.cameraSettings.get_or_add(CONSTANTS.VERTICAL_AIM_SENSITIVITY, self.verticalAimSensitivitySlider.value)

func _on_horizontal_aim_sensitivity_slider_value_changed(value: float) -> void:
	self.horizontalAimSensitivityValue.text = str(value)

func _on_horizontal_aim_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		self.cameraSettings.get_or_add(CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, self.horizontalAimSensitivitySlider.value)

func _on_vertical_look_sensitivity_slider_value_changed(value: float) -> void:
	self.verticalLookSensitivityValue.text = str(value)

func _on_vertical_look_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		self.cameraSettings.get_or_add(CONSTANTS.VERTICAL_LOOK_SENSITIVITY, self.verticalLookSensitivitySlider.value)

func _on_horizontal_look_sensitivity_slider_value_changed(value: float) -> void:
	self.horizontalLookSensitivityValue.text = str(value)

func _on_horizontal_look_sensitivity_slider_drag_ended(valueChanged: bool) -> void:
	if valueChanged:
		self.cameraSettings.get_or_add(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, self.horizontalLookSensitivitySlider.value)

func _open_control_select_menu(index: int, _clickPosition: Vector2, mouseButtonIndex: int) -> void:
	if mouseButtonIndex == MOUSE_BUTTON_LEFT:
		self.controlSelectMenu.open_menu(self.controlList.get_item_text(index))
		self.process_mode = Node.PROCESS_MODE_DISABLED

func _control_select_closed() -> void:
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _control_select_set(controlToUpdate: String, selectedInput: ControlSetting) -> void:
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	Logger.debug(UPDATE_CONTROL_LOG, [controlToUpdate, selectedInput.inputDescription], self)
	var newTexture: Texture2D = load(InputSprite.INPUT_ICONS.get(selectedInput.keycode, InputSprite.UNKNOWN_PATH))
	if newTexture != InputSprite.UNKNOWN_TEXTURE:
		var selectedIcons: PackedInt32Array = self.controlList.get_selected_items()
		if selectedIcons.size() == 1:
			self._unbind_input(selectedInput)
			self._update_selected_icons(newTexture)
		else:
			Logger.error(self.SELECT_ERROR_LOG, [str(selectedIcons.size())], self)

# Updates selected icons in ControlList to the passed in texture
func _update_selected_icons(newIcon: Texture2D) -> void:
	var selectedIcons: PackedInt32Array = self.controlList.get_selected_items()
	for i in selectedIcons.size():
		self.controlList.set_item_icon(selectedIcons[i], newIcon)

# Unbinds the control with the matching keycode
func _unbind_input(selectedInput: ControlSetting) -> void:
	# Check control list for matching items and unbind
	var incomingInputPath: String = InputSprite.INPUT_ICONS.get(selectedInput.keycode)
	for controlListIndex in self.controlList.item_count:
		var iconPath: String = controlList.get_item_icon(controlListIndex).resource_path
		if iconPath == incomingInputPath:
			var inputDescription: String = self.controlList.get_item_text(controlListIndex)
			Logger.debug(UNBIND_LOG, [inputDescription], self)
			self._assign_blank_keycap(controlListIndex)

# Applys blank keycap texture to the passed in index of ControlList
func _assign_blank_keycap(index: int) -> void:
	self.controlList.set_item_icon(index, InputSprite.UNKNOWN_TEXTURE)

# Converts the itemText to its assoicated GLOBAL_SETTINGS input name
func _get_constant_name(itemText: String) -> String:
	var constantValue: String = CONSTANTS.INPUT_LABEL.get(itemText, "")
	if constantValue == "":
		Logger.error(self.MISSING_CONSTANT_LOG, [itemText], self)
	return constantValue

# Checks control dictionaries for stored value of constantName
# If not found returns UNKNOWN_KEY InputEvent
func _get_constant_value(constantName: String) -> InputEvent:
	# Check GlobalSettings for control constant with matching name
	var mappedValue: InputEvent = GlobalSettings.CONTROLS.get(constantName, InputEventLibrary.UNKNOWN_KEY)
	if mappedValue == InputEventLibrary.UNKNOWN_KEY:
		# Log key is not bound and return UKNOWN value
		Logger.error(UNBOUND_INPUT_LOG, [constantName], self)
	return mappedValue

# Returns the index in ControlList for the provided GLOBAL_SETTINGS name
# If not found returns INT32_MAX
func _get_control_index(constantName: String) -> int:
	var constantItemText: String = CONSTANTS.INPUT_LABEL.find_key(constantName)
	for controlSetting in self.controlList.item_count:
		var itemText: String = self.controlList.get_item_text(controlSetting)
		if itemText == constantItemText:
			return controlSetting
	return CONSTANTS.INT32_MAX
