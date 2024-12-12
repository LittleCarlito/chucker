extends ThrowableItem
class_name PathDisk

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

const disk_scene: PackedScene = preload(SceneLibrary.DISK.PATH_SCENE)

const _BODY_EXIT: String = "body_exit"
const _BODY_ENTER: String = "body_enter"

@onready var disk_mesh: DiskMesh = $Path3D/PathFollow3D/DiskMesh
@onready var path_3d: Path3D = $Path3D
@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disk_mesh.prepare_item(CONSTANTS.DISK_TYPE.PATH)

# BUG When path is short the disk travels too quickly
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(path_follow):
		if launch_path.is_empty():
			_swap_disk()
		# If disk not collided or disk just launched process on path
		elif path_follow.progress_ratio < 1:
			var velocity_magnitude: float = _determine_speed()
			var distance_per_second: float = velocity_magnitude * delta
			path_follow.progress += distance_per_second
			disk_mesh.global_transform = path_follow.global_transform
			if disk_mesh.global_rotation.x != launch_angle:
				disk_mesh.global_rotation.x = launch_angle
		if path_follow.progress_ratio >= 1:
			disk_mesh.collision_location = disk_mesh.global_position
			_swap_disk()

# Create a new path disk
static func new_object() -> PathDisk:
	var new_path_disk: PathDisk = disk_scene.instantiate()
	return new_path_disk

func prepare_item(incomint_type: CONSTANTS.DISK_TYPE, incoming_owner: ChuckChucker = null, incoming_camera: Camera3D = null) -> void:
	super(incomint_type, incoming_owner, incoming_camera)
	self.top_level = true
	var new_disk_mesh: DiskMesh = DiskMesh.new_object()
	set_item_mesh(new_disk_mesh)
	new_disk_mesh.prepare_item(incomint_type, incoming_owner, incoming_camera)

func set_item_mesh(new_mesh: DiskMesh) -> void:
	self.add_child(new_mesh)
	var old_mesh: DiskMesh = disk_mesh
	if is_instance_valid(old_mesh):
		old_mesh.queue_free()
	disk_mesh = new_mesh

func set_launch_parameters(incoming_path: Array[Vector3], incoming_speed: float, incoming_angle: float) -> void:
	super(incoming_path, incoming_speed, incoming_angle)
	var throw_curve: Curve3D = Curve3D.new()
	for throw_point in incoming_path:
		throw_curve.add_point(to_local(throw_point))
	path_3d.curve = throw_curve
	disk_mesh.camera_container.toggle_camera()

func _body_enter(body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	var owner_rid: RID
	if item_owner != null:
		owner_rid = item_owner.get_rid()
		if body_rid != owner_rid:
			disk_mesh.collision_location = disk_mesh.global_position
			_swap_disk()

func _determine_speed() -> float:
	var max_speed: float = GlobalSettings.DISK.LAUNCH_SPEED * launch_speed
	var calulated_ratio: float = 1 - (4 * path_follow.progress_ratio) * (1 - path_follow.progress_ratio)
	var ratio_adjustment:float = max(GlobalSettings.DISK.MAX_SPEED_REDUCE, calulated_ratio)
	return ratio_adjustment * max_speed

# BUG Force applied to swapped disk is not forward from disk but unrotated universal forward
# Gets rid of PathDisk and spawns in a rigid disk in its place with force
func _swap_disk() -> void:
	# TODO Make shared code a method in Global DiskFactory script for generating Rigid3D disks
#			Should then add the preparation and building of other disk types to the class
	# Create a force disk
	var new_disk = ChuckDisk.new_disk()
	get_tree().root.add_child(new_disk)
	var prepare_angle: float
	if disk_mesh.collision_location == Vector3.INF:
		new_disk.global_position = self.global_position
		prepare_angle = launch_angle
	else:
		Logger.debug("newDisk current camera: %s", [str(new_disk.get_disk_camera())], self)
		Logger.debug("pathDisk camera: %s", [str(get_disk_camera())], self)
		var current_camera: Camera3D = get_disk_camera()
		var new_location: Vector3 = disk_mesh.global_position
		current_camera.reparent(get_tree().root, true)
		current_camera.position = lerp(current_camera.position, new_disk.position, GlobalSettings.CAMERA.PAN_SPEED)
		Logger.debug("newDisk current camera after set: %s", [str(new_disk.get_disk_camera())], self)
		new_disk.global_position = new_location
		prepare_angle = path_follow.global_rotation.x
		launch_speed = launch_speed * .5
	new_disk.prepare_item(CONSTANTS.DISK_TYPE.PATH, item_owner, fallback_camera)
	# Set momentum in direction of prepareAngle
	new_disk.set_rigid_launch_parameters(launch_path, launch_speed, prepare_angle)
	# Tilt the disk to original launch angle to simulate regular rigid throw
	new_disk.rotate_x(launch_angle)
	# Get rid of Path3D and Mesh
	self.queue_free()

func get_disk_camera() -> Camera3D:
	return disk_mesh.get_disk_camera()
