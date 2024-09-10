extends PlayableCharacter
class_name ChuckChucker

# TODO Make disk power setable not chargeable
# TODO Have the spawned disks be equipable
# TODO Spawned disks should determine what gets picked up
# TODO Add esc menu
# TODO Add settings to esc menu
#		With ability to define used controls
# TODO Make FOV configurable between a certain range

@onready var diskController: Node3D = $DiskController
@onready var playerDisk: ThrowableItem = $DiskController/DiskMesh
@onready var cameraController: Node3D = $CameraController
@onready var frontDetection: ShapeCast3D = $FrontDetect
@onready var chuckMesh: MeshInstance3D = $ChuckMesh
@onready var playerCamera: Camera3D = $CameraController/CameraTarget/ChuckCamera
@onready var scorecard: Sprite3D = $ScorecardSprite

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
	self._handle_menus()

## Actions to be performed when MOVE_JUMP is pressed
func _handle_jump(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if Input.is_action_just_pressed(USER_INPUT.MOVE.JUMP) and is_on_floor() and not disableMovement:
		velocity.y = GLOBAL_SETTINGS.PLAYER.JUMP_FORCE

## Rotation and aiming logic
func _handle_camera_controls() -> void:
	# Left and right rotation inputs
	if not disableMovement:
		if Input.is_action_pressed(USER_INPUT.ROTATE.LEFT):
			cameraController.rotate_y(deg_to_rad(GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
		if Input.is_action_pressed(USER_INPUT.ROTATE.RIGHT):
			cameraController.rotate_y(deg_to_rad(-GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))
			self.rotate_y(deg_to_rad(-GLOBAL_SETTINGS.CAMERA.ROTATE_SPEED))

## Actions when disk is thrown
func _handle_player_action(delta: float) -> void:
	if playerDisk.visible:
		if Input.is_action_pressed(USER_INPUT.ACTION.PRIMARY):
			playerDisk.hold_action(delta)
		if Input.is_action_just_released(USER_INPUT.ACTION.PRIMARY):
			playerDisk.release_action()
			self.toggle_equiped(false)

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
func _handle_movement(delta: float) -> void:
	# Handle jump
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed(USER_INPUT.MOVE.JUMP) and is_on_floor() and not disableMovement:
		velocity.y = GLOBAL_SETTINGS.PLAYER.JUMP_FORCE
	var input_dir = Input.get_vector(USER_INPUT.MOVE.LEFT, USER_INPUT.MOVE.RIGHT, USER_INPUT.MOVE.FORWARD, USER_INPUT.MOVE.BACKWARD)
	if(self.is_on_floor()):
		var direction = (cameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			if self.is_equipped() || disableMovement:
				velocity.x = 0
				velocity.z = 0
			else:
				var sprintAddition: float = 0.0
				if Input.is_action_pressed(USER_INPUT.MOVE.SPRINT):
					sprintAddition = GLOBAL_SETTINGS.PLAYER.SPRINT_SPEED
					self._zoom_out()
				else:
					self._reset_zoom()
				velocity.x = direction.x * (GLOBAL_SETTINGS.PLAYER.RUN_SPEED + sprintAddition)
				velocity.z = direction.z * (GLOBAL_SETTINGS.PLAYER.RUN_SPEED + sprintAddition)
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, GLOBAL_SETTINGS.PLAYER.RUN_SPEED)
			velocity.z = move_toward(velocity.z, 0, GLOBAL_SETTINGS.PLAYER.RUN_SPEED)
	self.move_and_slide()
	# Keep camera up
	cameraController.position = lerp(cameraController.position, position, GLOBAL_SETTINGS.CAMERA.PAN_SPEED)

func _handle_menus() -> void:
		if Input.is_action_pressed(USER_INPUT.MENU.SCORE):
			disableMovement = true
			if playerCamera.current:
				scorecard.visible = true
				get_viewport().get_camera_3d().look_at(scorecard.global_position)
		if Input.is_action_just_released(USER_INPUT.MENU.SCORE):
			disableMovement = false
			if playerCamera.current:
				scorecard.visible = false
				get_viewport().get_camera_3d().rotation = Vector3.ZERO

## Toggles the visibility logic when character has item equiped
func toggle_equiped(value: bool) -> void:
	playerDisk.visible = value

## Returns if character has item equipped
func is_equipped() -> bool:
	return playerDisk.visible

## Returns the height of Chuck
func get_height() -> float:
	return height

func get_camera() -> Camera3D:
	return $CameraController/CameraTarget/ChuckCamera

func _reset_zoom() -> void:
	playerCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV

func _zoom_in() -> void:
	playerCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV - GLOBAL_SETTINGS.CAMERA.IN_ADJUST

func _zoom_out() -> void:
	playerCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV + GLOBAL_SETTINGS.CAMERA.OUT_ADJUST

func reset_justLaunched() -> void:
	playerDisk.set_just_launched(false)
