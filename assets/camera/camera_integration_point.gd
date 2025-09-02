extends Marker3D
class_name CameraIntegrationPoint

var focus: Node3D
# If the camera is focusing on the given Node3D
var is_focused: bool
var is_primary_freelook: bool
var is_secondary_freelook: bool
var is_zoom: bool

func _init(
			focus_point: Node3D = Node3D.new(), 
			incoming_focus: bool = false, 
			incoming_primary_enabled: bool = false,
			incoming_secondary_enabled: bool = false,
			incoming_zoom_enabled: bool = false
			) -> void:
	self.focus = focus_point
	self.is_focused = incoming_focus
	self.is_primary_freelook = incoming_primary_enabled
	self.is_secondary_freelook = incoming_secondary_enabled
	self.is_zoom = incoming_zoom_enabled

func is_focusing() -> bool:
	return self.is_focused

func reset_focus() -> void:
	self.is_focused = false

func is_primary_freelook_enalbed() -> bool:
	return self.is_primary_freelook

func enable_primary_freelook() -> void:
	self.is_primary_freelook = true

func disable_primary_freelook() -> void:
	self.is_primary_freelook = false

func is_secondary_freelook_enabled() -> bool:
	return self.is_secondary_freelook

func enable_secondary_freelook() -> void:
	self.is_secondary_freelook = true

func disable_secondary_freelook() -> void:
	self.is_secondary_freelook = false

func is_zoom_eanbled() -> bool:
	return self.is_zoom_enabled

func enable_zoom() -> void:
	self.is_zoom_enabled = true

func disable_zoom() -> void:
	self.is_zoom_enabled = false
