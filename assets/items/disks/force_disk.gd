extends RigidBody3D
class_name ForceDisk

# TODO Current thing: Only having CameraContainer in Character objects to start
# TODO Have method in disks to create their own camera_container but by default the reference is null
# TODO When disk is thrown or disk launches another disk camera is passed along

const disk_scene: PackedScene = preload(SceneLibrary.DISK.FORCE_SCENE)
const _MISSING_FLIGHT_DATA_LOG: String = "Launch parameters must be set before item can be launched"
const _NO_ITEM_DATA_LOG: String = "ItemData has not been initialized for this node"
const _CREATING_CAMERA_LOG: String = "Creating camera container"
const _GET_DISK_CAMERA: String = "get_disk_camera"

signal lose_focus

@onready var disk_mesh: DiskMesh = $DiskMesh
@onready var disk_collision: DiskCollision = $DiskCollision
@export var item_data: ItemData
@export var flight_data: FlightData
var camera_container: CameraContainer

func _ready() -> void:
	if item_data == null:
		item_data = ItemData.create_item_type(GlobalSettings.DEFAULTS.ITEM as ItemData.TYPE)
	disk_mesh.set_type(item_data.internal_type)

func _process(_delta: float) -> void:
	pass

func prepare_item(incoming_type: ItemData.TYPE) -> void:
	item_data = ItemData.create_item_type(incoming_type, incoming_type)
	var new_disk_mesh: DiskMesh = DiskMesh.new_mesh()
	new_disk_mesh.set_type(incoming_type)

static func new_object() -> ForceDisk:
	var new_disk: ForceDisk = disk_scene.instantiate()
	new_disk.name = new_disk.name + "-" + str(new_disk.get_instance_id())
	return new_disk

func set_launch_parameters(incoming_path: Array[Vector3], incoming_speed: float, incoming_angle: float, is_focused: bool = false) -> void:
	flight_data = FlightData.create_flight_data(incoming_speed, incoming_angle, incoming_path, is_focused)

func launch_disk() -> void:
	if flight_data != null:
		self.rotate_x(flight_data.flight_angle)
		self.linear_velocity = -self.global_transform.basis.z * flight_data.flight_speed
		if flight_data.focus_flight:
			toggle_camera()
			if !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Logger.warn(_MISSING_FLIGHT_DATA_LOG, [], self)

func get_item_type() -> ItemData.TYPE:
	if item_data != null:
		return item_data.internal_type
	else:
		var formattedString: String = _NO_ITEM_DATA_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_UNKNOWN_LOG
		Logger.warn(formattedString, [], self)
		return ItemData.TYPE.UNKNOWN

func toggle_camera() -> void:
	if camera_container != null && camera_container.has_camera():
		camera_container.toggle_camera()

func get_mesh() -> DiskMesh:
	return disk_mesh

func set_disk_mesh(new_mesh: DiskMesh) -> void:
	self.add_child(new_mesh)
	var old_mesh: DiskMesh = disk_mesh
	if is_instance_valid(old_mesh):
		old_mesh.queue_free()
	disk_mesh = new_mesh

## Returns the camera from the disk
## Returns null if no camera exists
func get_disk_camera() -> Camera3D:
	var return_camera: Camera3D
	if camera_container != null:
		return_camera = camera_container.get_camera()
	else:
		var formattedString: String = CONSTANTS.NULL_CAMERA_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
		Logger.error(formattedString, [_GET_DISK_CAMERA], self)
	return return_camera

func set_disk_camera(new_camera: Camera3D) -> void:
	_create_camera_container()
	camera_container.set_camera(new_camera)

func _handle_collision(body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	disk_collision.store_collision(self.get_rid(), body_rid, self.global_position, flight_data, item_data)
	if camera_container != null && (camera_container.has_camera() && camera_container.is_current()):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if !camera_container.is_focused():
			# Focus camera on collision location
			camera_container.start_focus()
			camera_container.focus_camera(self.global_position)
			camera_container._idle_rotate = true
			self.linear_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
			self.angular_damp_mode = RigidBody3D.DAMP_MODE_COMBINE

# TODO Move this to holders of the CameraContainer Resource
# TODO Make sure you connect the signal to the item_owner in the factory
#		If doing above then no longer need to pass in and store item_owner and fallback_camera
# TODO Change this to be a group call that that activates the owner and deactivates the disks
func _on_lose_focus() -> void:
	lose_focus.emit()

func pick_up() -> void:
	self.queue_free()

func _create_camera_container() -> void:
	if camera_container == null:
		var new_camera_container: CameraContainer = CameraContainer.new_container()
		self.add_child(new_camera_container)
		camera_container = new_camera_container
	else:
		Logger.warn(CONSTANTS.ALREADY_EXISTS_LOG, [CONSTANTS.CAMERA_CONTAINER], self)
