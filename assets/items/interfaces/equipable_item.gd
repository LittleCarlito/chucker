extends MeshInstance3D
class_name EquipableItem

var ownerVar: ChuckChucker
var fallbackCamera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get whoever owns the equipable object
	ownerVar = self.owner
	if ownerVar != null:
		# Get the camera of whoever owns the object so it can fallback if needed
		fallbackCamera = ownerVar.get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _reset_zoom() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV

func _zoom_in() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV - GLOBAL_SETTINGS.CAMERA.IN_ADJUST

func _zoom_out() -> void:
	fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.FOV + GLOBAL_SETTINGS.CAMERA.OUT_ADJUST
