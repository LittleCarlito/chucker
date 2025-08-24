extends CharacterBody3D
class_name BaseCharacter

const _NO_CAMERA_CONTAINER_LOG: String = "New item \"%s\" doesn't have the ability to hold a camera"
const _EMPTY_CAMERA_CONTAINER: String = "CameraContainer from \"%s\" returned null"

@export var base_mesh: MeshInstance3D
@export var base_collision: CollisionShape3D
@export var camera_container: CameraContainer

var height: float
var _initial_camera_orientation: Transform3D
var disable_movement_var: bool = false
var disable_rotation_var: bool = false

func _ready() -> void:
	self.height = base_mesh.get_aabb().size.y
	_initial_camera_orientation = camera_container.global_transform
	self.camera_container.populate_camera_control(self._get_focus_point())

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

## Movement functions

## Character jumps; Multiplier can be applied
func jump(jump_multiplier: float = 1) -> void:
	if self.is_on_floor() and self.is_movement_enabled():
		self.velocity.y = GameConfig.DEFAULTS.jump_force * jump_multiplier

## Character moves; Multiplier can be applied
func move(move_direction: Vector3, speed_multiplier: float = 1) -> void:
	if is_movement_disabled():
		velocity.x = 0
		velocity.z = 0
	else:
		if move_direction:
			velocity.x = move_direction.x * (GameConfig.DEFAULTS.run_speed * speed_multiplier)
			velocity.z = move_direction.z * (GameConfig.DEFAULTS.run_speed * speed_multiplier)
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, GameConfig.DEFAULTS.run_speed)
			velocity.z = move_toward(velocity.z, 0, GameConfig.DEFAULTS.run_speed)
	move_and_slide()

## Character rotates on y axis; Multiplier can be applied
func rotate_y_axis(rotation_amount: float) -> void:
	self.rotate_y(rotation_amount)

## Applies gravity
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

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

## Camera functions

func rotate_camera(vertical_rotation: float, horizontal_rotation: float) -> void:
	if _can_vertically_rotate(vertical_rotation):
		camera_container.veritcal_rotate(vertical_rotation)
	if _can_horizontally_rotate(horizontal_rotation):
		camera_container.horizontal_rotate(horizontal_rotation)

func zoom_in(zoom_amount: float = NUMBERS.FLOAT16_MAX) -> void:
	self.camera_container.zoom_in(zoom_amount)

func zoom_out(zoom_amount: float = NUMBERS.FLOAT16_MAX) -> void:
	self.camera_container.zoom_out(zoom_amount)

func reset_zoom() -> void:
	self.camera_container.reset_zoom();

func horizontal_pan(rotation_amount: float, focus_location: Vector3 = Vector3.INF) -> void:
	self.camera_container.horizontal_pan(rotation_amount, focus_location)

func snap_back(incoming_rotation: float = NUMBERS.FLOAT16_MAX) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	self.camera_container.snap_back(incoming_rotation)

func set_camera(incoming_camera: Camera3D) -> void:
	self.camera_container.set_camera(incoming_camera)

func disable_camera() -> void:
	self.camera_container.disable_camera()

func enable_camera() -> void:
	self.camera_container.enable_camera()

func _reset_camera_control() -> void:
	self.camera_container.reset_camera_control()

func _handle_horizontal_rotation(incoming_rotation: float = NUMBERS.FLOAT16_MAX) -> void:
	var rotation_amount = incoming_rotation if incoming_rotation != NUMBERS.FLOAT16_MAX else deg_to_rad(CameraConfig.get_rotate_speed())
	self.rotate_y_axis(rotation_amount)
	Logger.debug("I CAUGHT IT; %03f", [incoming_rotation], self)
	# TODO assign to variable = f incoming_rotation is the max default value assign it to the GameConfig rotation amount value
	# TODO Rotate base character (self) determined amount
	pass

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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if camera_container.is_current():
		camera_container.zoom_in()

func _handle_zoom_out() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	camera_container.snap_back(self.global_rotation.z)

func _get_focus_point() -> Vector3:
	var focus_point: Vector3 = self.position + CameraConfig.get_player_focus_offset()
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

func _give_camera(new_item: Node3D) -> void:
	if new_item is CameraContainer or new_item.has_method(GroupData.GET_CAMERA_CONTAINER):
		var pulled_camera_container: CameraContainer
		if new_item is not CameraContainer:
			# TODO Implement _get_camera_container on assets that you would want to ahve the camera while equipped (might be none, maybe do one for fun)
			pulled_camera_container = new_item.call(GroupData.GET_CAMERA_CONTAINER)
			if pulled_camera_container == null:
				Logger.debug(_EMPTY_CAMERA_CONTAINER, [str(new_item)], self) 
		else:
			pulled_camera_container = new_item as CameraContainer
		if pulled_camera_container != null:
			camera_container.give_camera(pulled_camera_container)
		else:
			var formatted_string: String = _NO_CAMERA_CONTAINER_LOG + Logger.LOG_SEPARATOR + Logger.KEEPING_CAMERA
			Logger.debug(formatted_string, [str(new_item)], self)
	else:
		var formatted_string: String = _NO_CAMERA_CONTAINER_LOG + Logger.LOG_SEPARATOR + Logger.KEEPING_CAMERA
		Logger.debug(formatted_string, [str(new_item)], self)
