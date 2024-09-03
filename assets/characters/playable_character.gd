extends CharacterBody3D
class_name PlayableCharacter



func _physics_process(delta: float) -> void:
	self._handle_jump(delta)
	self._handle_camera_controls()
	self._handle_player_action(delta)
	self._handle_player_interact()
	self._handle_movement()

## Handles player action input
func _handle_player_action(_delta: float) -> void:
	push_error("UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement _handle_player_action method")


## Actions to be performed when MOVE_JUMP is pressed
func _handle_jump(_delta: float) -> void:
	push_error("UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement _handle_jump method")


## Handles camera/aiming related actions
func _handle_camera_controls() -> void:
	push_error("UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement _handle_camera_controls method")


## Handle player pressing interact button
func _handle_player_interact() -> void:
	push_error("UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement _handle_player_interact method")

## Detects and executes movements
func _handle_movement() -> void:
	push_error("UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement _handle_movement method")



## Toggles the visibility logic when character has item equiped
func toggle_equiped(_value: bool) -> void:
	push_error("UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement toggle_equiped method")


## Returns the height of Chuck
func get_height() -> float:
	push_error("UNIMPLEMENTED METHOD; All PlayableCharacter Objects must implement get_height method; Returing 0")
	return 0
