extends RigidBody3D
class_name ChuckDisk

const thrownDisk: PackedScene = preload(SceneLibrary.DISK.SCENE)

@onready var throwableMesh: ThrowableDiskMesh = $ThrowableMesh

var expectedPath: Array[Vector3]
var launchAngle: float
var launchSpeed: float

func _ready() -> void:
	throwableMesh.prepare_item(CONSTANTS.DISK_TYPE.FORCE)

func _process(delta: float) -> void:
	# Freeze the camera control when rigid body detects collision
	if self.get_contact_count() > 0 and throwableMesh.is_camera_current():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if !throwableMesh.focused:
			# Focus camera on collision location
			throwableMesh.start_focus()
			self.linear_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
			self.angular_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
		throwableMesh.idle_rotate(delta)
	# Otherwise handle camera controls if camera is active
	else:
		if throwableMesh.is_camera_current() && !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func prepare_item(incomingType: CONSTANTS.DISK_TYPE, incomingOwner: ChuckChucker = null, incomingCamera: Camera3D = null) -> void:
	self.top_level = true
	var newThrowableMesh: ThrowableDiskMesh = ThrowableDiskMesh.new_disk()
	self.set_throwable_mesh(newThrowableMesh)
	newThrowableMesh.prepare_item(incomingType, incomingOwner, incomingCamera)

static func new_disk() -> ChuckDisk:
	var newDisk: ChuckDisk = thrownDisk.instantiate()
	return newDisk

## Applies force to the disk and sets launch parameters
## If no path is given camera is not triggered
func set_rigid_launch_parameters(incomingPath: Array[Vector3], multiplier: float, incomingAngle: float) -> void:
	expectedPath = incomingPath
	launchAngle = incomingAngle
	launchSpeed = GlobalSettings.DISK.LAUNCH_SPEED * multiplier
	self.rotate_x(launchAngle)
	self.linear_velocity = -self.global_transform.basis.z * launchSpeed
	if !incomingPath.is_empty():
		self.toggle_camera()

func get_type() -> CONSTANTS.DISK_TYPE:
	return throwableMesh.itemType

func toggle_camera() -> void:
	throwableMesh.toggle_camera()

func get_mesh() -> ThrowableDiskMesh:
	return $ThrowableMesh

func set_throwable_mesh(newThrowableMesh: ThrowableDiskMesh) -> void:
	self.add_child(newThrowableMesh)
	var oldThrowableMesh: ThrowableDiskMesh = throwableMesh
	if is_instance_valid(oldThrowableMesh):
		oldThrowableMesh.queue_free()
	self.throwableMesh = newThrowableMesh
