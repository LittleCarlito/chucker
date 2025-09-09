extends RigidBody3D
class_name ForceDisk

	# TODO Continue
	# TODO Get character stuff into state based
	#			Jumping, moving, aiming, etc have it all determine an ENUM in the character
	# TODO Add lerp to camera handoffs
	#			make lerp speed global setting configurable
	# TODO Need to work on passing camera along to what is active
	# TODO Use groups instead of item_owner/fallback_camera setup
	#			Each ChuckChucker has their own group created using their scene name
	#				Make sure the new_object type method adds to the name like disk types
	#			Each disk that is thrown is added to a group
	#				If it was not thrown by a person there should be an evironment group it belongs to
	#			Each disk type and ChuckChucker type should have a "item_lose_focus" method
	#				Item one will set camera current to false and queue_free self
	#				ChuckChucker type will enable camera and movement
	# TODO Instead of queue_freeing objects work on pooling and reusing them
	# TODO See about slowing (maybe clamping) values as bounds get closer to make it feel like resistance

const _NO_ITEM_DATA_LOG: String = "AssetData has not been initialized for this node"
const _CREATING_CAMERA_LOG: String = "Creating camera container"
const _SET_DISK_CAMERA: String = "set_disk_camera"
const _GET_DISK_CAMERA: String = "get_disk_camera"

@export var disk_mesh: DiskMesh
@export var disk_collision: DiskCollision
var asset_data: AssetData
var flight_data: FlightData
var camera_container: CameraContainer
var _collided: bool = false
var _applied_flight_data: bool = false

# TODO Fix to use variable below when switching to new camera
#			Right now shit in CameraContainer is used but it will need to be from state instead
# TODO Need to get below used from CameraState from AssetData instead
#			When camera rig takes something in to focus it it needs to set the camera status to TRACKED
#			Other camera states need to be changed to AVAILABLE, UNAVAILABLE (for if camera can't view it), and UKNOWN (edge cases; should error)
# TODO Ensure the camera state is properly tracked in other objects the camera can track as well (i.e. path disk, etc)
var _is_tracked: bool = false

func _ready() -> void:
	if self.asset_data == null:
		self.asset_data = AssetData.new(AssetData.TYPE.FORCE)
		if !self.asset_data.group_name.is_empty():
			add_to_group(self.asset_data.group_name)
	self.disk_mesh.set_type(self.asset_data.creation_type)
	self.angular_damp = 0.0
	GlobalInputController.connect(SIGNAL_NAME.FREELOOK_MOTION, _handle_freelook_motion)

func _process(_delta: float) -> void:
	if self.flight_data != null && not self._applied_flight_data:
		self.angular_velocity.y = self.flight_data.get_flight_spin()
		self._applied_flight_data = true

func set_internal_type(new_internal_type: AssetData.TYPE) -> void:
	asset_data.set_internal_type(new_internal_type)
	disk_mesh.set_type(asset_data.internal_type)

func set_creation_type(new_creation_type: AssetData.TYPE) -> void:
	asset_data.creation_type = new_creation_type

func get_item_type() -> AssetData.TYPE:
	if asset_data != null:
		return asset_data.internal_type
	else:
		var formatted_string: String = _NO_ITEM_DATA_LOG + Logger.LOG_SEPARATOR + Logger.RETURNING_UNKNOWN_LOG
		Logger.warn(formatted_string, [], self)
		return AssetData.TYPE.UNKNOWN

# TODO This should be changed to transfer camera or something along those lines
func toggle_camera() -> void:
	if camera_container != null && camera_container.has_camera():
		camera_container.toggle_camera()

func get_mesh() -> DiskMesh:
	return disk_mesh

func sync_asset() -> void:
	disk_mesh.set_type(asset_data.creation_type)

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
		var formatted_string: String = Logger.NULL_CAMERA_LOG + Logger.LOG_SEPARATOR + Logger.RETURNING_NULL_LOG
		Logger.error(formatted_string, [_GET_DISK_CAMERA], self)
	return return_camera

func set_disk_camera(new_camera: Camera3D) -> void:
	if camera_container == null:
		var formatted_string: String = Logger.NULL_CAMERA_LOG + Logger.LOG_SEPARATOR + _CREATING_CAMERA_LOG
		Logger.warn(formatted_string, [_SET_DISK_CAMERA], self)
		_create_camera_container()
	camera_container.set_camera(new_camera)

func pick_up() -> void:
	self.queue_free()

func _handle_freelook_motion(v_motion: float, h_motion: float) -> void:
	# TODO Will need this using state isntead of the camera container stuff once it is figured out
	if GlobalCursorController.is_captured_current() and camera_container != null and camera_container.is_current():
		camera_container.horizontal_pan(h_motion, self.global_position)

func _handle_collision(body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	_collided = true
	disk_collision.store_collision(self.get_rid(), body_rid, self.global_position, flight_data, asset_data)
	if camera_container != null && (camera_container.has_camera() && camera_container.is_current()):
		camera_container.start_focus(self.global_basis, self.global_position)
		self.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
		self.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	# TODO Refactor this to use accurate state ensuring it is tracked before emitting
	# GlobalCameraController.set_rig_dile(true)

## Creates intneral camera_container object
## Should only be called intnernally
func _create_camera_container() -> void:
	if camera_container == null:
		var new_camera_container: CameraContainer = AssetFactory.new_camera_container()
		self.add_child(new_camera_container)
		_set_camera_container(new_camera_container)
	else:
		Logger.warn(Logger.ALREADY_EXISTS_LOG, [Logger.CAMERA_CONTAINER], self)

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data

func _set_flight_data(incoming_data: FlightData) -> void:
	flight_data = incoming_data

func _launch() -> void:
	if flight_data != null:
		self.flight_data.print_details()
		self.global_position = flight_data.get_actual_path()[0].point_position
		self.basis = flight_data.get_flight_basis()
		self.linear_velocity = -self.transform.basis.z * flight_data.get_flight_speed()
		self.angular_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
		if flight_data.is_focus_flight():
			_submit_camera_request()
			camera_container.set_current()
			camera_container.hold_min_height()
			if not GlobalCursorController.is_captured_current():
				GlobalCursorController.request_captured(self, "Force disk launched")
	else:
		Logger.warn(Logger.MISSING_FLIGHT_DATA_LOG, [], self)

func _get_camera_container() -> CameraContainer:
	_create_camera_container()
	return camera_container

func _set_camera_container(incoming_container: CameraContainer) -> void:
	if camera_container != null:
		camera_container.disconnect(GroupData.LOSE_FOCUS, _return_camera_to_owner)
		camera_container = null
	camera_container = incoming_container
	camera_container.reparent(self)
	camera_container.connect(GroupData.LOSE_FOCUS, _return_camera_to_owner)
	camera_container.connect(GroupData.LOG_OUTPUT, _handle_child_logs)

func _return_camera_to_owner() -> void:
	var has_custom_group: bool = asset_data != null and !asset_data.group_name.is_empty()
	var has_camera: bool = camera_container != null and camera_container.has_camera()
	if has_camera and has_custom_group:
		get_tree().call_group(asset_data.group_name, GroupData.TRANSFER_AND_ENABLE, camera_container.get_camera())
	else:
		Logger.debug(Logger.CANT_RETURN_LOG, [str(self)], self)

func _submit_camera_request() -> void:
	if asset_data != null and !asset_data.group_name.is_empty():
		_create_camera_container()
		get_tree().call_group(asset_data.group_name, GroupData.REQUEST_CAMERA, camera_container)
		camera_container.add_to_group(asset_data.group_name)
		camera_container.reset_camera()
	else:
		var formatted_string: String = Logger.NO_GROUP_LOG + Logger.LOG_SEPARATOR + Logger.NOT_SUBMITTING
		Logger.debug(formatted_string, [], self)

# TODO Make this static and shared somehwere
func _handle_child_logs(incoming_level: Logger.LEVEL, incoming_log: String, optional_params: Array) -> void:
	match incoming_level:
		Logger.LEVEL.DEBUG:
			Logger.debug(incoming_log, optional_params, self)
		Logger.LEVEL.INFO:
			Logger.info(incoming_log, optional_params, self)
		Logger.LEVEL.WARN:
			Logger.warn(incoming_log, optional_params, self)
		Logger.LEVEL.ERROR:
			Logger.error(incoming_log, optional_params, self)
