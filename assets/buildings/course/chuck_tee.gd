extends StaticBody3D
class_name ChuckTee

# TODO Need to figure out scorecard view so it is less hacky
# TODO Need to get tee_camera on CameraContainer so its controllable as well
@onready var camera_container: CameraContainer = $CameraContainer
@export var hole_data: HoleData
var hole_nodes: Array[HoleNode] = []

const _CURRENT_CAMERA_LOG: String = "Current camera is %s"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_container.populate_camera_control()
	Logger.debug("FOV before setting %s", [str(camera_container.get_camera().fov)], self)
	camera_container.set_fov(GlobalSettings.CAMERA.get(CONSTANTS.STATIONARY_FOV, GlobalSettings.CAMERA_DEFAULTS.STATIONARY_FOV))
	Logger.debug("FOV after setting %s", [str(camera_container.get_camera().fov)], self)
	# TODO Need to get noded path from teebox to hole and have camera focus on first node
	# TODO need to create group from teebox this will be group owner
	#		Try to share asset status stuff with already existing classes
	self.add_to_group(self.name)
	# TODO Need to make Global Hole Data object
	# TODO Need to add method to all Hole Data related nodes to update the Global Hole Data object with their data
	# TODO Need to make method in all Hole Data related nodes to pull Global Hole data
	# TODO Create a new method in the AssetFactory to create next in line tee box HoleData
	#		Method should use data in Global Hole Data to figure out next available hole number
	# TODO If hole_data is null use the AssetFactory method to create the next in line HoleData for this tee box
	if hole_data == null:
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_tee_box_area_body_entered(body: Node3D) -> void:
	_handle_body(body, false)

func _on_tee_box_area_body_exited(body: Node3D) -> void:
	_handle_body(body, true)

# TODO In here is where activation stuff occurs
func _handle_body(body: Node3D, enable_body_cam: bool) -> void:
	if body is ChuckChucker:
		if enable_body_cam:
			body.camera_container.enable_camera()
			camera_container.disable_camera()
		else:
			body.camera_container.disable_camera()
			camera_container.enable_camera()
		if(get_viewport().get_camera_3d() != null):
			Logger.debug(_CURRENT_CAMERA_LOG, [get_viewport().get_camera_3d().name], self)

func get_camera() -> Camera3D:
	return camera_container.get_camera()
