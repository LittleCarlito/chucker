extends RigidBody3D
class_name ForceDisk

# TODO Continue from here
# TODO Override EquipableItem methods in DiskMesh
# TODO Imeplment camera_container stuff in ChuckChucker as well

const disk_scene: PackedScene = preload(SceneLibrary.DISK.FORCE_SCENE)

@onready var disk_mesh: DiskMesh = $DiskMesh

var expected_path: Array[Vector3]
var launch_angle: float
var launch_speed: float
var focus_on_launch = false

func _ready() -> void:
	disk_mesh.prepare_item(CONSTANTS.DISK_TYPE.FORCE)

func _process(delta: float) -> void:
	# Freeze the camera control when rigid body detects collision
	if self.get_contact_count() > 0 and disk_mesh.camera_container.is_current():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if !disk_mesh.camera_container.is_focused():
			# Focus camera on collision location
			disk_mesh.camera_container.start_focus()
			self.linear_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
			self.angular_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
		disk_mesh.idle_rotate(delta)
	# Otherwise handle camera controls if camera is active
	else:
		if disk_mesh.camera_container.is_current() && !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func prepare_item(incoming_type: CONSTANTS.DISK_TYPE, incoming_owner: ChuckChucker = null, incoming_camera: Camera3D = null) -> void:
	self.top_level = true
	var new_disk_mesh: DiskMesh = DiskMesh.new_object()
	set_disk_mesh(new_disk_mesh)
	new_disk_mesh.prepare_item(incoming_type, incoming_owner, incoming_camera)

static func new_object() -> ForceDisk:
	var new_disk: ForceDisk = disk_scene.instantiate()
	new_disk.name = new_disk.name + "-" + str(new_disk.get_instance_id())
	return new_disk

## Applies force to the disk and sets launch parameters
## If no path is given camera is not triggered
func set_rigid_launch_parameters(incoming_path: Array[Vector3], multiplier: float, incoming_angle: float) -> void:
	expected_path = incoming_path
	launch_angle = incoming_angle
	launch_speed = GlobalSettings.DISK.LAUNCH_SPEED * multiplier
	self.rotate_x(launch_angle)
	self.linear_velocity = -self.global_transform.basis.z * launch_speed
	if focus_on_launch:
		toggle_camera()

func get_type() -> CONSTANTS.DISK_TYPE:
	return disk_mesh.item_type

func toggle_camera() -> void:
	disk_mesh.toggle_camera()

func get_mesh() -> DiskMesh:
	return disk_mesh

func set_disk_mesh(new_mesh: DiskMesh) -> void:
	self.add_child(new_mesh)
	var old_mesh: DiskMesh = disk_mesh
	if is_instance_valid(old_mesh):
		old_mesh.queue_free()
	disk_mesh = new_mesh

func get_disk_camera() -> Camera3D:
	return disk_mesh.get_disk_camera()

func set_disk_camera(new_camera: Camera3D) -> void:
	disk_mesh.set_disk_camera(new_camera)
