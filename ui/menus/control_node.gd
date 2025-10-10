extends Node3D
class_name ControlNode

const _UNABLE_TO_OPEN_LOG: String = "Unable to open %s; Error: %s"
const _EMPTY_SAVE_LOG:String = "Must provide settings to be saved; Input: %s"
const _UNEXPTECTED_TYPE_LOG: String = "Save file object was not expected type"
const _BAD_USER_INPUT_LOG: String = "Value from USER_INPUT \"%s\" could not be mapped to a GLOBAL_SETTING"
const _NO_DEFAULT_LOG: String = "Global default value for settingName \"%s\" in category \"%s\" could not be found; Not updating control"
const _NO_CATEGORY_LOG: String = "Category could not be extracted for \"%s\"; No control is being updated"
const _TEE_CAMERA: String = "TeeboxCamera"

const MENU: Dictionary = {
	"SCORECARD": {
		"PLAYER_PIXEL_SIZE": .003,
		"TEEBOX_PIXEL_SIZE": .0023
	}
}

@export var scorecard: ScorecardView
@export var pause_menu: PauseMenu

signal apply_settings
signal disable_movement
signal disable_rotation
signal enable_movement
signal enable_rotation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalInputController.connect(SIGNAL_NAME.PAUSE_ACTION, _handle_pause_action)
	GlobalInputController.connect(SIGNAL_NAME.TAB_ACTION, _handle_tab_action)
	GlobalInputController.connect(SIGNAL_NAME.TAB_RELEASE, _handle_tab_release)

func _handle_pause_action() -> void:
	pause_menu.visible = true
	get_tree().paused = true
	set_process_input(false)

func _handle_tab_action() -> void:
	disable_movement.emit()
	disable_rotation.emit()
	# Determine what camera is active so we know how big to make the scorecard
	var current_camera: Camera3D = get_tree().root.get_camera_3d()
	if(current_camera.name == _TEE_CAMERA):
		scorecard.set_pixel_size(MENU.SCORECARD.TEEBOX_PIXEL_SIZE)
	else:
		scorecard.set_pixel_size(MENU.SCORECARD.PLAYER_PIXEL_SIZE)
	scorecard.scorecard_sprite.visible = true
	get_viewport().get_camera_3d().look_at(scorecard.scorecard_sprite.global_position)

func _handle_tab_release() -> void:
	enable_movement.emit()
	enable_rotation.emit()
	scorecard.scorecard_sprite.visible = false
	get_viewport().get_camera_3d().rotation = Vector3.ZERO

# Handling close menu signals
func _close_menu() -> void:
	pause_menu.visible = false
	get_tree().paused = false
	set_process_input(true)

func _apply_settings() -> void:
	apply_settings.emit()
