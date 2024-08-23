extends CharacterBody3D

const CHUCK_DISK = "ChuckDisk"
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_PAN_SPEED = .15
const CAMERA_ROTATE_SPEED = 4
const DISK_SPEED = 10

# TODO All String and number references to const
# TODO All $ object references to var

@export var thrownDisk: PackedScene = load("res://ChuckDisk.tscn")

# TODO Grabbing doesn't always work correctly
#			Can have AimLine appear but disk remain on ground and one above head not showing
#				Throwing disk then causes crash

func _physics_process(delta: float) -> void:
	# TODO Debug to check status of ChuckDisk
	var chuckDiskExists = $PinJoint3D/DiskController/DiskContainer/ChuckDisk != null
	print("ChuckDisk exists: " + str(chuckDiskExists))
	# Handle jump logic
	_handle_jump(delta)
	# Camera controls
	_handle_camera_controls()
	# Check for player action
	_handle_action()
	# Check for player interaction
	_handle_interact()
	# Check for character movement
	_handle_movement()

## Actions when disk is thrown
func _handle_action() -> void:
	if Input.is_action_just_pressed("player_action") and $PinJoint3D/DiskController/DiskContainer/ChuckDisk.visible:
		$PinJoint3D/DiskController/DiskContainer/ChuckDisk.visible = false
		$PinJoint3D/DiskController/DiskContainer/AimLine.visible = false
		# TODO Spawn a new disk into FirstHole scene originating from $DiskLauncher
		var newDisk = thrownDisk.instantiate()
		get_node("/root/FirstHole/DiskSpawn").add_child(newDisk)
		newDisk.global_transform = $PinJoint3D/DiskController/DiskLauncher.global_transform
		newDisk.linear_velocity = -newDisk.global_transform.basis.z * DISK_SPEED

## Actions to be performed when MOVE_JUMP is pressed
func _handle_jump(delta: float) -> void:
		# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

## Actions to be performed when ROTATE_CAMERA_LEFT 
## or ROTATE_CAMERA_RIGHT are pressed
func _handle_camera_controls() -> void:
	if Input.is_action_pressed("rotate_left"):
		$CameraController.rotate_y(deg_to_rad(CAMERA_ROTATE_SPEED))
		rotate_y(deg_to_rad(CAMERA_ROTATE_SPEED))
	if Input.is_action_pressed("rotate_right"):
		$CameraController.rotate_y(deg_to_rad(-CAMERA_ROTATE_SPEED))
		rotate_y(deg_to_rad(-CAMERA_ROTATE_SPEED))

## Handle player pressing interact button
func _handle_interact() -> void:
	if Input.is_action_just_pressed("player_interact") and $FrontDetect.is_colliding():
		var collidingCount = $FrontDetect.get_collision_count()
		for n in collidingCount:
			var collidingObject = $FrontDetect.get_collider(0)
			if collidingObject != null and collidingObject.name == CHUCK_DISK:
				$PinJoint3D/DiskController/DiskContainer/ChuckDisk.visible = true
				$PinJoint3D/DiskController/DiskContainer/AimLine.visible = true
				collidingObject.queue_free()

## Detects and executes movements
func _handle_movement() -> void:
		# If there is a direction to move set its velocity
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if(is_on_floor()):
		var direction = ($CameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		# Otherwise set velocity to start slowing down
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	# Keep camera up
	$CameraController.position = lerp($CameraController.position, position, CAMERA_PAN_SPEED)
