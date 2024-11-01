extends RigidBody3D
class_name ChuckDisk

# TODO PreCollisionDetection box isn't doing anything
#		Add signal connection in PathDisk to awaken and add force to landing

const thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.SCENE)

@onready var diskMesh: MeshInstance3D = $DiskMesh
@onready var cameraContainer: Node3D = $CameraContainer
@onready var cameraControl: Node3D = $CameraContainer/CameraControl
@onready var diskCamera: Camera3D = $CameraContainer/CameraControl/DiskCamera
@onready var cameraTimer: Timer = $CameraContainer/CameraTimer

var diskType: ThrowableItem.TYPE
var thrower: ChuckChucker
var fallbackCamera: Camera3D
var collisionLocation: Vector3 = Vector3.INF
var collided: bool

func _ready() -> void:
	var parentObject: Object
	if self.get_parent() != null:
		parentObject = self.get_parent()
	if parentObject is ChuckTee:
		fallbackCamera = null
	var activeMaterial: StandardMaterial3D = diskMesh.get_active_material(0)
	activeMaterial.albedo_color = GLOBAL_SETTINGS.COLOR.CHARGE

# TODO This is the source of the issues for improperly colliding path disks
#		I think problem is it loses its camera for some reason
#			diskCamera.current being false makes it loop through the path never spawning a disk
func _process(delta: float) -> void:
	# Maintain minimum height for the camera
	cameraControl.global_position.y = max(GLOBAL_SETTINGS.CAMERA.MIN_HEIGHT, cameraControl.global_position.y)
	# Freeze the camera control when rigid body detects collision
	if self.get_contact_count() > 0 and diskCamera.current:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if !collided and diskCamera.current:
			# Initial collision so start timers
			cameraTimer.start(GLOBAL_SETTINGS.CAMERA.SHOT_WATCH_TIME)
			collided = true
			self.linear_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
			self.angular_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
		# Move camera control to where collision occured
		self._idle_rotate(delta)
	# Otherwise handle camera controls if camera is active
	else:
		if diskCamera.current:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and diskCamera.current:
		if event is InputEventMouseMotion:
			var horizontalRotateAmount: float = GLOBAL_SETTINGS.CONTROLS.INVERT_HORIZONTAL * (deg_to_rad(event.relative.x) * GLOBAL_SETTINGS.CONTROLS.HORIZONTAL_SENSITIVITY)
			cameraContainer.global_rotation_degrees.y += horizontalRotateAmount
			cameraControl.look_at(self.global_position)

func toggle_camera() -> void:
	diskCamera.current = not diskCamera.current

# TODO Camera is timing out after being thrown; That is why path disk is causing issues when being thrown second
#		What starts the timer?
func _on_camera_timer_timeout() -> void:
	diskCamera.current = false
	thrower.disableMovement = false
	fallbackCamera.current = true
	collisionLocation = Vector3.INF
	cameraContainer.top_level = false
	self.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	self.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	cameraTimer.stop()

static func new_disk(newdiskCamera: Camera3D, newThrower: ChuckChucker) -> ChuckDisk:
	var newDisk: ChuckDisk = thrownDisk.instantiate()
	newDisk.fallbackCamera = newdiskCamera
	newDisk.thrower = newThrower
	return newDisk

func _idle_rotate(delta: float) -> void:
	cameraContainer.top_level = true
	# Calculate the rotation angle in radians
	var rotationAmount: float = (GLOBAL_SETTINGS.CAMERA.IDLE_ROTATE_SPEED * delta)
	# Get the current global position of the Root object
	if collisionLocation == Vector3.INF:
		collisionLocation = self.global_position
	cameraContainer.global_rotation_degrees.y += rotationAmount
	cameraControl.look_at(collisionLocation)

func get_mesh() -> MeshInstance3D:
	return $DiskMesh
