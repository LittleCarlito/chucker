extends Node3D
class_name PathDisk

const _BODY_EXIT: String = "body_exit"
const _BODY_ENTER: String = "body_enter"

@export var disk_mesh: DiskMesh
@export var disk_collision: DiskCollision
@export var path_3d: Path3D
@export var path_follow: PathFollow3D
@export var debug_logs: bool = true
var camera_container: CameraContainer
var flight_data: FlightData
var asset_data: AssetData
var _launched: bool = false
var _collision_location: Vector3 = Vector3.INF
var _spawned_disk: bool = false
var _details_logged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.disk_mesh.set_type(AssetData.TYPE.PATH)
	if self.asset_data != null and !self.asset_data.group_name.is_empty():
		add_to_group(self.asset_data.group_name)

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and self.camera_container != null and self.camera_container.is_current():
		if event is InputEventMouseMotion:
			var horizontal_rotation_amount: float = deg_to_rad(event.relative.x) * CameraConfig.get_horizontal_look_sens()
			self.camera_container.horizontal_pan(horizontal_rotation_amount, self.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(self.path_follow):
		self.disk_mesh.rotation.y += (self.flight_data.get_flight_spin() * delta) * GameConfig.DEFAULTS.spin_multiplier
		if self.flight_data == null or self.flight_data.get_actual_path().is_empty():
			self._swap_disk(true)

func _physics_process(delta: float) -> void:
	if self._launched:
		# Log flight information
		if GameConfig.DEFAULTS.flight_detail and not self._details_logged:
			self.flight_data.print_details()
			self._details_logged = true
		# Move disk in space
		if self.path_follow.progress_ratio < 1:
			self._apply_roll_intensity()
			var distance_per_second: float = self.flight_data.get_flight_speed() * delta
			self.path_follow.progress += distance_per_second
		else:
			self._collision_location = self.disk_mesh.global_position
			self._swap_disk()

func set_item_mesh(new_mesh: DiskMesh) -> void:
	self.path_follow.add_child(new_mesh)
	var old_mesh: DiskMesh = self.disk_mesh
	if is_instance_valid(old_mesh):
		old_mesh.queue_free()
	self.disk_mesh = new_mesh

func get_disk_camera() -> Camera3D:
	return self.camera_container.get_camera()

func is_current() -> bool:
	return self.camera_container.is_current()

func pick_up() -> void:
	self.queue_free()

# TODO Think on how different shot types would be implemented
#			A shot where only increasing absolute values of z roation is added (aka it doesn't flatten out)
#			Shots where no roll intensity is applied and it travels with no tilt
#			Shots where it over-rotates and can end up on its side or upside down before reaching ground
func _apply_roll_intensity() -> void:
	if flight_data.get_flight_power() > GameConfig.DEFAULTS.min_pull_for_offset:
		var current_roll_intensity: float = self.flight_data.roll_intensity_at(self.path_follow.progress_ratio)
		if GameConfig.DEFAULTS.flight_detail:
			Logger.debug("Roll intensity at percentage %03f is %03f", [self.path_follow.progress_ratio, current_roll_intensity], self)
		var roll_modifier: float = current_roll_intensity * 20
		self.disk_mesh.rotation.z = roll_modifier
	else:
		if GameConfig.DEFAULTS.flight_detail:
			Logger.debug("Throw has too little power to apply roll", [], self)

func _body_enter(body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body_rid != self.asset_data.owner_rid:
		self._collision_location = self.disk_mesh.global_position
		self._swap_disk()

func _determine_speed() -> float:
	var max_speed: float = GameConfig.DEFAULTS.launch_speed * self.flight_data.get_flight_speed()
	var calulated_ratio: float = 1 - (4 * self.path_follow.progress_ratio) * (1 - self.path_follow.progress_ratio)
	var ratio_adjustment:float = max(GameConfig.DEFAULTS.max_speed_reduce, calulated_ratio)
	return ratio_adjustment * max_speed

# Gets rid of PathDisk and spawns in a rigid disk in its place with force
func _swap_disk(drop_disk: bool = false) -> void:
	if not self._spawned_disk:
		## Create a force disk
		var spawn_disk_data: AssetData = AssetData.new(
														self.asset_data.creation_type, 
														AssetData.ITEM_STATE.DEACTIVATED, 
														AssetData.CAMERA_STATE.TRACKABLE, 
														AssetData.TYPE.PULL, 
														self.asset_data.group_name, 
														self.asset_data.owner_rid
														)
		var prepare_angle: float = self.disk_mesh.rotation.x
		if drop_disk:
			var new_disk_spawn_data: SpawnData = SpawnData.new(spawn_disk_data, self.disk_mesh.global_position)
			var new_disk: ForceDisk = AssetDelivery.spawn_asset(new_disk_spawn_data) as ForceDisk
			new_disk.rotation.x = prepare_angle
			self._spawned_disk = true
		else:
			var new_flight_path: FlightPath = FlightPath.convert([self.disk_mesh.global_position])
			self.flight_data.set_flight_path(new_flight_path)
			# TODO Get PathDisk collision speed offset to config
			var original_flight_speed: float = self.flight_data.get_flight_speed()
			self.flight_data.set_flight_speed(0)
			var _launched_disk: ForceDisk = AssetDelivery.create_and_launch(self.flight_data, spawn_disk_data)
			# TODO Get path disk speed modifier to config
			var added_velocity: Vector3 = Vector3(0, -(original_flight_speed * 0.4), -(original_flight_speed * 0.4))
			_launched_disk.linear_velocity += _launched_disk.global_transform.basis * added_velocity
			self._spawned_disk = true
		pick_up()

func _set_flight_data(incoming_data: FlightData) -> void:
	flight_data = incoming_data

func _launch() -> void:
	if self.flight_data != null:
		self.flight_data.print_details()

		if self.flight_data.is_focus_flight():
			_submit_camera_request()
			self.camera_container.set_current()
			self.camera_container.hold_min_height()
			self.camera_container.hold_steady()
			self.disk_mesh.basis = flight_data.get_flight_basis()
			if !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Set path's curve equal to flight data's path
		var flight_curve: Curve3D = Curve3D.new()
		for flight_point in flight_data.get_actual_path():
			flight_curve.add_point(flight_point.point_position)
		path_3d.curve = flight_curve
		self._launched = true
	else:
		Logger.warn(Logger.MISSING_FLIGHT_DATA_LOG, [], self)

func _get_camera_container() -> CameraContainer:
	return self.camera_container

func _set_camera_container(incoming_container: CameraContainer) -> void:
	if self.camera_container != null:
		self.camera_container.disconnect(GroupData.LOSE_FOCUS, _return_camera_to_owner)
		self.camera_container = null
	self.camera_container = incoming_container
	self.camera_container.connect(GroupData.LOSE_FOCUS, _return_camera_to_owner)
	self.camera_container.connect(GroupData.LOG_OUTPUT, _handle_child_logs)

func _submit_camera_request() -> void:
	if self.asset_data != null and !self.asset_data.group_name.is_empty():
		_create_camera_container()
		get_tree().call_group(self.asset_data.group_name, GroupData.REQUEST_CAMERA, camera_container)
		self.camera_container.add_to_group(self.asset_data.group_name)
		self.camera_container.reset_camera()
	else:
		var formatted_string: String = Logger.NO_GROUP_LOG + Logger.LOG_SEPARATOR + Logger.NOT_SUBMITTING
		Logger.debug(formatted_string, [], self)

func _return_camera_to_owner() -> void:
	var has_custom_group: bool = self.asset_data != null and !self.asset_data.group_name.is_empty()
	var has_camera: bool = self.camera_container != null and self.camera_container.has_camera()
	if has_camera and has_custom_group:
		get_tree().call_group(asset_data.group_name, GroupData.TRANSFER_AND_ENABLE, camera_container.get_camera())
	else:
		Logger.debug(Logger.CANT_RETURN_LOG, [str(self)], self)

func _set_asset_data(incoming_data: AssetData) -> void:
	self.asset_data = incoming_data

## Creates intneral camera_container object
## Should only be called intnernally
func _create_camera_container() -> void:
	if self.camera_container == null:
		var new_camera_container: CameraContainer = AssetFactory.new_camera_container()
		self.disk_mesh.add_child(new_camera_container)
		_set_camera_container(new_camera_container)
	else:
		Logger.warn(Logger.ALREADY_EXISTS_LOG, [Logger.CAMERA_CONTAINER], self)

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
