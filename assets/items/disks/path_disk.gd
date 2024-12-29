extends Node3D
class_name PathDisk

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
@export var camera_container: CameraContainer
@export var path_3d: Path3D
@export var path_follow: PathFollow3D
var flight_data: FlightData
var asset_data: AssetData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disk_mesh.set_type(AssetData.TYPE.PATH)
	if asset_data != null and !asset_data.group_name.is_empty():
		add_to_group(asset_data.group_name)

# BUG When path is short the disk travels too quickly
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#if (camera_container.has_camera() && camera_container.is_current()) && !(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if is_instance_valid(path_follow):
		#if launch_path.is_empty():
			#_swap_disk()
		## If disk not collided or disk just launched process on path
		#elif path_follow.progress_ratio < 1:
			#var velocity_magnitude: float = _determine_speed()
			#var distance_per_second: float = velocity_magnitude * delta
			#path_follow.progress += distance_per_second
			#disk_mesh.global_transform = path_follow.global_transform
			#if disk_mesh.global_rotation.x != launch_angle:
				#disk_mesh.global_rotation.x = launch_angle
		#if path_follow.progress_ratio >= 1:
			#disk_mesh.collision_location = disk_mesh.global_position
			#_swap_disk()

func set_item_mesh(new_mesh: DiskMesh) -> void:
	self.add_child(new_mesh)
	var old_mesh: DiskMesh = disk_mesh
	if is_instance_valid(old_mesh):
		old_mesh.queue_free()
	disk_mesh = new_mesh

func set_launch_parameters(_incoming_data: FlightData) -> void:
	#super(incoming_path, incoming_speed, incoming_angle, is_focused)
	#var throw_curve: Curve3D = Curve3D.new()
	#for throw_point in incoming_path:
		#throw_curve.add_point(to_local(throw_point))
	#path_3d.curve = throw_curve
	#camera_container.toggle_camera()
	pass

func _body_enter(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	pass
	# TODO Refator to use AssetData or group method calls
	#var owner_rid: RID
	#if item_owner != null:
		#owner_rid = item_owner.get_rid()
		#if body_rid != owner_rid:
			#disk_mesh.collision_location = disk_mesh.global_position
			#_swap_disk()

func _determine_speed() -> float:
	return 0
	#var max_speed: float = GlobalSettings.DISK.LAUNCH_SPEED * launch_speed
	#var calulated_ratio: float = 1 - (4 * path_follow.progress_ratio) * (1 - path_follow.progress_ratio)
	#var ratio_adjustment:float = max(GlobalSettings.DISK.MAX_SPEED_REDUCE, calulated_ratio)
	#return ratio_adjustment * max_speed

# Gets rid of PathDisk and spawns in a rigid disk in its place with force
func _swap_disk() -> void:
	pass
	## Create a force disk
	#var new_disk = ForceDisk.new_viewable_disk()
	#get_tree().root.add_child(new_disk)
	#var prepare_angle: float
	#if disk_collision.get_collision_count() == 0:
		#new_disk.global_position = self.global_position
		#prepare_angle = launch_angle
	#else:
		#var current_camera: Camera3D = get_disk_camera()
		#var new_location: Vector3 = disk_mesh.global_position
		#current_camera.reparent(get_tree().root, true)
		#current_camera.position = lerp(current_camera.position, new_disk.position, GlobalSettings.CAMERA.PAN_SPEED)
		#new_disk.global_position = new_location
		#prepare_angle = path_follow.global_rotation.x
		#launch_speed = launch_speed * .5
	#new_disk.set_internal_type(AssetData.TYPE.PATH)
	#new_disk.set_creation_type(AssetData.TYPE.PATH)
	## Set momentum in direction of prepareAngle
	#var swap_focus: bool = !launch_path.is_empty()
	#new_disk.set_launch_parameters(launch_path, launch_speed, prepare_angle, swap_focus)
	## Tilt the disk to original launch angle to simulate regular rigid throw
	#new_disk.rotate_x(launch_angle)
	## Get rid of Path3D and Mesh
	#self.queue_free()

func get_disk_camera() -> Camera3D:
	return camera_container.get_camera()

func is_current() -> bool:
	return camera_container.is_current()
