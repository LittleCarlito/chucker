extends CharacterBody3D
class_name BaseCharacter

const _NO_CAMERA_CONTAINER_LOG: String = "New item \"%s\" doesn't have the ability to hold a camera"
const _EMPTY_CAMERA_CONTAINER: String = "CameraContainer from \"%s\" returned null"

@export var base_mesh: MeshInstance3D
@export var base_collision: CollisionShape3D
@export var camera_container: CameraContainer

var height: float
var _initial_camera_orientation: Transform3D
# TODO Need to break apart disable_movement calls into specifying movement and/or rotation
var disable_movement_var: bool = false
var disable_rotation_var: bool = false

func _ready() -> void:
	self.height = base_mesh.get_aabb().size.y

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

## Character jumps; Multiplier can be applied
func jump(jump_multiplier: float = 1) -> void:
	if self.is_on_floor() and self.is_movement_enabled():
		self.velocity.y = GameConfig.DEFAULTS.jump_force * jump_multiplier

## Character moves; Multiplier can be applied
func move(move_direction: Vector3, speed_multiplier: float = 1) -> void:
	if is_movement_disabled():
		velocity.x = 0
		velocity.z = 0
	if move_direction:
		velocity.x = move_direction.x * (GameConfig.DEFAULTS.run_speed * speed_multiplier)
		velocity.z = move_direction.z * (GameConfig.DEFAULTS.run_speed * speed_multiplier)
	# Otherwise set velocity to start slowing down
	else:
		velocity.x = move_toward(velocity.x, 0, GameConfig.DEFAULTS.run_speed)
		velocity.z = move_toward(velocity.z, 0, GameConfig.DEFAULTS.run_speed)
	move_and_slide()

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

## Applies gravity
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
