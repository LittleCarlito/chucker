extends PlayableCharacter
class_name ChuckChucker

const _UKNOWN_OBJECT_LOG: String = "Tried to pick up UKNOWN object; Where did you get that?"
const _NO_CAMERA_CONTAINER_LOG: String = "New item \"%s\" doesn't have the ability to hold a camera"
const _EMPTY_CAMERA_CONTAINER: String = "CameraContainer from \"%s\" returned null"

@onready var chuck_mesh: MeshInstance3D = $ChuckMesh
@onready var front_detection: ShapeCast3D = $FrontDetect
@onready var camera_container: CameraContainer = $CameraContainer
@onready var item_container: ItemContainer = $ItemContainer

# TODO Time for Groups
# 		Use of disks should be done through group method calls
#		This as the owner can call to prepare_launcher(flight_data)
#		Disks as members of the group should check their type
#			If LAUNCHER react to the signal/method call by preparing launcher
#		This as the owner can call to fire_launcher()
#		Disks as member of the group should check their type
#			If LAUNCHER reach to the signal/method by sending set flight_data and item_data to the factory
@export var item_data: AssetData
var stopwatch: Stopwatch = Stopwatch.new()
var height: float

# TODO Make sure states are properly set by objects at each state changing event
#		EXISTS, TRACKABLE, VIEWABLE
#		EXISTS - No internal containers; just the object
#		TRACKABLE - FocusContainer exists within it
#		VIEWABLE - Has a Camera3D within its FocusControl
# TODO Get ChuckChucker, mesh, and collision into a scene as BaseCharacter
#		Then make another scene off that one with controls in the script and a camera at creation called ControllableCharacter
# BUG After throwing the disk a second time mesh was spun sidways but controls remained normal (cube rotated on y axis)

func _ready() -> void:
	self.add_to_group(self.name)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	height = chuck_mesh.get_aabb().size.y
	camera_container.populate_camera_control(_get_focus_point())
	if item_data == null:
		item_data = AssetData.create_item_data(AssetData.TYPE.PLAYER)
	item_data.group_name = self.name
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
	if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_UP) || event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GlobalSettings.DISK.ROTATE_ADJUST
		if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		_handle_rotation(rotation_adjust)

## Actions to be performed when MOVE_JUMP is pressed
func _handle_jump(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.JUMP) and is_on_floor() and is_movement_enabled():
		velocity.y = GlobalSettings.PLAYER.JUMP_FORCE

## Rotation and aiming logic
func _handle_camera_controls() -> void:
	# Left and right rotation inputs
	if is_rotation_enabled():
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_LEFT):
			#camera_container.rotate_y(deg_to_rad(GlobalSettings.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(GlobalSettings.CAMERA.ROTATE_SPEED))
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_RIGHT):
			#camera_container.rotate_y(deg_to_rad(-GlobalSettings.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(-GlobalSettings.CAMERA.ROTATE_SPEED))

## Actions when disk is thrown
func _handle_player_action(delta: float) -> void:
	if item_container.is_equipped():
		# TODO Need to make sure disks that are capable of launching have these methods implemented
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY):
			get_tree().call_group(self.name, CONSTANTS.HOLD_ACTION, delta)
		if Input.is_action_just_released(CONSTANTS.USER_INPUT.PRIMARY):
			get_tree().call_group(self.name, CONSTANTS.RELEASE_ACTION)

# TODO FrontDetect should be made its own scene with this in its script
## Handle player pressing interact button
func _handle_player_interact() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.INTERACT) and front_detection.is_colliding():
		var colliding_count = front_detection.get_collision_count()
		for n in colliding_count:
			var colliding_object = front_detection.get_collider(0)
			Logger.debug("%s", [str(colliding_object)], colliding_object)
			if colliding_object != null and colliding_object is ForceDisk:
				AssetDelivery.create_and_give_item(self, colliding_object)

# TODO This should just be handled by this class without signals from below being needed
#		Should be checking if equipped (if necessary what type; group check)
#			Then handling rotation event and calling this method internally not from a signal
# Handles rotation signals from held nodes
func _handle_rotation(rotation_amount: float) -> void:
	var is_min_rotate: bool = rotation_amount > 0 and item_container.rotation_degrees.x < GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION
	var is_max_rotate: bool = rotation_amount < 0 and item_container.rotation_degrees.x > GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION
	if is_min_rotate or is_max_rotate:
		var projected_rotation: float
		if rotation_amount > 0:
			projected_rotation = rad_to_deg(rotation_amount + item_container.rotation.x)
			if projected_rotation > GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION:
				item_container.rotation_degrees.x = GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION
			else:
				item_container.rotate_x(rotation_amount)
		else:
			projected_rotation = rad_to_deg(rotation_amount + item_container.rotation.x)
			if projected_rotation < GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION:
				item_container.rotation_degrees.x = GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION
			else:
				item_container.rotate_x(rotation_amount)

## Detects and executes movements
func _handle_movement(delta: float) -> void:
	# Handle jump
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.JUMP) and is_on_floor() and is_movement_enabled():
		velocity.y = GlobalSettings.PLAYER.JUMP_FORCE
	var input_dir = Input.get_vector(CONSTANTS.USER_INPUT.STRAFE_LEFT, CONSTANTS.USER_INPUT.STRAFE_RIGHT, CONSTANTS.USER_INPUT.FORWARD, CONSTANTS.USER_INPUT.BACKWARD)
	if(is_on_floor()):
		var direction = (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if item_container.is_equipped() || is_movement_disabled():
				velocity.x = 0
				velocity.z = 0
			else:
				var sprint_addition: float = 0.0
				if Input.is_action_pressed(CONSTANTS.USER_INPUT.SPRINT):
					sprint_addition = GlobalSettings.PLAYER.SPRINT_SPEED
					camera_container.zoom_out()
				else:
					camera_container.reset_zoom()
				velocity.x = direction.x * (GlobalSettings.PLAYER.RUN_SPEED + sprint_addition)
				velocity.z = direction.z * (GlobalSettings.PLAYER.RUN_SPEED + sprint_addition)
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, GlobalSettings.PLAYER.RUN_SPEED)
			velocity.z = move_toward(velocity.z, 0, GlobalSettings.PLAYER.RUN_SPEED)
	move_and_slide()
	# Keep camera up
	#camera_container.position = lerp(camera_container.position, position, GlobalSettings.CAMERA.PAN_SPEED)

## Returns the height of Chuck
func get_height() -> float:
	return height

# TODO Not currently used; Should end up being used by Groups to regain control
func regain_focus() -> void:
	enable_movement()
	camera_container.enable_camera()

func reload_project_settings() -> void:
	camera_container.reset_zoom()

func _handle_looking(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		disable_movement()
		if camera_container.is_current():
			camera_container.zoom_in()
	elif event.is_action_released(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera_container.snap_back(self.global_basis)
		enable_movement()
	elif event is InputEventMouseMotion and Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		var v_rotation_amount: float = NodeUtil.get_vertical_rotation_amount(event)
		var h_rotation_amount: float = NodeUtil.get_horizontal_rotation_amount(event)
		if _can_horizontally_rotate(h_rotation_amount):
			camera_container.horizontal_rotate(h_rotation_amount)
		if _can_vertically_rotate(v_rotation_amount):
			camera_container.veritcal_rotate(v_rotation_amount)
		if item_container.is_equipped():
			_handle_rotation(v_rotation_amount)
	# Third person viewing self
	# Only occurs when unequipped and primary is held
	elif event.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY) and item_container.is_unequipped():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and (Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY) and item_container.is_unequipped()):
		## Determine amount to rotate camera
		var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
		camera_container.horizontal_pan(horizontal_rotate_amount, self.global_position)
	elif event.is_action_released(CONSTANTS.USER_INPUT.PRIMARY) and item_container.is_unequipped():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera_container.snap_back(self.global_basis)

func _can_horizontally_rotate(rotation_amount:float) -> bool:
	var potential_horizontal_roation: float = camera_container.get_horizontal_rotation() + rotation_amount
	var max_horizontal_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MAX_HORIZONTAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MAX_HORIZONTAL_ROTATION)
	var min_horizontal_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MIN_HORIZONTAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MIN_HORIZONTAL_ROTATION)
	return (potential_horizontal_roation > min_horizontal_value) and (potential_horizontal_roation < max_horizontal_value)

func _can_vertically_rotate(rotation_amount:float) -> bool:
	var potential_vertical_roation: float = camera_container.get_vertical_rotation() + rotation_amount
	var max_vertical_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MAX_VERTICAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MAX_VERTICAL_ROTATION)
	var min_vertical_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MIN_VERTICAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MIN_VERTICAL_ROTATION)
	return (potential_vertical_roation > min_vertical_value) and (potential_vertical_roation < max_vertical_value)

func _update_state() -> void:
	item_data.camera_state = AssetData.get_camera_state(camera_container)

func hold_action(delta: float) -> void:
	Logger.debug("I'm gonna chuck", [], self)

func release_action() -> void:
	# TODO Should probably be doing something with the unequip_item() where camera is offered up to the item_container
	#		If something spawns it will need to grab and reparent the camera
	disable_movement()
	disable_rotation()
	# TODO Expecting this will break; Doesn't lead to any code; Should probably be a call to item_container
	item_container.unequip_item()
	# TODO This should then update the status of the character if the item took the camera with it
	_update_state()

## Stores new_item internally and attempts to give it internal camera if possible
## Returns item that was equipped if one was previously
func equip_item(new_item: Node3D) -> Node3D:
	var displaced_item: Node3D = null
	_give_camera(new_item)
	# Returns the equipped item if there was one
	displaced_item = item_container.equip_item(new_item)
	_update_state()
	return displaced_item

func _give_camera(new_item: Node3D) -> void:
	if new_item is CameraContainer or new_item.has_method(CONSTANTS.GET_CAMERA_CONTAINER):
		var pulled_camera_container: CameraContainer
		if new_item is not CameraContainer:
			# TODO Implement _get_camera_container on assets that you would want to ahve the camera while equipped (might be none, maybe do one for fun)
			pulled_camera_container = new_item.call(CONSTANTS.GET_CAMERA_CONTAINER)
			if pulled_camera_container == null:
				Logger.debug(_EMPTY_CAMERA_CONTAINER, [str(new_item)], self) 
		else:
			pulled_camera_container = new_item as CameraContainer
		if pulled_camera_container != null:
			camera_container.give_camera(pulled_camera_container)
		else:
			var formatted_string: String = _NO_CAMERA_CONTAINER_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.KEEPING_CAMERA
			Logger.debug(formatted_string, [str(new_item)], self)
	else:
		var formatted_string: String = _NO_CAMERA_CONTAINER_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.KEEPING_CAMERA
		Logger.debug(formatted_string, [str(new_item)], self)

# TODO Some version of this should be implemented to handle when a deactivate_to_owner()
#func activate_fallback() -> void:
	#if fallback_camera != null:
		#fallback_camera.current = true
	#if item_owner != null:
		#item_owner.enable_movement()
		#item_owner.enable_rotation()
	#deactivate.emit()

func _get_focus_point() -> Vector3:
	var focus_point: Vector3 = self.position + GlobalSettings.CAMERA.get(CONSTANTS.PLAYER_FOCUS_OFFSET, GlobalSettings.CAMERA_DEFAULTS.PLAYER_FOCUS_OFFSET)
	return focus_point
