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
@onready var disk_collision: DiskCollision = $Path3D/PathFollow3D/CollisionArea/DiskCollision
@onready var camera_container: CameraContainer = $Path3D/PathFollow3D/DiskMesh/CameraContainer
@onready var path_3d: Path3D = $Path3D
@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disk_mesh.set_type(ItemData.TYPE.PATH)

# BUG When path is short the disk travels too quickly
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (camera_container.has_camera() && camera_container.is_current()) && !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
	new_path_disk.name = new_path_disk.name + "-" + str(new_path_disk.get_instance_id())
	return new_path_disk

func prepare_item(incoming_type: ItemData.TYPE, incoming_owner: ChuckChucker = null, incoming_camera: Camera3D = null) -> void:
	super(incoming_type, incoming_owner, incoming_camera)
	var new_disk_mesh: DiskMesh = DiskMesh.new_mesh()
	new_disk_mesh.set_type(incoming_type)
	set_item_mesh(new_disk_mesh)

func set_item_mesh(new_mesh: DiskMesh) -> void:
	self.add_child(new_mesh)
	var old_mesh: DiskMesh = disk_mesh
	if is_instance_valid(old_mesh):
		old_mesh.queue_free()
	disk_mesh = new_mesh

func set_launch_parameters(incoming_path: Array[Vector3], incoming_speed: float, incoming_angle: float, is_focused: bool = false) -> void:
	super(incoming_path, incoming_speed, incoming_angle, is_focused)
	var throw_curve: Curve3D = Curve3D.new()
	for throw_point in incoming_path:
		throw_curve.add_point(to_local(throw_point))
	path_3d.curve = throw_curve
	camera_container.toggle_camera()

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

# Gets rid of PathDisk and spawns in a rigid disk in its place with force
func _swap_disk() -> void:
	# TODO Continue from here
	# TODO Use groups instead of item_owner/fallback_camera setup
	#			Each ChuckChucker has their own group created using their scene name
	#				Make sure the new_object type method adds to the name like disk types
	#			Each disk that is thrown is added to a group
	#				If it was not thrown by a person there should be an evironment group it belongs to
	#			Each disk type and ChuckChucker type should have a "item_lose_focus" method
	#				Item one will set camera current to false and queue_free self
	#				ChuckChucker type will enable camera and movement
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
	# TODO Imeplment camera_container stuff in ChuckChucker as well
	# Create a force disk
	var new_disk = ForceDisk.new_object()
	get_tree().root.add_child(new_disk)
	var prepare_angle: float
	if disk_collision.get_collision_count() == 0:
		new_disk.global_position = self.global_position
		prepare_angle = launch_angle
	else:
		var current_camera: Camera3D = get_disk_camera()
		var new_location: Vector3 = disk_mesh.global_position
		current_camera.reparent(get_tree().root, true)
		current_camera.position = lerp(current_camera.position, new_disk.position, GlobalSettings.CAMERA.PAN_SPEED)
		new_disk.global_position = new_location
		prepare_angle = path_follow.global_rotation.x
		launch_speed = launch_speed * .5
	new_disk.prepare_item(ItemData.TYPE.PATH)
	# Set momentum in direction of prepareAngle
	var swap_focus: bool = !launch_path.is_empty()
	new_disk.set_launch_parameters(launch_path, launch_speed, prepare_angle, swap_focus)
	# Tilt the disk to original launch angle to simulate regular rigid throw
	new_disk.rotate_x(launch_angle)
	# Get rid of Path3D and Mesh
	self.queue_free()

func get_disk_camera() -> Camera3D:
	return camera_container.get_camera()

func is_current() -> bool:
	return camera_container.is_current()
