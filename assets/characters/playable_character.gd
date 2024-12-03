extends CharacterBody3D
class_name PlayableCharacter

const _UNIMPLEMENTED_LOG: String = "UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement \"%s\""
const _HANDLE_PLAYER_ACTION: String = "_handle_player_action"
const _HANDLE_CAMERA_CONTROLS: String = "_handle_camera_controls"
const _HANDLE_PLAYER_INTERACT: String = "_handle_player_interact"
const _HANDLE_MOVEMENT: String = "_handle_movement"
const _UNEQUIP_ITEM: String = "unequip_item"
const _GET_HEIGHT: String = "get_height"

func _physics_process(delta: float) -> void:
	self._handle_camera_controls()
	self._handle_player_action(delta)
	self._handle_player_interact()
	self._handle_movement(delta)

## Handles player action input
func _handle_player_action(_delta: float) -> void:
	Logger.error(self._UNIMPLEMENTED_LOG, [self._HANDLE_PLAYER_ACTION], self)

## Handles camera/aiming related actions
func _handle_camera_controls() -> void:
	Logger.error(self._UNIMPLEMENTED_LOG, [self._HANDLE_CAMERA_CONTROLS], self)

## Handle player pressing interact button
func _handle_player_interact() -> void:
	Logger.error(self._UNIMPLEMENTED_LOG, [self._HANDLE_PLAYER_INTERACT], self)

## Detects and executes movements
func _handle_movement(_delta: float) -> void:
	Logger.error(self._UNIMPLEMENTED_LOG, [self._HANDLE_MOVEMENT], self)

## Unequips the currently equipped item
func unequip_item() -> void:
	Logger.error(self._UNIMPLEMENTED_LOG, [self._UNEQUIP_ITEM], self)

## Returns the height of Chuck
func get_height() -> float:
	Logger.error(self._UNIMPLEMENTED_LOG, [self._GET_HEIGHT], self)
	return 0
