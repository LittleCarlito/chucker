extends Node

signal request_camera(requesting_node: Node3D)


func focus_new_node(new_focus: Node3D) -> void:
	request_camera.emit(new_focus)
