extends CharacterBody3D
class_name PlayableCharacter

const _RETURNING_ZERO: String = "; Returning 0"
const _HANDLE_PLAYER_ACTION: String = "_handle_player_action"
const _HANDLE_CAMERA_CONTROLS: String = "_handle_camera_controls"
const _HANDLE_PLAYER_INTERACT: String = "_handle_player_interact"
const _HANDLE_MOVEMENT: String = "_handle_movement"
const _UNEQUIP_ITEM: String = "unequip_item"
const _GET_HEIGHT: String = "get_height"

var disable_movement_var: bool = false

func _physics_process(delta: float) -> void:
	_handle_camera_controls()
	_handle_player_action(delta)
	_handle_player_interact()
	_handle_movement(delta)

## Handles player action input
func _handle_player_action(_delta: float) -> void:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG, [_HANDLE_PLAYER_ACTION], self)

## Handles camera/aiming related actions
func _handle_camera_controls() -> void:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, _HANDLE_CAMERA_CONTROLS], self)

## Handle player pressing interact button
func _handle_player_interact() -> void:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, _HANDLE_PLAYER_INTERACT], self)

## Detects and executes movements
func _handle_movement(_delta: float) -> void:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, _HANDLE_MOVEMENT], self)

## Unequips the currently equipped item
func unequip_item() -> void:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, _UNEQUIP_ITEM], self)

## Returns the height of Chuck
func get_height() -> float:
	Logger.error(CONSTANTS.UNIMPLEMENTED_LOG + _RETURNING_ZERO, [self.name, _GET_HEIGHT], self)
	return 0

func is_movement_disabled() -> bool:
	return disable_movement_var

func is_movement_enabled() -> bool:
	return !disable_movement_var

func disable_movement() -> void:
	disable_movement_var = true

func enable_movement() -> void:
	disable_movement_var = false

func toggle_movement() -> void:
	disable_movement_var = not disable_movement_var
