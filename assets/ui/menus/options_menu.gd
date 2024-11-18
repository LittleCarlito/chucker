extends Control
class_name OptionsMenu

const UPDATE_CONTROL_LOG: String = "Updating control \"%s\" to input \"%s\""
const BAD_INPUT_LOG: String = "Input \"%s\" does not have an associated icon"
const SELECT_ERROR_LOG: String = "Incorrect number of items selected to change control input; \"%s\" items selected"
const MISSING_CONSTANT_LOG: String = "\"%s\" does not have an associated value in CONSTANTS.INPUT_LABEL"
const BAD_CONSTANT_LOG: String = "Control setting \"%s\" couldn't be mapped back to a ControlList text label"
const MISSING_CONSTNAT_LOG: String = "Value for constantName \"%s\" could not be found"

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

# TODO See about refactoring controlSettings to String, InputEvent dictionary
#			If doesn't work will have to split out Keyboard and Mouse controls to separate dictionaries
#			If it does work then GLOBAL_SETTINGS controls need to be recondensed to single dictionary
# TODO Update fov, view invert, sensitivity references to CAMERA dictionary and not CONTROLS
# TODO Need to have apply call overwrite PROJECT_SETTINGS stuff and save() it

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
		var mappedTexture: Texture2D = AssetManagement.get_sprite(mappedInput)
		self.controlList.set_item_icon(i, mappedTexture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.MAIN) and self.visible:
		self._on_close_menu()

func _on_close_menu() -> void:
	close_menu.emit()
	self._reset_variables(self.SETTING_TABS.GENERAL)
	self.initialize_ui()

func _on_back_menu() -> void:
	back_menu.emit()
	self._reset_variables(self.SETTING_TABS.GENERAL)
	self.initialize_ui()

func _on_save_menu() -> void:
	# TODO Need to refactor for keyboard mouse sections
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

func _control_select_set(controlToUpdate: String, selectedInput: InputEvent) -> void:
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	Logger.debug(UPDATE_CONTROL_LOG, [controlToUpdate, str(selectedInput.as_text())], self)
	var newTexture: Texture2D = AssetManagement.get_sprite(selectedInput)
	if newTexture != AssetManagement.UKNOWN_TEXTURE:
		var selectedIcons: PackedInt32Array = self.controlList.get_selected_items()
		if selectedIcons.size() == 1:
			self._unbind_input(selectedInput)
			self._update_selected_icons(newTexture)
			var controlItemText: String = self.controlList.get_item_text(selectedIcons[0])
			var controlConstant: String = self._get_constant_name(controlItemText)
			self.controlSettings.get_or_add(controlConstant, selectedInput)
		else:
			Logger.error(self.SELECT_ERROR_LOG, [str(selectedIcons.size())], self)
	else:
		var naKeyTexture: Texture2D = load(AssetManagement.INPUT_ICONS.UNKOWN)
		self._update_selected_icons(naKeyTexture)
		Logger.error(self.BAD_INPUT_LOG, [selectedInput], self)

# Updates selected icons in ControlList to the passed in texture
func _update_selected_icons(newIcon: Texture2D) -> void:
	var selectedIcons: PackedInt32Array = self.controlList.get_selected_items()
	for i in selectedIcons.size():
		self.controlList.set_item_icon(selectedIcons[i], newIcon)

func _unbind_input(selectedInput: InputEvent) -> void:
	var selectedKeycode: int = AssetManagement.extract_keycode(selectedInput)
	# Check intermediate changes
	for settingKey in controlSettings.keys():
		var updatedKeyEvent: InputEvent = controlSettings.get(settingKey)
		var updatedKeycode: int = AssetManagement.extract_keycode(updatedKeyEvent)
		# TODO selectedInput is the event from controlSelect _input and needs to be converted to be compatible with InputEventLibrary objects
		if updatedKeyEvent != InputEventLibrary.UNKOWN_KEY and (selectedKeycode == updatedKeycode):
			var settingIndex: int = self._get_control_index(settingKey)
			if settingIndex != CONSTANTS.INT32_MAX:
				self._assign_blank_keycap(settingIndex)
				self.controlSettings.erase(settingKey)
				self.controlSettings.get_or_add(settingKey, InputEventLibrary.UNKOWN_KEY)
			else:
				Logger.error(BAD_CONSTANT_LOG, [settingKey], self)
	# Check set controls
	for controlListIndex in self.controlList.item_count:
		var constantName: String = self._get_constant_name(self.controlList.get_item_text(controlListIndex))
		var mappedInput: InputEvent = self._get_constant_value(constantName)
		var mappedKeycode: int = AssetManagement.extract_keycode(mappedInput)
		if mappedInput != InputEventLibrary.UNKOWN_KEY and (mappedKeycode == selectedKeycode):
			self._assign_blank_keycap(controlListIndex)
			var controlTextToUnbind: String = self.controlList.get_item_text(controlListIndex)
			var controlConstant: String = self._get_constant_name(controlTextToUnbind)
			# TODO Need to find a way to assign unbound as an InputEvent in the map
			self.controlSettings.get_or_add(controlConstant, InputEventLibrary.UNKOWN_KEY)

# Applys blank keycap texture to the passed in index of ControlList
func _assign_blank_keycap(index: int) -> void:
	self.controlList.set_item_icon(index, AssetManagement.UKNOWN_TEXTURE)

# Converts the itemText to its assoicated GLOBAL_SETTINGS input name
func _get_constant_name(itemText: String) -> String:
	var constantValue: String = CONSTANTS.INPUT_LABEL.get(itemText, "")
	if constantValue == "":
		Logger.error(self.MISSING_CONSTANT_LOG, [itemText], self)
	return constantValue

# Checks control dictionaries for stored value of constantName
# If not found returns UKNOWN_KEY InputEvent
func _get_constant_value(constantName: String) -> InputEvent:
	# Check GlobalSettings for control constant with matching name
	var mappedValue: InputEvent = GlobalSettings.CONTROLS.get(constantName, InputEventLibrary.UNKOWN_KEY)
	if mappedValue == InputEventLibrary.UNKOWN_KEY:
		# Not found; Log and return value for UNKOWN
		Logger.error(MISSING_CONSTANT_LOG, [constantName], self)
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
