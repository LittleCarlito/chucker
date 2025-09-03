extends Node

signal request_camera(requesting_node: Node3D)
signal change_mode(new_mode: TrackingMode)

enum TrackingMode {
	FULL,
	POSITION
}

func focus_new_node(new_focus: Node3D) -> void:
	self.request_camera.emit(new_focus)

func set_rig_mode(incoming_mode: TrackingMode) -> void:
	self.change_mode.emit(incoming_mode)
