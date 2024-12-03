extends PlayableCharacter
class_name ChuckChucker

const UNEQUIP_MESSAGE: String = "unequip_item() called but no item is equiped"

@onready var diskController: Node3D = $DiskController
@onready var cameraController: Node3D = $CameraController
@onready var frontDetection: ShapeCast3D = $FrontDetect
@onready var chuckMesh: MeshInstance3D = $ChuckMesh
@onready var playerCamera: Camera3D = $CameraController/CameraTarget/ChuckCamera

var playerDisk: ThrowableItem
var disableMovement: bool = false
var stopwatch: StopWatch = StopWatch.new()
var aimingNode: Node3D = Node3D.new()
var aimingControl: Node3D = Node3D.new()
var launchControl: Node3D = Node3D.new()
var height: float

var jumpDetected: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	height = chuckMesh.get_aabb().size.y

func _physics_process(delta: float) -> void:
	self._handle_camera_controls()
	self._handle_player_action(delta)
	self._handle_player_interact()
	self._handle_movement(delta)

## Actions to be performed when MOVE_JUMP is pressed
func _handle_jump(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.JUMP) and is_on_floor() and not disableMovement:
		velocity.y = GlobalSettings.PLAYER.JUMP_FORCE

## Rotation and aiming logic
func _handle_camera_controls() -> void:
	# Left and right rotation inputs
	if not disableMovement:
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_LEFT):
			cameraController.rotate_y(deg_to_rad(GlobalSettings.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(GlobalSettings.CAMERA.ROTATE_SPEED))
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_RIGHT):
			cameraController.rotate_y(deg_to_rad(-GlobalSettings.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(-GlobalSettings.CAMERA.ROTATE_SPEED))

## Actions when disk is thrown
func _handle_player_action(delta: float) -> void:
	if playerDisk != null:
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY):
			playerDisk.hold_action(delta)
		if Input.is_action_just_released(CONSTANTS.USER_INPUT.PRIMARY):
			playerDisk.release_action()

## Handle player pressing interact button
func _handle_player_interact() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.INTERACT) and frontDetection.is_colliding():
		var collidingCount = frontDetection.get_collision_count()
		for n in collidingCount:
			var collidingObject = frontDetection.get_collider(0)
			if collidingObject != null and (collidingObject is PathDisk or collidingObject is ChuckDisk):
				if collidingObject is ChuckDisk:
					if collidingObject.diskType == ThrowableItem.TYPE.CHARGE:
						var newChargeMesh = ChargeDisk.new_disk()
						self.diskController.add_child(newChargeMesh)
						playerDisk = newChargeMesh
						playerDisk.fallbackCamera = playerCamera
						playerDisk.ownerVar = self
					elif collidingObject.diskType == ThrowableItem.TYPE.PATH:
						var newPullMesh = PullDisk.new_disk()
						self.diskController.add_child(newPullMesh)
						playerDisk = newPullMesh
						playerDisk.fallbackCamera = playerCamera
						playerDisk.ownerVar = self
						playerDisk.pullDraw.ownerVar = self
					playerDisk.rotate_parent.connect(self._handle_rotation)
				collidingObject.queue_free()

# Handles rotation signals from held nodes
func _handle_rotation(rotationAmount: float) -> void:
	var isMinRotate: bool = rotationAmount > 0 and self.diskController.rotation_degrees.x < GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION
	var isMaxRotate: bool = rotationAmount < 0 and self.diskController.rotation_degrees.x > GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION
	if isMinRotate or isMaxRotate:
		var projectedRotation: float
		if rotationAmount > 0:
			projectedRotation = rad_to_deg(rotationAmount + self.diskController.rotation.x)
			if projectedRotation > GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION:
				self.diskController.rotation_degrees.x = GlobalSettings.PLAYER.MAX_LAUNCH_ROTATION
			else:
				self.diskController.rotate_x(rotationAmount)
		else:
			projectedRotation = rad_to_deg(rotationAmount + self.diskController.rotation.x)
			if projectedRotation < GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION:
				self.diskController.rotation_degrees.x = GlobalSettings.PLAYER.MIN_LAUNCH_ROTATION
			else:
				self.diskController.rotate_x(rotationAmount)

## Detects and executes movements
func _handle_movement(delta: float) -> void:
	# Handle jump
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.JUMP) and is_on_floor() and not disableMovement:
		velocity.y = GlobalSettings.PLAYER.JUMP_FORCE
	var input_dir = Input.get_vector(CONSTANTS.USER_INPUT.STRAFE_LEFT, CONSTANTS.USER_INPUT.STRAFE_RIGHT, CONSTANTS.USER_INPUT.FORWARD, CONSTANTS.USER_INPUT.BACKWARD)
	if(self.is_on_floor()):
		var direction = (cameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if self.is_equipped() || disableMovement:
				velocity.x = 0
				velocity.z = 0
			else:
				var sprintAddition: float = 0.0
				if Input.is_action_pressed(CONSTANTS.USER_INPUT.SPRINT):
					sprintAddition = GlobalSettings.PLAYER.SPRINT_SPEED
					self._zoom_out()
				else:
					self._reset_zoom()
				velocity.x = direction.x * (GlobalSettings.PLAYER.RUN_SPEED + sprintAddition)
				velocity.z = direction.z * (GlobalSettings.PLAYER.RUN_SPEED + sprintAddition)
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, GlobalSettings.PLAYER.RUN_SPEED)
			velocity.z = move_toward(velocity.z, 0, GlobalSettings.PLAYER.RUN_SPEED)
	self.move_and_slide()
	# Keep camera up
	cameraController.position = lerp(cameraController.position, position, GlobalSettings.CAMERA.PAN_SPEED)

## Toggles the visibility logic when character has item equiped
func unequip_item() -> void:
	if playerDisk != null:
		playerDisk.queue_free()
		playerDisk.rotate_parent.disconnect(self._handle_rotation)
	else:
		Logger.warn(UNEQUIP_MESSAGE, [], self)
	# Reset item controller rotation
	self.diskController.rotation_degrees.x = 0

## Returns if character has item equipped
func is_equipped() -> bool:
	return playerDisk != null

## Returns the height of Chuck
func get_height() -> float:
	return height

func get_camera() -> Camera3D:
	return $CameraController/CameraTarget/ChuckCamera

func _reset_zoom() -> void:
	playerCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV)

func _zoom_in() -> void:
	playerCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV) - GlobalSettings.CAMERA.get(CONSTANTS.IN_ADJUST)

func _zoom_out() -> void:
	playerCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV) + GlobalSettings.CAMERA.get(CONSTANTS.OUT_ADJUST)

func load_settings() -> void:
	_reset_zoom()
