extends CharacterBody3D
class_name ChuckChucker

@export var thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.SCENE)

@onready var diskController: Node3D = $DiskController
@onready var diskContainer: Node3D = $DiskController/DiskContainer
@onready var playerDisk: MeshInstance3D = $DiskController/DiskContainer/PlayerDisk
@onready var diskLauncher: Node3D = $DiskController/DiskContainer/DiskLauncher
@onready var cameraController: Node3D = $CameraController
@onready var frontDetection: ShapeCast3D = $FrontDetect
var stopwatch: StopWatch = StopWatch.new()
var aimingNode: Node3D = Node3D.new()
var aimingControl: Node3D = Node3D.new()
var launchControl: Node3D = Node3D.new()

func _ready() -> void: 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	self._handle_jump(delta)
	self._handle_camera_controls()
	self._handle_player_action(delta)
	self._handle_player_interact()
	self._handle_movement()

## Actions when disk is thrown
func _handle_player_action(delta: float) -> void:
	#if playerDisk.visible:
		if Input.is_action_pressed(USER_INPUT.ACTION.PRIMARY):
			self._power_up_launch(delta)
		if Input.is_action_just_released(USER_INPUT.ACTION.PRIMARY):
			self._launch_disk()

## Actions to be performed when MOVE_JUMP is pressed
func _handle_jump(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if Input.is_action_just_pressed(USER_INPUT.MOVE.JUMP) and is_on_floor():
		velocity.y = GLOBAL_SETTINGS.PLAYER.JUMP_FORCE

## Handles camera/aiming related actions
func _handle_camera_controls() -> void:
	if Input.is_action_pressed(USER_INPUT.ROTATE.LEFT):
		cameraController.rotate_y(deg_to_rad(GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
		rotate_y(deg_to_rad(GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
	if Input.is_action_pressed(USER_INPUT.ROTATE.RIGHT):
		cameraController.rotate_y(deg_to_rad(-GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
		rotate_y(deg_to_rad(-GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
	if playerDisk.visible:
		if Input.is_action_just_pressed(USER_INPUT.ROTATE.UP):
			diskContainer.rotate_x(deg_to_rad(GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
		if Input.is_action_just_pressed(USER_INPUT.ROTATE.DOWN):
			diskContainer.rotate_x(deg_to_rad(-GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))

## Handle player pressing interact button
func _handle_player_interact() -> void:
	if Input.is_action_just_pressed(USER_INPUT.ACTION.INTERACT) and frontDetection.is_colliding():
		var collidingCount = frontDetection.get_collision_count()
		for n in collidingCount:
			var collidingObject = frontDetection.get_collider(0)
			if collidingObject != null and collidingObject.name == ASSET_MANAGEMENT.DISK.NAME:
				self.toggle_equiped(true)
				collidingObject.queue_free()

## Detects and executes movements
func _handle_movement() -> void:
		# If there is a direction to move set its velocity
	var input_dir = Input.get_vector(USER_INPUT.MOVE.LEFT, USER_INPUT.MOVE.RIGHT, USER_INPUT.MOVE.FORWARD, USER_INPUT.MOVE.BACKWARD)
	if(is_on_floor()):
		var direction = (cameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * GLOBAL_SETTINGS.PLAYER.RUN_SPEED
			velocity.z = direction.z * GLOBAL_SETTINGS.PLAYER.RUN_SPEED
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, GLOBAL_SETTINGS.PLAYER.RUN_SPEED)
			velocity.z = move_toward(velocity.z, 0, GLOBAL_SETTINGS.PLAYER.RUN_SPEED)
	move_and_slide()
	# Keep camera up
	cameraController.position = lerp(cameraController.position, position, GLOBAL_SETTINGS.CAMERA.PAN_SPEED)

# TODO Refactor this kind of functionality into the object and out of the character
## Power up launch and create aim line
func _power_up_launch(delta: float) -> void:
	stopwatch.isHeld(delta)
	var heldTime: float = stopwatch.getTime()
	# TODO Need aiming nodes to follow chuck if he falls (they stay on current plane)
	# TODO Height of control nodes needs to be shorter to start with (beginning curve is huge)
	# TODO AimControl point should start closer on z access and get further as you charge
	# Handle aiming node
	aimingNode.position = self.global_position
	aimingNode.position.y = 0
	aimingNode.basis = self.global_basis
	var aimingTranslate: Vector3 = Vector3(0, 0, -(heldTime * 10))
	aimingNode.translate(aimingTranslate)
	DrawUtil.point(aimingNode.position)
	# Handle aiming control node
	aimingControl.position = aimingNode.position
	aimingControl.position.y += 1 + (.6 * heldTime)
	aimingControl.basis = aimingNode.basis
	var zDistance: float = diskContainer.position.z - aimingNode.position.z
	var aimControlTranslate: Vector3 = Vector3(0, 0, (zDistance/2))
	aimingControl.translate(aimControlTranslate)
	DrawUtil.point(aimingControl.position, .05, Color.ORANGE_RED)
	# Handle launch control node
	launchControl.position = self.global_position
	launchControl.position.y = min(aimingControl.position.y, 2)
	launchControl.basis = diskContainer.global_basis
	var launchControlTranslate: Vector3 = Vector3(0, 0, -(zDistance/2))
	launchControl.translate(launchControlTranslate)
	DrawUtil.point(launchControl.position, .05, Color.DEEP_PINK)
	print("zDistance " + str(zDistance))
	# Draw curve
	DrawUtil.curve(diskLauncher.global_position, launchControl.position, aimingControl.position, aimingNode.position)

## Launch disk and reset objects
func _launch_disk() -> void:
	var multiplier = min(stopwatch.getTime(), GLOBAL_SETTINGS.DISK.MAX_HOLD)
	stopwatch.reset()
	self.toggle_equiped(false)
	var newDisk = thrownDisk.instantiate()
	get_tree().get_root().add_child(newDisk)
	newDisk.global_transform = diskLauncher.global_transform
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * (GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier)
	diskContainer.rotation.x = 0

## Toggles the visibility logic when character has item equiped
func toggle_equiped(value: bool) -> void:
	playerDisk.visible = value
