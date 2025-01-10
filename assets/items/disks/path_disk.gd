extends Node3D
class_name PathDisk

# TODO NEXT
# TODO Fix AssetDelivery create_and_launch
# TODO Refactor Basis to be Transform in Path stuff
# TODO Refactor all rotation stuff to be Transform based
# TODO Get CameraContainer out of here and created through a method like ForceDisk
# TODO Refactor to use AimLine AssetData FlightData and DiskFactory
# BUG Can steal mouse if thrown over the edge
# TODO Flickering when swapdisk disk switch happens
#		Should just give the camera object to the swapped disk instead of activating the new one
# TODO Make disk tilt in the air when curve is added
# TODO Need to allow holding power consistent while still pulling offset curve
#		Consider making another disk that is a multi click disk
#			First click starts the shot and draws a line to the mouse (to max line length)
#			Second click sets power and draws offset line to the mouse (to max offset line length)
#			Third click launches the disk
#			Right clicking during the process resets the shot
# TODO Add original launch velocity on z axis to disk when collision is detected
#		Need to make collision with ground more realistic

const _BODY_EXIT: String = "body_exit"
const _BODY_ENTER: String = "body_enter"

@export var disk_mesh: DiskMesh
@export var disk_collision: DiskCollision
@export var path_3d: Path3D
@export var path_follow: PathFollow3D
var camera_container: CameraContainer
var flight_data: FlightData
var asset_data: AssetData
var _launched: bool = false
var _collision_location: Vector3 = Vector3.INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disk_mesh.set_type(AssetData.TYPE.PATH)
	if asset_data != null and !asset_data.group_name.is_empty():
		add_to_group(asset_data.group_name)

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and camera_container != null and camera_container.is_current():
		if event is InputEventMouseMotion:
			var horizontal_rotation_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
			camera_container.horizontal_pan(horizontal_rotation_amount, self.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(path_follow):
		if flight_data == null or flight_data.flight_path.is_empty():
			_swap_disk(true)

func _physics_process(delta: float) -> void:
	if _launched:
		if path_follow.progress_ratio < 1:
			var distance_per_second: float = flight_data.flight_speed * delta
			path_follow.progress += distance_per_second
		else:
			_collision_location = disk_mesh.global_position
			_swap_disk()

func set_item_mesh(new_mesh: DiskMesh) -> void:
	path_follow.add_child(new_mesh)
	var old_mesh: DiskMesh = disk_mesh
	if is_instance_valid(old_mesh):
		old_mesh.queue_free()
	disk_mesh = new_mesh

func _body_enter(body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body_rid != asset_data.owner_rid:
		_collision_location = disk_mesh.global_position
		_swap_disk()

func _determine_speed() -> float:
	var max_speed: float = GameConfig.DEFAULTS.launch_speed * flight_data.flight_speed
	var calulated_ratio: float = 1 - (4 * path_follow.progress_ratio) * (1 - path_follow.progress_ratio)
	var ratio_adjustment:float = max(GameConfig.DEFAULTS.max_speed_reduce, calulated_ratio)
	return ratio_adjustment * max_speed

# Gets rid of PathDisk and spawns in a rigid disk in its place with force
func _swap_disk(drop_disk: bool = false) -> void:
	## Create a force disk
	var spawn_disk_data: AssetData = AssetDelivery.create_asset_data(asset_data.creation_type, AssetData.ITEM_STATE.DEACTIVATED, AssetData.CAMERA_STATE.TRACKABLE, AssetData.TYPE.PULL, asset_data.group_name, asset_data.owner_rid)
	var prepare_angle: float = disk_mesh.rotation.x
	if drop_disk:
		var new_disk: ForceDisk = AssetDelivery.spawn_asset(spawn_disk_data, disk_mesh.global_position) as ForceDisk
		new_disk.rotation.x = prepare_angle
	else:
		# TODO Get resulting dot vector between the last 2 points of the path curve
		#		Need to set flight basis to that
		var new_flight_path: Array[Vector3] = [disk_mesh.global_position]
		flight_data.set_flight_path(new_flight_path)
		# TODO Get PathDisk collision speed offset to config
		flight_data.flight_speed *= 0.1
		# TODO on the curve detect the most negative z rotation and set path_follow rotate path_follow to it; Then set flight_data.global_basis thing to path_follow basis
		flight_data.flight_global_basis = _get_recent_basis()
		var launched_disk: ForceDisk = AssetDelivery.create_and_launch(flight_data, spawn_disk_data)
	pick_up()

func get_disk_camera() -> Camera3D:
	return camera_container.get_camera()

func is_current() -> bool:
	return camera_container.is_current()

func _set_flight_data(incoming_data: FlightData) -> void:
	flight_data = incoming_data

func _launch() -> void:
	if flight_data != null:
		if flight_data.focus_flight:
			_submit_camera_request()
			camera_container.set_current()
			camera_container.hold_min_height()
			disk_mesh.global_rotation.y = flight_data.flight_global_basis.get_euler().y
			disk_mesh.global_rotation.x = flight_data.flight_global_basis.get_euler().x
			if !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Set path's curve equal to flight data's path
		var flight_curve: Curve3D = Curve3D.new()
		for flight_point in flight_data.flight_path:
			flight_curve.add_point(flight_point)
		path_3d.curve = flight_curve
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_launched = true
	else:
		Logger.warn(Logger.MISSING_FLIGHT_DATA_LOG, [], self)

func _get_camera_container() -> CameraContainer:
	return camera_container

func _set_camera_container(incoming_container: CameraContainer) -> void:
	if camera_container != null:
		camera_container.disconnect(GroupData.LOSE_FOCUS, _return_camera_to_owner)
		camera_container = null
	camera_container = incoming_container
	camera_container.connect(GroupData.LOSE_FOCUS, _return_camera_to_owner)
	camera_container.connect(GroupData.HANDLE_CHILD_LOGS, _handle_child_logs)

func _submit_camera_request() -> void:
	if asset_data != null and !asset_data.group_name.is_empty():
		_create_camera_container()
		get_tree().call_group(asset_data.group_name, GroupData.REQUEST_CAMERA, camera_container)
		camera_container.add_to_group(asset_data.group_name)
		camera_container.reset_camera()
	else:
		var formatted_string: String = Logger.NO_GROUP_LOG + Logger.LOG_SEPARATOR + Logger.NOT_SUBMITTING
		Logger.debug(formatted_string, [], self)

func _return_camera_to_owner() -> void:
	var has_custom_group: bool = asset_data != null and !asset_data.group_name.is_empty()
	var has_camera: bool = camera_container != null and camera_container.has_camera()
	if has_camera and has_custom_group:
		get_tree().call_group(asset_data.group_name, GroupData.TRANSFER_AND_ENABLE, camera_container.get_camera())
	else:
		Logger.debug(Logger.CANT_RETURN_LOG, [str(self)], self)

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data

## Creates intneral camera_container object
## Should only be called intnernally
func _create_camera_container() -> void:
	if camera_container == null:
		var new_camera_container: CameraContainer = AssetFactory.new_camera_container()
		disk_mesh.add_child(new_camera_container)
		_set_camera_container(new_camera_container)
	else:
		Logger.warn(Logger.ALREADY_EXISTS_LOG, [Logger.CAMERA_CONTAINER], self)

func pick_up() -> void:
	self.queue_free()

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

## Uses path_follow to determine the basis of the last 2 executed on points in the curve
func _get_recent_basis() -> Basis:
	var size_cuttoff: int = path_follow.progress_ratio * path_3d.curve.point_count
	var end_point: Vector3 = path_3d.curve.get_point_position(size_cuttoff)
	var previous_basis: Basis = path_3d.basis
	path_3d.look_at(end_point)
	var grabbed_basis: Basis = path_3d.basis
	path_3d.basis = previous_basis
	return grabbed_basis
