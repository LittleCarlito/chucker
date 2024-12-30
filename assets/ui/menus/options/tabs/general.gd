extends OptionTab
class_name GeneralTab

# Logically used variables
@export var fov_slider: HSlider
@export var fov_value: Label
@export var horizontal_aim_sensitivity_slider: HSlider
@export var horizontal_aim_sensitivity_value: Label
@export var vertical_aim_sensitivity_slider: HSlider
@export var vertical_aim_sensitivity_value: Label
@export var horizontal_look_sensitivity_slider: HSlider
@export var horizontal_look_sensitivity_value: Label
@export var vertical_look_sensitivity_slider: HSlider
@export var vertical_look_sensitivity_value: Label
@export var v_inversion_toggle: CheckButton
@export var h_inversion_toggle: CheckButton
# Display only variables
@export var fov_label: Label
@export var horizontal_look_sensitivity_label: Label
@export var vertical_look_sensitivity_label: Label
@export var horizontal_aim_sensitivity_label: Label
@export var vertical_aim_sensitivity_label: Label
@export var top_slider_rows: VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	font_update_list = [
		fov_value,
		horizontal_aim_sensitivity_value,
		vertical_aim_sensitivity_value,
		horizontal_look_sensitivity_value,
		vertical_look_sensitivity_value,
		v_inversion_toggle,
		h_inversion_toggle,
		fov_label,
		horizontal_look_sensitivity_label,
		vertical_look_sensitivity_label,
		horizontal_aim_sensitivity_label,
		vertical_aim_sensitivity_label
	]
	y_scale_update_list = [
		fov_slider,
		vertical_aim_sensitivity_slider,
		vertical_look_sensitivity_slider,
		horizontal_aim_sensitivity_slider,
		horizontal_look_sensitivity_slider
	]
	xy_scale_update_list = [
		v_inversion_toggle,
		h_inversion_toggle
	]
	initialize_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func initialize_ui() -> void:
	fov_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.PLAYER_FOV, GlobalSettings.CAMERA_DEFAULTS.PLAYER_FOV)
	fov_value.text = str(fov_slider.value)
	horizontal_aim_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_AIM_SENSITIVITY)
	horizontal_aim_sensitivity_value.text = str(horizontal_aim_sensitivity_slider.value)
	vertical_aim_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_AIM_SENSITIVITY)
	vertical_aim_sensitivity_value.text = str(vertical_aim_sensitivity_slider.value)
	horizontal_look_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
	horizontal_look_sensitivity_value.text = str(horizontal_look_sensitivity_slider.value)
	vertical_look_sensitivity_slider.value = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_LOOK_SENSITIVITY)
	vertical_look_sensitivity_value.text = str(vertical_look_sensitivity_slider.value)
	v_inversion_toggle.button_pressed = GlobalSettings.CAMERA.get(CONSTANTS.INVERT_VERTICAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_VERTICAL)
	h_inversion_toggle.button_pressed = GlobalSettings.CAMERA.get(CONSTANTS.INVERT_HORIZONTAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_HORIZONTAL)

func _on_fov_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var new_entry: Dictionary = {CONSTANTS.PLAYER_FOV: fov_slider.value}
		value_updated.emit(UIData.TYPE.CAMERA, new_entry)

func _on_fov_slider_value_changed(value: float) -> void:
	fov_value.text = str(value)

func _on_v_inversion_toggle_toggled(toggled_on: bool) -> void:
	var new_entry: Dictionary = {CONSTANTS.INVERT_VERTICAL: toggled_on}
	value_updated.emit(UIData.TYPE.CAMERA, new_entry)

func _on_h_inversion_toggle_toggled(toggled_on: bool) -> void:
	var new_entry: Dictionary = {CONSTANTS.INVERT_HORIZONTAL: toggled_on}
	value_updated.emit(UIData.TYPE.CAMERA, new_entry)

func _on_vertical_aim_sensitivity_slider_value_changed(value: float) -> void:
	vertical_aim_sensitivity_value.text = str(value)

func _on_vertical_aim_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var new_entry: Dictionary = {CONSTANTS.VERTICAL_AIM_SENSITIVITY: vertical_aim_sensitivity_slider.value}
		value_updated.emit(UIData.TYPE.CAMERA, new_entry)

func _on_horizontal_aim_sensitivity_slider_value_changed(value: float) -> void:
	horizontal_aim_sensitivity_value.text = str(value)

func _on_horizontal_aim_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var new_entry: Dictionary = {CONSTANTS.HORIZONTAL_AIM_SENSITIVITY: horizontal_aim_sensitivity_slider.value}
		value_updated.emit(UIData.TYPE.CAMERA, new_entry)

func _on_vertical_look_sensitivity_slider_value_changed(value: float) -> void:
	vertical_look_sensitivity_value.text = str(value)

func _on_vertical_look_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var new_entry: Dictionary = {CONSTANTS.VERTICAL_LOOK_SENSITIVITY: vertical_look_sensitivity_slider.value}
		value_updated.emit(UIData.TYPE.CAMERA, new_entry)

func _on_horizontal_look_sensitivity_slider_value_changed(value: float) -> void:
	horizontal_look_sensitivity_value.text = str(value)

func _on_horizontal_look_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var new_entry: Dictionary = {CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY: horizontal_look_sensitivity_slider.value}
		value_updated.emit(UIData.TYPE.CAMERA, new_entry)
