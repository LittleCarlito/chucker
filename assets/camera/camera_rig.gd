extends Node3D
class_name CameraRig


@export var integration_point: CameraIntegrationPoint
@export var camera_controller: Node3D
@export var internal_camera: Camera3D
var enable_rig_movement: bool = false

# TODO Logic for handling WASD movement when enable_right_movement is true
#			Ensure that camera is able to move but if there is a focus point that logic is still respected and still looked at


# TODO Each object should have a FocusPoint created on it that is passed to the CameraRig
#			Make it an optional paramter here; with empty constructor as default
func _ready(incoming_current: bool = false, incoming_integration: CameraIntegrationPoint = null) -> void:
	self.camera_controller.position.z = GameConfig.DEFAULTS.controller_distance
	self.camera_controller.position.y = GameConfig.DEFAULTS.controller_height
	if incoming_current:
		self.make_current()
	if incoming_integration != null:
		self.integration_point = incoming_integration

func set_integration_point(incoming_point: Node3D) -> void:
	self.integration_point = incoming_point
	# TODO Here is where you would look for signals and connect them to the incoming_point

func get_integration_point() -> Node3D:
	return self.integration_point

func deintegrate() -> void:
	# TODO Here is where you need to check if focus point existed
	#			If it did you need to disconnect all the signals
	self.integration_point = CameraIntegrationPoint.new()

func is_current() -> bool:
	return self.internal_camera.is_current()

## Sets camera to current
func make_current() -> void:
	self.internal_camera.make_current()

## If camera is current makes it not current
func clear_current() -> void:
	self.internal_camera.clear_current()

func pivot_vertically(incoming_rotation: float) -> void:
	# TODO 	Logic to tilt self in global space by incoming rotation
	#			Everything should stay the same in local space
	#			CameraContainer aka self is what rotates in global space
	#			Since focus point is the objects node as well they will stay attached position wise
	#				This allows the rotation of self safely keeping evrything else in line
	pass

func pivot_horizontally(incoming_rotation: float) -> void:
	# TODO 	Same logic as above
	#			Moveing self as a whole instead of camera container and trying to restrict it
	pass
