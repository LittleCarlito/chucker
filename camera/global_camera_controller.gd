extends Node

signal request_camera(requesting_node: Node3D)
signal is_focusing(incoming_focus: bool)
signal hold_height(new_min: float)
signal is_idling(incoming_value: bool)

# TODO Move these to state constants
enum TrackingMode {
	FULL,
	POSITION,
	TRACK
}

func focus_new_node(new_focus: Node3D) -> void:
	request_camera.emit(new_focus)

func set_is_rig_focusing(incoming_focus: bool) -> void:
	is_focusing.emit(incoming_focus)

func set_rig_height(new_height: float) -> void:
	hold_height.emit(new_height)

func set_rig_idle(incoming_value: bool) -> void:
	is_idling.emit(incoming_value)
