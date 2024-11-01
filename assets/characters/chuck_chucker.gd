extends PlayableCharacter
class_name ChuckChucker

# TODO Move button handling to objects that care about it
#		i.e. just adding PauseMenuView is enough to add esc
#				Will need to set owner or fallback camera or something to establish what to check for current
# TODO Add esc menu
#		Make cursor visible when menu is visible
#		Make buttons work
# TODO Add settings to esc menu
#		With ability to define used controls
# TODO Make FOV configurable between a certain range
# TODO Fix chucking a disk over the edge
#		Make Environment asset that is "CourseFloor"
#			Add a signal for body exit
#			Code to queue_free to start with
#				Eventually will want to respawn people and disks at certain points
#					People probably right where they fell in
#					Disks spawn near where they fell in but perpindicular to hole playing or something like that
# TODO Give chuck a bag he carries
#		Allow the bag to have 6 x 6 inventory where disks are stored and can be chosen/equipped


const UNEQUIP_MESSAGE: String = "unequip_item() called but no item is equiped"

@onready var diskController: Node3D = $DiskController
@onready var cameraController: Node3D = $CameraController
@onready var frontDetection: ShapeCast3D = $FrontDetect
@onready var chuckMesh: MeshInstance3D = $ChuckMesh
@onready var playerCamera: Camera3D = $CameraController/CameraTarget/ChuckCamera
@onready var scorecard: ScorecardView = $ScorecardView
@onready var pauseMenu: PauseMenu = $PauseMenu


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
	scorecard.set_pixel_size(GLOBAL_SETTINGS.MENU.SCORECARD.PLAYER_PIXEL_SIZE)

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
	if playerDisk != null:
		if Input.is_action_pressed(USER_INPUT.ACTION.PRIMARY):
			playerDisk.hold_action(delta)
		if Input.is_action_just_released(USER_INPUT.ACTION.PRIMARY):
			playerDisk.release_action()

## Handle player pressing interact button
func _handle_player_interact() -> void:
	# Detect obejects in front of the character
	if Input.is_action_just_pressed(USER_INPUT.ACTION.INTERACT) and frontDetection.is_colliding():
		var collidingCount = frontDetection.get_collision_count()
		for n in collidingCount:
			var collidingObject = frontDetection.get_collider(0)
			if collidingObject != null and (collidingObject is PathDisk or collidingObject is ChuckDisk):
				# TODO Refactor below to not be as repeated
				# TODO Can be buggy when launching charge disk as second disk
				#		Camera resets back to chuck too quickly
				# TODO Verify that a memory leak isn't happening with new disk meshes being accumulated in diskContainer
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
	# TODO This opens and closes like crazy
	if Input.is_action_pressed(USER_INPUT.MENU.MAIN) and not pauseMenu.visible:
		# TODO make this a safer check and not this
		pauseMenu.visible = true
		get_tree().paused = not get_tree().paused
	if Input.is_action_just_released(USER_INPUT.MENU.SCORE):
		disableMovement = false
		if playerCamera.current:
			scorecard.scorecardSprite.visible = false
			get_viewport().get_camera_3d().rotation = Vector3.ZERO
	if Input.is_action_pressed(USER_INPUT.MENU.SCORE):
		disableMovement = true
		if playerCamera.current:
			scorecard.scorecardSprite.visible = true
			get_viewport().get_camera_3d().look_at(scorecard.scorecardSprite.global_position)


## Toggles the visibility logic when character has item equiped
func unequip_item() -> void:
	if playerDisk != null:
		playerDisk.queue_free()
	else:
		# TODO Make warn push warning inside logger so 2 lines don't appear here
		Logger.warn(UNEQUIP_MESSAGE, [], self)
		push_warning(UNEQUIP_MESSAGE)

## Returns if character has item equipped
func is_equipped() -> bool:
	return playerDisk != null

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
