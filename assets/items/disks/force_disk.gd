extends RigidBody3D
class_name ForceDisk

	# TODO Continue
	# TODO Get path disk working again
	# TODO Have the spawned course objects integrate their data with Global Hole Data
	# TODO Get character stuff into state based
	#			Jumping, moving, aiming, etc have it all determine an ENUM in the character
	# TODO Add lerp to camera handoffs
	#			make lerp speed global setting configurable
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

func _ready() -> void:
	if asset_data == null:
		asset_data = AssetDelivery.create_asset_data(GameConfig.DEFAULTS.item as AssetData.TYPE)
		if !asset_data.group_name.is_empty():
			add_to_group(asset_data.group_name)
	disk_mesh.set_type(asset_data.creation_type)
	_update_state()

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and camera_container != null and camera_container.is_current():
		if event is InputEventMouseMotion:
			var horizontal_rotation_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
			camera_container.horizontal_pan(horizontal_rotation_amount, self.global_position)

func set_internal_type(new_internal_type: AssetData.TYPE) -> void:
	asset_data.internal_type = new_internal_type
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
	_update_state()

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
	_update_state()

func _handle_collision(body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	_collided = true
	disk_collision.store_collision(self.get_rid(), body_rid, self.global_position, flight_data, asset_data)
	if camera_container != null && (camera_container.has_camera() && camera_container.is_current()):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		camera_container.start_focus(self.global_basis, self.global_position)
		self.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
		self.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE

func pick_up() -> void:
	self.queue_free()

## Creates intneral camera_container object
## Should only be called intnernally
func _create_camera_container() -> void:
	if camera_container == null:
		var new_camera_container: CameraContainer = AssetFactory.new_camera_container()
		self.add_child(new_camera_container)
		_set_camera_container(new_camera_container)
	else:
		Logger.warn(Logger.ALREADY_EXISTS_LOG, [Logger.CAMERA_CONTAINER], self)

func _update_state() -> void:
	asset_data.camera_state = AssetData.get_camera_state(camera_container)

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data

func _set_flight_data(incoming_data: FlightData) -> void:
	flight_data = incoming_data

func _launch() -> void:
	if flight_data != null:
		self.global_position = flight_data.flight_path[0]
		self.global_basis = flight_data.flight_global_basis
		self.linear_velocity = -self.global_transform.basis.z * flight_data.flight_speed
		self.angular_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
		if flight_data.focus_flight:
			_submit_camera_request()
			camera_container.set_current()
			camera_container.hold_min_height()
			if !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
	camera_container.connect(GroupData.HANDLE_CHILD_LOGS, _handle_child_logs)

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
