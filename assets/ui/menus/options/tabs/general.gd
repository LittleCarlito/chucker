extends OptionTab
class_name GeneralTab

# TODO OOOOO
# TODO Convert these settings to override.cfg

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
	initialize_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func initialize_ui() -> void:
	# Set fov elements
	fov_slider.value = CameraConfig.get_fov_value()
	fov_value.text = str(fov_slider.value)
	# Set aim/look elements
	horizontal_aim_sensitivity_slider.value = CameraConfig.get_horizontal_aim_sens()
	horizontal_aim_sensitivity_value.text = str(horizontal_aim_sensitivity_slider.value)
	vertical_aim_sensitivity_slider.value = CameraConfig.get_vertical_aim_sense()
	vertical_aim_sensitivity_value.text = str(vertical_aim_sensitivity_slider.value)
	horizontal_look_sensitivity_slider.value = CameraConfig.get_horizontal_look_sens()
	horizontal_look_sensitivity_value.text = str(horizontal_look_sensitivity_slider.value)
	vertical_look_sensitivity_slider.value = CameraConfig.get_vertical_look_sense()
	vertical_look_sensitivity_value.text = str(vertical_look_sensitivity_slider.value)
	# Set inversion elements
	v_inversion_toggle.button_pressed = CameraConfig.is_vertical_invert()
	h_inversion_toggle.button_pressed = CameraConfig.is_horizontal_invert()

func _on_fov_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		applied_changes[CameraConfig.PLAYER_FOV] = fov_slider.value

func _on_fov_slider_value_changed(value: float) -> void:
	fov_value.text = str(value)

func _on_v_inversion_toggle_toggled(toggled_on: bool) -> void:
	applied_changes[CameraConfig.INVERT_VERTICAL] = toggled_on

func _on_h_inversion_toggle_toggled(toggled_on: bool) -> void:
	applied_changes[CameraConfig.INVERT_HORIZONTAL] = toggled_on

func _on_vertical_aim_sensitivity_slider_value_changed(value: float) -> void:
	vertical_aim_sensitivity_value.text = str(value)

func _on_vertical_aim_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		applied_changes[CameraConfig.VERTICAL_AIM_SENSITIVITY] = vertical_aim_sensitivity_slider.value

func _on_horizontal_aim_sensitivity_slider_value_changed(value: float) -> void:
	horizontal_aim_sensitivity_value.text = str(value)

func _on_horizontal_aim_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		applied_changes[CameraConfig.HORIZONTAL_AIM_SENSITIVITY] = horizontal_aim_sensitivity_slider.value

func _on_vertical_look_sensitivity_slider_value_changed(value: float) -> void:
	vertical_look_sensitivity_value.text = str(value)

func _on_vertical_look_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		applied_changes[CameraConfig.VERTICAL_LOOK_SENSITIVITY] = vertical_look_sensitivity_slider.value

func _on_horizontal_look_sensitivity_slider_value_changed(value: float) -> void:
	horizontal_look_sensitivity_value.text = str(value)

func _on_horizontal_look_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		applied_changes[CameraConfig.HORIZONTAL_LOOK_SENSITIVITY] = horizontal_look_sensitivity_slider.value
