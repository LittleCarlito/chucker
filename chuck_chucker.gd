extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_PAN_SPEED = .15
const CAMERA_ROTATE_SPEED = CAMERA_PAN_SPEED * 15;

var held_object: Object

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Camera controls
	if Input.is_action_pressed("rotate_left"):
		_handleLeftRotate()
	if Input.is_action_pressed("rotate_right"):
		_handleRightRotate()
	# Check for character movement
	_handleMovement()

## Actions to be performed when ROTATE_CAMERA_LEFT is pressed
func _handleLeftRotate() -> void:
	$CameraController.rotate_y(deg_to_rad(CAMERA_ROTATE_SPEED))
	rotate_y(deg_to_rad(CAMERA_ROTATE_SPEED))

## Actions to be performed when ROTATE_CAMERA_RIGHT is pressed
func _handleRightRotate() -> void:
	$CameraController.rotate_y(deg_to_rad(-CAMERA_ROTATE_SPEED))
	rotate_y(deg_to_rad(-CAMERA_ROTATE_SPEED))

## Detects and executes movements
func _handleMovement() -> void:
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
