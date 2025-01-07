extends PlayableCharacter
class_name ChuckChucker

const _UKNOWN_OBJECT_LOG: String = "Tried to pick up UNKNOWN object; Where did you get that?"
const _NO_CAMERA_CONTAINER_LOG: String = "New item \"%s\" doesn't have the ability to hold a camera"
const _EMPTY_CAMERA_CONTAINER: String = "CameraContainer from \"%s\" returned null"

@export var chuck_mesh: MeshInstance3D
@export var front_detection: ShapeCast3D
@export var camera_container: CameraContainer
@export var item_container: ItemContainer
@export var focusing_throws: bool

var asset_data: AssetData
var stopwatch: Stopwatch = Stopwatch.new()
var height: float
var _initial_camera_orientation: Transform3D
var _just_launched: bool = false

# TODO Get ChuckChucker, mesh, and collision into a scene as BaseCharacter
#		Then make another scene off that one with controls in the script and a camera at creation called ControllableCharacter

func _ready() -> void:
	_initial_camera_orientation = camera_container.global_transform
	self.add_to_group(self.name)
	camera_container.add_to_group(self.name)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	height = chuck_mesh.get_aabb().size.y
	camera_container.populate_camera_control(_get_focus_point())
	camera_container.set_current()
	if asset_data == null:
		asset_data = AssetDelivery.create_asset_data(AssetData.TYPE.PLAYER)
	asset_data.group_name = self.name
	_update_state()

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	_handle_camera_controls()
	_handle_player_action(delta)
	_handle_player_interact()
	_handle_movement(delta)

func _input(event: InputEvent) -> void:
	_handle_looking(event)
	## Rotate input control
	if event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_UP) || event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GameConfig.DEFAULTS.rotate_adjust
		if event.is_action_pressed(InputConfig.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		item_container._handle_x_rotation(rotation_adjust)

## Actions to be performed when MOVE_JUMP is pressed
func _handle_jump(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.JUMP) and is_on_floor() and is_movement_enabled():
		velocity.y = GameConfig.DEFAULTS.jump_force

## Rotation and aiming logic
func _handle_camera_controls() -> void:
	if is_rotation_enabled():
		# Left and right rotation inputs
		if Input.is_action_pressed(InputConfig.USER_INPUT.ROTATE_LEFT):
			self.rotate_y(deg_to_rad(CameraConfig.get_rotate_speed()))
		if Input.is_action_pressed(InputConfig.USER_INPUT.ROTATE_RIGHT):
			self.rotate_y(deg_to_rad(-CameraConfig.get_rotate_speed()))

## Actions when disk is thrown
func _handle_player_action(delta: float) -> void:
	if item_container.is_equipped():
		if Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY):
			item_container.hold_action(delta, focusing_throws)
		if Input.is_action_just_released(InputConfig.USER_INPUT.PRIMARY):
			item_container.release_action()

# TODO FrontDetect should be made its own scene with this in its script
## Handle player pressing interact button
func _handle_player_interact() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.INTERACT) and front_detection.is_colliding():
		var colliding_count = front_detection.get_collision_count()
		for n in colliding_count:
			var colliding_object = front_detection.get_collider(0)
			if colliding_object != null and colliding_object is ForceDisk:
				AssetDelivery.create_and_give_item(self, colliding_object)

## Detects and executes movements
func _handle_movement(delta: float) -> void:
	# Handle jump
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed(InputConfig.USER_INPUT.JUMP) and is_on_floor() and is_movement_enabled():
		velocity.y = GameConfig.DEFAULTS.jump_force
	var input_dir = Input.get_vector(InputConfig.USER_INPUT.STRAFE_LEFT, InputConfig.USER_INPUT.STRAFE_RIGHT, InputConfig.USER_INPUT.FORWARD, InputConfig.USER_INPUT.BACKWARD)
	if(is_on_floor()):
		var direction = (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if is_movement_disabled():
				velocity.x = 0
				velocity.z = 0
			else:
				var sprint_addition: float = 0.0
				if Input.is_action_pressed(InputConfig.USER_INPUT.SPRINT):
					sprint_addition = GameConfig.DEFAULTS.sprint_speed
					camera_container.zoom_out()
				elif camera_container.has_camera():
					camera_container.reset_zoom()
				velocity.x = direction.x * (GameConfig.DEFAULTS.run_speed + sprint_addition)
				velocity.z = direction.z * (GameConfig.DEFAULTS.run_speed + sprint_addition)
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, GameConfig.DEFAULTS.run_speed)
			velocity.z = move_toward(velocity.z, 0, GameConfig.DEFAULTS.run_speed)
	move_and_slide()
	# Keep camera up
	#camera_container.position = lerp(camera_container.position, position, GlobalSettings.CAMERA.PAN_SPEED)

## Returns the height of Chuck
func get_height() -> float:
	return height

func reload_project_settings() -> void:
	camera_container.reset_zoom()

func _handle_looking(event: InputEvent) -> void:
	# Only handle aiming mouse movements when not equipped
	if !is_equipped():
		# When secondary is pressed
		if event.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			_handle_zoom_in()
			disable_movement()
		# When secondary is released
		elif event.is_action_released(InputConfig.USER_INPUT.SECONDARY):
			_handle_zoom_out()
			if !_just_launched:
				enable_movement()
		# When secondary is pressend and it is movement
		elif event is InputEventMouseMotion and Input.is_action_pressed(InputConfig.USER_INPUT.SECONDARY):
			var v_rotation_amount: float = NodeUtil.get_vertical_rotation_amount(event)
			var h_rotation_amount: float = NodeUtil.get_horizontal_rotation_amount(event)
			if _can_horizontally_rotate(h_rotation_amount):
				camera_container.horizontal_rotate(h_rotation_amount)
			if _can_vertically_rotate(v_rotation_amount):
				camera_container.veritcal_rotate(v_rotation_amount)
	# Third person viewing self
	# Only occurs when unequipped and primary is held
	if event.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and item_container.is_unequipped():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and (Input.is_action_pressed(InputConfig.USER_INPUT.PRIMARY) and item_container.is_unequipped()):
		## Determine amount to rotate camera
		var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
		camera_container.horizontal_pan(horizontal_rotate_amount, self.global_position)
	elif event.is_action_released(InputConfig.USER_INPUT.PRIMARY) and item_container.is_unequipped():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera_container.snap_back(self.global_rotation.z)

func _handle_zoom_in() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if camera_container.is_current():
		camera_container.zoom_in()

func _handle_zoom_out() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	camera_container.snap_back(self.global_rotation.z)

func _handle_turn_horizontal(rotate_amount: float) -> void:
	## Determine amount to rotate camera
	var previous_orientation: Transform3D = camera_container.global_transform
	var horizontal_rotate_amount: float = rotate_amount * CameraConfig.get_horizontal_look_sens()
	self.global_rotation_degrees.y += horizontal_rotate_amount * GameConfig.DEFAULTS.rotation_multiplier
	camera_container.global_transform = previous_orientation

func _can_horizontally_rotate(rotation_amount:float) -> bool:
	var potential_horizontal_roation: float = camera_container.get_horizontal_rotation() + rotation_amount
	var max_horizontal_value: float = CameraConfig.get_max_horizontal_rotation()
	var min_horizontal_value: float = CameraConfig.get_min_horizontal_rotation()
	return (potential_horizontal_roation > min_horizontal_value) and (potential_horizontal_roation < max_horizontal_value)

func _can_vertically_rotate(rotation_amount:float) -> bool:
	var potential_vertical_roation: float = camera_container.get_vertical_rotation() + rotation_amount
	var max_vertical_value: float = CameraConfig.get_max_vertical_rotation()
	var min_vertical_value: float = CameraConfig.get_min_vertical_rotation()
	return (potential_vertical_roation > min_vertical_value) and (potential_vertical_roation < max_vertical_value)

# TODO Need to go through methods in and affecting this class and determine which need to have this method called after
#		Only should set enum state and not change enablement of movement or anything like that
func _update_state() -> void:
	asset_data.camera_state = AssetData.get_camera_state(camera_container)

# TODO Should come up with something; Maybe an unequip check and then some default interaction like a wiggle
func hold_action(_delta: float) -> void:
	pass

## Handles group calls on release_action
func release_action() -> void:
	# TODO Expecting this will break; Doesn't lead to any code; Should probably be a call to item_container
	unequip_item()
	# TODO This should then update the status of the character if the item took the camera with it
	_update_state()
	_just_launched = true
	# If the camera was released for the launch disable movement
	if asset_data.camera_state != AssetData.CAMERA_STATE.ACTIVE:
		disable_movement()
		disable_rotation()

## Stores new_item internally and attempts to give it internal camera if possible
## Returns item that was equipped if one was previously
func equip_item(new_item: Node3D) -> void:
	disable_movement()
	var displaced_item: Node3D = null
	_give_camera(new_item)
	# Returns the equipped item if there was one
	displaced_item = item_container.equip_item(new_item)
	if displaced_item != null:
		AssetDelivery.dump_asset(displaced_item)
	if new_item.has_signal(ThrowableItem.AIM):
		new_item.connect(ThrowableItem.AIM, item_container._handle_aiming)
	if new_item.has_signal(ThrowableItem.LAUNCHED):
		new_item.connect(ThrowableItem.LAUNCHED, release_action)
	_update_state()

func unequip_item(alter_movement: bool = false) -> void:
	if alter_movement and is_movement_disabled():
		enable_movement()
	item_container.unequip_item()

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

func _get_focus_point() -> Vector3:
	var focus_point: Vector3 = self.position + CameraConfig.get_player_focus_offset()
	return focus_point

func _transfer_and_enable(incoming_camera: Camera3D) -> void:
	if is_movement_disabled():
		enable_movement()
	if is_rotation_disabled():
		enable_rotation()
	camera_container.set_camera(incoming_camera)

func is_equipped() -> bool:
	return item_container.is_equipped()
