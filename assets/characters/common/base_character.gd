extends CharacterBody3D
class_name BaseCharacter

const _NO_CAMERA_CONTAINER_LOG: String = "New item \"%s\" doesn't have the ability to hold a camera"
const _EMPTY_CAMERA_CONTAINER: String = "CameraContainer from \"%s\" returned null"

@export var base_mesh: MeshInstance3D
@export var base_collision: CollisionShape3D
@export var asset_state: AssetState

# TODO OOOOO 
# TODO Task list
# TODO Get the other character based classes working off state
#			FreelookCharacter has been deleted
#				Should really be behavior determined by the camera based off the state it is in
# TODO Be able to move the character via state manipulation
# TODO Move AssetData into AssetState
# TODO Get back to Asset_Delivery TODOs
# TODO Then to CameraRigs TODOs
# TODO Then try to switch it all over to an ECS system
#		Resolvers looking through globally registered nodes and data
#			Finds the ones it needs to process based off tags
#				Determines what type of object and handles according to the type of resolver it is
#			Should be ASSET.STATE based resolvers and they can look for AssetState's in their desired state
#				Or could do tags I guess

func _ready() -> void:
	asset_state.set_veritcal_length(base_mesh.get_aabb().size.y)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	TransformResolver.resolve_velocity(self, asset_state.get_current_velocity())
	move_and_slide()
	# TODO If you find that you never slow down it is because you need to push your results back into state

## Applies gravity
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		asset_state.apply_velocity(get_gravity() * delta)

## Character jumps; Multiplier can be applied
func jump(jump_multiplier: float = 1) -> void:
	if is_on_floor() and is_movement_enabled():
		asset_state.set_current_y_velocity(GameConfig.DEFAULTS.jump_force * jump_multiplier)

func move(move_direction: Vector3) -> void:
	if is_movement_disabled():
		asset_state.set_current_x_velocity(0)
		asset_state.set_current_z_velocity(0)
	else:
		var speed: float = GameConfig.DEFAULTS.run_speed
		if move_direction != Vector3(0, 0, 0):
			if asset_state.is_sprinting():
				speed *= GameConfig.DEFAULTS.sprint_multiplier
			asset_state.set_current_x_velocity(move_direction.x * speed)
			asset_state.set_current_z_velocity(move_direction.z * speed)
		# Otherwise set velocity to start slowing down
		elif is_on_floor():
			asset_state.set_current_x_velocity(move_toward(velocity.x, 0, speed))
			asset_state.set_current_z_velocity(move_toward(velocity.z, 0, speed))

func start_sprint() -> void:
	asset_state.start_sprinting()

func stop_sprint() -> void:
	asset_state.stop_sprinting()

## Character rotates on y axis; Multiplier can be applied
func rotate_y_axis(rotation_amount: float) -> void:
	asset_state.apply_rotation(Vector3(0, rotation_amount, 0))

## Returns the height of Chuck
func get_vertical_length() -> float:
	return asset_state.get_vertical_length()

## Returns true if movement is disabled
func is_movement_disabled() -> bool:
	return !asset_state.is_movement_enabled()

## Returns true if movement is enabled
func is_movement_enabled() -> bool:
	return asset_state.is_movement_enabled()

## Disables movement
func disable_movement() -> void:
	asset_state.update_movement_enabled(false)

## Enables movement
func enable_movement() -> void:
	asset_state.update_movement_enabled(true)

## Toggles movement enablement
func toggle_movement() -> void:
	var movement_enabled: bool = asset_state.is_movement_enabled()
	asset_state.update_movement_enabled(movement_enabled)

## Returns true if rotation is enabled
func is_rotation_enabled() -> bool:
	return asset_state.is_rotation_enabled()

## Returns true if rotation is disabled
func is_rotation_disabled() -> bool:
	return !asset_state.is_rotation_enabled()

## Disables rotation
func disable_rotation() -> void:
	asset_state.update_rotation_enabled(true)

## Enables rotation
func enable_rotation() -> void:
	asset_state.update_rotation_enabled(false)

## Toggles rotation enablement
func toggle_rotation() -> void:
	var currently_enabled: bool = asset_state.is_rotation_enabled()
	asset_state.update_rotation_enabled(not currently_enabled)

func get_asset_state() -> AssetState:
	if asset_state == null:
		var own_guid: String = self.get_meta(GroupData.GUID)
		own_guid = "" if own_guid == null else own_guid
		asset_state = AssetState.new(own_guid)
	return asset_state

func set_asset_state(new_state: AssetState) -> void:
	asset_state = new_state
