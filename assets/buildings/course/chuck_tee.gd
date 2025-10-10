extends StaticBody3D
class_name ChuckTee

# TODO Need to figure out scorecard view so it is less hacky
# TODO Need to get tee_camera on CameraContainer so its controllable as well
@onready var camera_container: CameraContainer = $CameraContainer
@export var hole_data: HoleData
@export var hole_node_data: HoleNodeData
# TODO This should be the parent class of all created hole nodes for the associtead hole
#		Then group method call from Global Hole Data can be simplified to just a Group call on the TeeBox group
#			TeeBox group method then makes all its node_numbers sequential inside itself
#			TeeBox group method then calculates all the distances between the one node and the next
#			After all Nodes in the array have had their stats updated
var hole_nodes: Array[HoleNode] = []
var asset_data: AssetData

const _CURRENT_CAMERA_LOG: String = "Current camera is %s"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ApplicationConfig.ENABLE_LEGACY_CAMERA:
		camera_container.populate_camera_control(_get_focus_point())
		camera_container.set_fov(CameraConfig.get_stationary_fov_value())
	# TODO Need to get noded path from teebox to hole and have camera focus on first node
	# TODO need to create group from teebox this will be group owner
	#		Try to share asset status stuff with already existing classes
	add_to_group(name)
	# TODO Need to make Global Hole Data object
	# TODO Need to add method to all Hole Data related nodes to update the Global Hole Data object with their data
	# TODO Need to make method in all Hole Data related nodes to pull Global Hole data
	# TODO Create a new method in the AssetFactory to create next in line tee box HoleData
	#		Method should use data in Global Hole Data to figure out next available hole number
	# TODO If hole_data is null use the AssetFactory method to create the next in line HoleData for this tee box
	if hole_node_data == null:
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
	# TODO Re-enable once disk throw camera collision stuff is working again
	# TODO Then get this working transferring active when disks are launched out
	if body is ChuckChucker:
		if enable_body_cam:
			body.camera_container.enable_camera()
			camera_container.disable_camera()
		else:
			body.camera_container.disable_camera()
			camera_container.enable_camera()
		if(get_viewport().get_camera_3d() != null):
			Log.debug(_CURRENT_CAMERA_LOG, [get_viewport().get_camera_3d().name], self)

func get_camera() -> Camera3D:
	return camera_container.get_camera()

func _increase_node_number(hole_number: int, incoming_node_number: int) -> void:
	if hole_node_data != null:
		if hole_node_data.hole_data.hole_number == hole_number and hole_node_data.node_number > incoming_node_number:
			hole_node_data.node_number = hole_node_data.node_number + 1
	else:
		var formatted_string: String = Log.NOT_FOUND_LOG + Log.LOG_SEPARATOR + Log.FOR_METHOD_LOG
		Log.error(formatted_string, [Log.HOLE_NODE_DATA, Log.INCREASE_NODE_NUMBER], self)

func _decrease_node_number(hole_number: int, incoming_node_number: int) -> void:
	if hole_node_data != null:
		if hole_node_data.hole_data.hole_number == hole_number and hole_node_data.node_number > incoming_node_number:
			hole_node_data.node_number = hole_node_data.node_number - 1
	else:
		var formatted_string: String = Log.NOT_FOUND_LOG + Log.LOG_SEPARATOR + Log.FOR_METHOD_LOG
		Log.error(formatted_string, [Log.HOLE_NODE_DATA, Log.DECREASE_NODE_NUMBER], self)

func _get_focus_point() -> Vector3:
	var focus_point: Vector3 = position + CameraConfig.get_stationary_focus_offset()
	if !hole_nodes.is_empty():
		# TODO Need to get HoleNodes integrated and have this look to its next hole node
		pass
	return focus_point

func _set_asset_data(incoming_data: AssetData) -> void:
	asset_data = incoming_data

# TODO Implement to
#			Make all the nodes for the holes data sequential
#			Update all the nodes distance between eachother
#				Should have reference to them in stored array
#			Update total distance of the hole
func _update_state() -> void:
	pass
