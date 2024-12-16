extends RigidBody3D
class_name ForceDisk

	# TODO Continue from here
	# TODO Get aiming from CameraContainer working properly in ChargeDisk
	# TODO Get looking/rotation/idling from CameraContainer working properly ForceDisk
	# TODO Shouldn't have to add special input handling
	#		As long as camera_container exists and its conditionals are met its handling should take effect
	#			Cause by inherit mode processing
	# TODO Need to work on passing camera along to what is active
	# TODO Use groups instead of item_owner/fallback_camera setup
	#			Each ChuckChucker has their own group created using their scene name
	#				Make sure the new_object type method adds to the name like disk types
	#			Each disk that is thrown is added to a group
	#				If it was not thrown by a person there should be an evironment group it belongs to
	#			Each disk type and ChuckChucker type should have a "item_lose_focus" method
	#				Item one will set camera current to false and queue_free self
	#				ChuckChucker type will enable camera and movement
	# TODO Make GlobalSignal handler
	#		Start with method to collect all movement signals from a group and log how many objects are moving every 3rd frame
	# TODO Instead of queue_freeing objects work on pooling and reusing them
	# TODO Look into using Entity Component System (ECS) over OOP
	#		How godot (and game dev in general) is done
	#		Composition over inheritance
	#		Want an equipable object? Have a node that makes things equipable and include that node in the one you want equipable
	#		Want a throwable object? Have a node that makes things throwable and include that node in the one you want throwable
	#		Want a disk looking object? Include the disk mesh scene in the one you want with that mesh
	#		Want a disk collision box? Include that
	#		The path disk would include above and the rigid disk would not include the disk mesh or collision box but instead the rigid disk scene
	# BUG Not sure about swap disk force adding direction; make sure it is the disk facing direction and not true north
	# TODO Swap out disk creation stuff in swap disk with DiskFactory usage
	# TODO See about slowing (maybe clamping) values as bounds get closer to make it feel like resistance

const disk_scene: PackedScene = preload(SceneLibrary.DISK.FORCE_SCENE)
const _MISSING_FLIGHT_DATA_LOG: String = "Launch parameters must be set before item can be launched"
const _NO_ITEM_DATA_LOG: String = "ItemData has not been initialized for this node"
const _CREATING_CAMERA_LOG: String = "Creating camera container"
const _SET_DISK_CAMERA: String = "set_disk_camera"
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
	_update_item_state()

func _process(_delta: float) -> void:
	pass

static func new_disk() -> ForceDisk:
	var new_force_disk: ForceDisk = disk_scene.instantiate()
	new_force_disk.name = new_force_disk.name + "-" + str(new_force_disk.get_instance_id())
	return new_force_disk

static func new_viewable_disk() -> ForceDisk:
	var new_force_disk: ForceDisk = ForceDisk.new_disk()
	new_force_disk._create_camera_container()
	return new_force_disk

func set_internal_type(new_internal_type: ItemData.TYPE) -> void:
	item_data.internal_type = new_internal_type
	disk_mesh.set_type(item_data.internal_type)

func set_creation_type(new_creation_type: ItemData.TYPE) -> void:
	item_data.creation_type = new_creation_type

func set_launch_parameters(incoming_path: Array[Vector3], incoming_speed: float, incoming_angle: float, is_focused: bool = false) -> void:
	flight_data = FlightData.create_flight_data(incoming_speed, incoming_angle, incoming_path, is_focused)

func launch_disk() -> void:
	if flight_data != null:
		self.rotate_x(flight_data.flight_angle)
		self.linear_velocity = -self.global_transform.basis.z * flight_data.flight_speed
		if flight_data.focus_flight:
			# TODO This should be changed to transfer camera or something along those lines
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

# TODO This should be changed to transfer camera or something along those lines
func toggle_camera() -> void:
	if camera_container != null && camera_container.has_camera():
		camera_container.toggle_camera()
	_update_item_state()

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
	if camera_container == null:
		var formattedString: String = CONSTANTS.NULL_CAMERA_LOG + CONSTANTS.LOG_SEPARATOR + _CREATING_CAMERA_LOG
		Logger.warn(formattedString, [_SET_DISK_CAMERA], self)
	_create_camera_container()
	camera_container.set_camera(new_camera)
	_update_item_state()

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

## Creates intneral camera_container object
## Should only be called intnernally
func _create_camera_container() -> void:
	if camera_container == null:
		var new_camera_container: CameraContainer = CameraContainer.new_container()
		self.add_child(new_camera_container)
		camera_container = new_camera_container
	else:
		Logger.warn(CONSTANTS.ALREADY_EXISTS_LOG, [CONSTANTS.CAMERA_CONTAINER], self)

func _update_item_state() -> void:
	var updated_state: ItemData.STATE = ItemData.STATE.EXISTS
	if camera_container != null:
		updated_state = ItemData.STATE.TRACKABLE
		if camera_container.has_camera():
			updated_state = ItemData.STATE.VIEWABLE
			if camera_container.is_current():
				updated_state = ItemData.STATE.ACTIVE
	item_data.item_state = updated_state
