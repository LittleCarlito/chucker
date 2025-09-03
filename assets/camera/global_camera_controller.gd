extends Node

signal request_camera(requesting_node: Node3D)
signal change_mode(new_mode: TrackingMode)
signal is_focusing(incoming_focus: bool)

enum TrackingMode {
	FULL,
	POSITION,
	TRACK
}

func focus_new_node(new_focus: Node3D) -> void:
	self.request_camera.emit(new_focus)

func set_rig_mode(incoming_mode: TrackingMode) -> void:
	self.change_mode.emit(incoming_mode)

func set_is_rig_focusing(incoming_focus: bool) -> void:
	self.is_focusing.emit(incoming_focus)
