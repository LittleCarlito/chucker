extends PlayableCharacter
class_name ChuckChucker

const _UKNOWN_OBJECT_LOG: String = "Tried to pick up UKNOWN object; Where did you get that?"
const _UNEQUIP_MESSAGE_LOG: String = "unequip_item() called but no item is equiped"

@onready var item_controller: Node3D = $ItemController
@onready var camera_controller: Node3D = $CameraController
@onready var front_detection: ShapeCast3D = $FrontDetect
@onready var chuck_mesh: MeshInstance3D = $ChuckMesh
@onready var player_camera: Camera3D = $CameraController/CameraTarget/ChuckCamera

var player_item: ThrowableItem
var stopwatch: Stopwatch = Stopwatch.new()
var height: float

# BUG After throwing the disk a second time mesh was spun sidways but controls remained normal (cube rotated on y axis)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	height = chuck_mesh.get_aabb().size.y

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
	if is_movement_enabled():
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_LEFT):
			camera_controller.rotate_y(deg_to_rad(GlobalSettings.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(GlobalSettings.CAMERA.ROTATE_SPEED))
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_RIGHT):
			camera_controller.rotate_y(deg_to_rad(-GlobalSettings.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(-GlobalSettings.CAMERA.ROTATE_SPEED))

## Actions when disk is thrown
func _handle_player_action(delta: float) -> void:
	if player_item != null:
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY):
			player_item.hold_action(delta)
		if Input.is_action_just_released(CONSTANTS.USER_INPUT.PRIMARY):
			player_item.release_action()

## Handle player pressing interact button
func _handle_player_interact() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.INTERACT) and front_detection.is_colliding():
		var colliding_count = front_detection.get_collision_count()
		for n in colliding_count:
			var colliding_object = front_detection.get_collider(0)
			Logger.debug("%s", [str(colliding_object)], colliding_object)
			if colliding_object != null:
				if colliding_object is RigidDisk:
					var rigid_disk: RigidDisk = colliding_object as RigidDisk
					match rigid_disk.get_item_type():
						CONSTANTS.DISK_TYPE.FORCE:
							player_item = ChargeDisk.new_object(CONSTANTS.DISK_TYPE.FORCE, self, player_camera)
						CONSTANTS.DISK_TYPE.PATH:
							player_item = PullDisk.new_object(self, player_camera, CONSTANTS.DISK_TYPE.PATH)
							#playerDisk.prepare_item(newType, newThrower, newDiskCamera)
						_:
							Logger.error(_UKNOWN_OBJECT_LOG, [], self)
					# Connect the playerDisk rotation signal to chucker
					if player_item != null:
						player_item.rotate_parent.connect(_handle_rotation)
						item_controller.add_child(player_item)
					rigid_disk.pick_up()
				else:
					# TODO Should really figure out something else to do here
					colliding_object.queue_free()

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
		var direction = (camera_controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if is_equipped() || is_movement_disabled()  :
				velocity.x = 0
				velocity.z = 0
			else:
				var sprint_addition: float = 0.0
				if Input.is_action_pressed(CONSTANTS.USER_INPUT.SPRINT):
					sprint_addition = GlobalSettings.PLAYER.SPRINT_SPEED
					_zoom_out()
				else:
					_reset_zoom()
				velocity.x = direction.x * (GlobalSettings.PLAYER.RUN_SPEED + sprint_addition)
				velocity.z = direction.z * (GlobalSettings.PLAYER.RUN_SPEED + sprint_addition)
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, GlobalSettings.PLAYER.RUN_SPEED)
			velocity.z = move_toward(velocity.z, 0, GlobalSettings.PLAYER.RUN_SPEED)
	move_and_slide()
	# Keep camera up
	camera_controller.position = lerp(camera_controller.position, position, GlobalSettings.CAMERA.PAN_SPEED)

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

## Returns the height of Chuck
func get_height() -> float:
	return height

# TODO Replace all of below with calls to CameraContainer once it replaces internal camera in object
#		Should be able to delete all these
func get_camera() -> Camera3D:
	return player_camera

func _reset_zoom() -> void:
	player_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV)

func _zoom_in() -> void:
	player_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV) - GlobalSettings.CAMERA.get(CONSTANTS.IN_ADJUST)

func _zoom_out() -> void:
	player_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV) + GlobalSettings.CAMERA.get(CONSTANTS.OUT_ADJUST)

func load_settings() -> void:
	_reset_zoom()
