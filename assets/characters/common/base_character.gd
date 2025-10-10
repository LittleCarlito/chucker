extends CharacterBody3D
class_name BaseCharacter

const _NO_CAMERA_CONTAINER_LOG: String = "New item \"%s\" doesn't have the ability to hold a camera"
const _EMPTY_CAMERA_CONTAINER: String = "CameraContainer from \"%s\" returned null"

@export var base_mesh: MeshInstance3D
@export var base_collision: CollisionShape3D
@export var camera_container: CameraContainer

var height: float
var is_sprinting: bool = false
var disable_movement_var: bool = false
var disable_rotation_var: bool = false
var _initial_camera_orientation: Transform3D
var _pending_movement: bool = false

# TODO OOOOO 
# TODO Task list
# TODO To do below you need to
#		Change StatefulAsset to AssetState
#		Make it a Resource and not Node3D
#		Have CameraRig extend Node3D and not it
#		Have CameraRig contain an AssetState and use that like it was using StatefulAsset
#		Update asset registration functions
#			Resource is now internal part of asset and not something created in registration
#			Needs to be pulled out of created asset
#				Should probably have a functiuon in GroupName or something for "get_asset_state"
#			With that the batch signal out can be removed
#				Now shared ref to AssetState object connects dispatched actions directly to the state
#				Gets rid of all the _dirty_state stuff too
# TODO Make Basecharacter Node3D class containing a CharaacterBody3D
#		Wire up the calls so that they manipulate the character properly
# TODO Refactor character to function based off state and not inputs
# TODO Get back to Asset_Delivery TODOs
# TODO Then to CameraRigs TODOs

func _ready() -> void:
	height = base_mesh.get_aabb().size.y
	_initial_camera_orientation = camera_container.global_transform
	if ApplicationConfig.ENABLE_LEGACY_CAMERA:
		camera_container.populate_camera_control(_get_focus_point())

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	if _pending_movement:
		move_and_slide()
		_pending_movement = false

## Movement functions

## Character jumps; Multiplier can be applied
func jump(jump_multiplier: float = 1) -> void:
	if is_on_floor() and is_movement_enabled():
		velocity.y = GameConfig.DEFAULTS.jump_force * jump_multiplier

# TODO Change the velocity x and z setting to use move toward with acceleration and deccelration considerations
## Character moves; Multiplier can be applied
func move(move_direction: Vector3) -> void:
	if is_movement_disabled():
		velocity.x = 0
		velocity.z = 0
	else:
		var speed: float = GameConfig.DEFAULTS.run_speed
		if move_direction != Vector3(0, 0, 0):
			if is_sprinting:
				speed *= GameConfig.DEFAULTS.sprint_multiplier
			velocity.x = move_direction.x * speed
			velocity.z = move_direction.z * speed
		# Otherwise set velocity to start slowing down
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	_pending_movement = true

func start_sprint() -> void:
	is_sprinting = true

func stop_sprint() -> void:
	is_sprinting = false

## Character rotates on y axis; Multiplier can be applied
func rotate_y_axis(rotation_amount: float) -> void:
	rotate_y(rotation_amount)

## Applies gravity
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

## Returns the height of Chuck
func get_height() -> float:
	return height

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

## Camera functions

func rotate_camera(vertical_rotation: float, horizontal_rotation: float) -> void:
	if _can_vertically_rotate(vertical_rotation):
		camera_container.veritcal_rotate(vertical_rotation)
	if _can_horizontally_rotate(horizontal_rotation):
		camera_container.horizontal_rotate(horizontal_rotation)

func zoom_in(zoom_amount: float = NUMBERS.FLOAT16_MAX) -> void:
	camera_container.zoom_in(zoom_amount)

func zoom_out(zoom_amount: float = NUMBERS.FLOAT16_MAX) -> void:
	camera_container.zoom_out(zoom_amount)

func reset_zoom() -> void:
	camera_container.reset_zoom();

func horizontal_pan(rotation_amount: float, focus_location: Vector3 = Vector3.INF) -> void:
	camera_container.horizontal_pan(rotation_amount, focus_location)

func snap_back(incoming_rotation: float = NUMBERS.FLOAT16_MAX) -> void:
	camera_container.snap_back(incoming_rotation)

func set_camera(incoming_camera: Camera3D) -> void:
	camera_container.set_camera(incoming_camera)

func disable_camera() -> void:
	camera_container.disable_camera()

func enable_camera() -> void:
	camera_container.enable_camera()

func _reset_camera_control() -> void:
	camera_container.reset_camera_control()

func _handle_horizontal_rotation(incoming_rotation: float = NUMBERS.FLOAT16_MAX) -> void:
	var rotation_amount = incoming_rotation if incoming_rotation != NUMBERS.FLOAT16_MAX else deg_to_rad(CameraConfig.get_rotate_speed())
	rotate_y_axis(rotation_amount)

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

func _handle_zoom_in() -> void:
	if camera_container.is_current():
		camera_container.zoom_in()

func _handle_zoom_out() -> void:
	camera_container.snap_back(global_rotation.z)

func _get_focus_point() -> Vector3:
	var focus_point: Vector3 = position + CameraConfig.get_player_focus_offset()
	return focus_point

func _can_vertically_rotate(rotation_amount:float) -> bool:
	var potential_vertical_roation: float = camera_container.get_vertical_rotation() + rotation_amount
	var max_vertical_value: float = CameraConfig.get_max_vertical_rotation()
	var min_vertical_value: float = CameraConfig.get_min_vertical_rotation()
	return (potential_vertical_roation > min_vertical_value) and (potential_vertical_roation < max_vertical_value)

func _can_horizontally_rotate(rotation_amount:float) -> bool:
	var potential_horizontal_roation: float = camera_container.get_horizontal_rotation() + rotation_amount
	var max_horizontal_value: float = CameraConfig.get_max_horizontal_rotation()
	var min_horizontal_value: float = CameraConfig.get_min_horizontal_rotation()
	return (potential_horizontal_roation > min_horizontal_value) and (potential_horizontal_roation < max_horizontal_value)
