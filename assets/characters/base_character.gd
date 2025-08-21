extends CharacterBody3D
class_name BaseCharacter

@export var base_mesh: MeshInstance3D
@export var base_collision: CollisionShape3D

var height: float
# TODO Need to break apart disable_movement calls into specifying movement and/or rotation
var disable_movement_var: bool = false
var disable_rotation_var: bool = false

func _ready() -> void:
	self.height = base_mesh.get_aabb().size.y

## Returns the height of Chuck
func get_height() -> float:
	return self.height

## Returns true if movement is disabled
func is_movement_disabled() -> bool:
	return disable_movement_var

## Returns true if movement is enabled
func is_movement_enabled() -> bool:
	return !disable_movement_var

## Disables movement
func disable_movement() -> void:
	disable_movement_var = true

## Enables movement
func enable_movement() -> void:
	disable_movement_var = false

## Toggles movement enablement
func toggle_movement() -> void:
	disable_movement_var = not disable_movement_var

## Returns true if rotation is enabled
func is_rotation_enabled() -> bool:
	return !disable_rotation_var

## Returns true if rotation is disabled
func is_rotation_disabled() -> bool:
	return disable_rotation_var

## Disables rotation
func disable_rotation() -> void:
	disable_rotation_var = true

## Enables rotation
func enable_rotation() -> void:
	disable_rotation_var = false

## Toggles rotation enablement
func toggle_rotation() -> void:
	disable_rotation_var = not disable_rotation_var