extends PlayableCharacter
class_name ChuckChucker

const _UKNOWN_OBJECT_LOG: String = "Tried to pick up UKNOWN object; Where did you get that?"
const _UNEQUIP_MESSAGE_LOG: String = "unequip_item() called but no item is equiped"

@onready var chuck_mesh: MeshInstance3D = $ChuckMesh
@onready var front_detection: ShapeCast3D = $FrontDetect
@onready var camera_container: CameraContainer = $CameraContainer
@onready var item_controller: Node3D = $ItemController

var player_item: ThrowableItem
var item_data: ItemData
var stopwatch: Stopwatch = Stopwatch.new()
var height: float

# TODO Rework CameraContainer to be FocusContainer
#		Each item and Character will have states
#			EXISTS, TRACKABLE, VIEWABLE
#			EXISTS - No internal containers; just the object
#			TRACKABLE - FocusContainer exists within it
#			VIEWABLE - Has a Camera3D within its FocusControl
# TODO Need to rework how CameraContainer follows and sets focus now that it isn't internal camera
#			CameraContainer also has its own input handling that might be doubling up movements and such
# TODO Get ChuckChucker, mesh, and collision into a scene as BaseCharacter
#		Then make another scene off that one with controls in the script and a camera at creation called ControllableCharacter
# BUG After throwing the disk a second time mesh was spun sidways but controls remained normal (cube rotated on y axis)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	height = chuck_mesh.get_aabb().size.y
	camera_container.populate_camera_control()
	if item_data == null:
		item_data = ItemData.create_item_type(ItemData.TYPE.PLAYER)
	_update_item_state()

func _input(event: InputEvent) -> void:
	_handle_looking(event)
	## Rotate input control
	if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_UP) || event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GlobalSettings.DISK.ROTATE_ADJUST
		if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		_handle_rotation(rotation_adjust)

func _physics_process(delta: float) -> void:
	_handle_camera_controls()
	_handle_player_action(delta)
	_handle_player_interact()
	_handle_movement(delta)

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
	if player_item != null:
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY):
			player_item.hold_action(delta)
		if Input.is_action_just_released(CONSTANTS.USER_INPUT.PRIMARY):
			player_item.release_action()

# TODO FrontDetect should be made its own scene with this in its script
## Handle player pressing interact button
func _handle_player_interact() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.INTERACT) and front_detection.is_colliding():
		var colliding_count = front_detection.get_collision_count()
		for n in colliding_count:
			var colliding_object = front_detection.get_collider(0)
			Logger.debug("%s", [str(colliding_object)], colliding_object)
			if colliding_object != null:
				if colliding_object is ForceDisk:
					var rigid_disk: ForceDisk = colliding_object as ForceDisk
					match rigid_disk.get_item_type():
						ItemData.TYPE.FORCE:
							player_item = ChargeDisk.new_object()
						ItemData.TYPE.PATH:
							player_item = PullDisk.new_object()
						_:
							Logger.error(_UKNOWN_OBJECT_LOG, [], self)
					# Connect the playerDisk rotation signal to chucker
					if player_item != null:
						# TODO Need to update the methods taking the camera in to reparent it to the object receiving it
						player_item.prepare_item(rigid_disk.get_item_type(), self, camera_container.get_camera())
						player_item.rotate_parent.connect(_handle_rotation)
						item_controller.add_child(player_item)
					rigid_disk.pick_up()
				else:
					# TODO Should really figure out something else to do here
					colliding_object.queue_free()

# TODO This should just be handled by this class without signals from below being needed
#		Should be checking if equipped (if necessary what type; group check)
#			Then handling rotation event and calling this method internally not from a signal
# Handles rotation signals from held nodes
func _handle_rotation(rotation_amount: float) -> void:
	var is_min_rotate: bool = rotation_amount > 0 and item_controller.rotation_degrees.x < GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION
	var is_max_rotate: bool = rotation_amount < 0 and item_controller.rotation_degrees.x > GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION
	if is_min_rotate or is_max_rotate:
		var projected_rotation: float
		if rotation_amount > 0:
			projected_rotation = rad_to_deg(rotation_amount + item_controller.rotation.x)
			if projected_rotation > GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION:
				item_controller.rotation_degrees.x = GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION
			else:
				item_controller.rotate_x(rotation_amount)
		else:
			projected_rotation = rad_to_deg(rotation_amount + item_controller.rotation.x)
			if projected_rotation < GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION:
				item_controller.rotation_degrees.x = GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION
			else:
				item_controller.rotate_x(rotation_amount)

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
			if is_equipped() || is_movement_disabled():
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

## Toggles the visibility logic when character has item equiped
func unequip_item() -> void:
	if player_item != null:
		player_item.rotate_parent.disconnect(_handle_rotation)
		player_item.queue_free()
	else:
		Logger.warn(_UNEQUIP_MESSAGE_LOG, [], self)
	# Reset item controller rotation
	item_controller.rotation_degrees.x = 0

## Returns if character has item equipped
func is_equipped() -> bool:
	return player_item != null

func is_unequipped() -> bool:
	return player_item == null

## Returns the height of Chuck
func get_height() -> float:
	return height

# TODO Should be connected to disks by factory creating them if set as owner_var
func regain_focus() -> void:
	enable_movement()
	camera_container.enable_camera()

func load_settings() -> void:
	camera_container.reset_zoom()

# TODO This should probably be in CameraContainer; It gives things the ability to aim
func _handle_looking(event: InputEvent) -> void:
	if event.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		disable_movement()
		if camera_container.is_current():
			camera_container.zoom_in()
	elif event.is_action_released(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera_container.snap_back(self.global_basis, self.global_position)
		enable_movement()
	elif event is InputEventMouseMotion and Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		var v_rotation_amount: float = NodeUtil.get_vertical_rotation_amount(event)
		var h_rotation_amount: float = NodeUtil.get_horizontal_rotation_amount(event)
		if _can_horizontally_rotate(h_rotation_amount):
			camera_container.horizontal_rotate(h_rotation_amount)
		if _can_vertically_rotate(v_rotation_amount):
			camera_container.veritcal_rotate(v_rotation_amount)
		if is_equipped():
			_handle_rotation(v_rotation_amount)
	# Third person viewing self
	# Only occurs when unequipped and primary is held
	elif event.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY) and is_unequipped():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and (Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY) and is_unequipped()):
		## Determine amount to rotate camera
		var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
		camera_container.horizontal_pan(horizontal_rotate_amount, self.global_position)
	elif event.is_action_released(CONSTANTS.USER_INPUT.PRIMARY) and is_unequipped():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera_container.snap_back(self.global_basis, self.global_position)

func _can_horizontally_rotate(rotation_amount:float) -> bool:
	var potential_horizontal_roation: float = camera_container.get_horizontal_rotation() + rotation_amount
	var max_horizontal_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MAX_HORIZONTAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MAX_HORIZONTAL_ROTATION)
	var min_horizontal_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MIN_HORIZONTAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MIN_HORIZONTAL_ROTATION)
	# TODO Determine if within bounds
	return (potential_horizontal_roation > min_horizontal_value) and (potential_horizontal_roation < max_horizontal_value)

func _can_vertically_rotate(rotation_amount:float) -> bool:
	var potential_vertical_roation: float = camera_container.get_vertical_rotation() + rotation_amount
	var max_vertical_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MAX_VERTICAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MAX_VERTICAL_ROTATION)
	var min_vertical_value: float = GlobalSettings.CAMERA.get(CONSTANTS.MIN_VERTICAL_ROTATION, GlobalSettings.CAMERA_DEFAULTS.MIN_VERTICAL_ROTATION)
	# TODO Determine if within bounds
	return (potential_vertical_roation > min_vertical_value) and (potential_vertical_roation < max_vertical_value)

## TODO Duplicate code
func _update_item_state() -> void:
	var updated_state: ItemData.STATE = ItemData.STATE.EXISTS
	if camera_container != null:
		updated_state = ItemData.STATE.TRACKABLE
		if camera_container.has_camera():
			updated_state = ItemData.STATE.VIEWABLE
			if camera_container.is_current():
				updated_state = ItemData.STATE.ACTIVE
	item_data.item_state = updated_state

# Handles signals from connected cameras to reparent them
func _release_camera(new_parent: Node = get_tree().root) -> void:
	camera_container.reparent_camera(new_parent)
