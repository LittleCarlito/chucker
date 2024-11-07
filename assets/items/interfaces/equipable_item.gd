extends MeshInstance3D
class_name EquipableItem

const NULL_FALLBACK_MESSAGE: String = "%s called but fallbackCamera is null"
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

# TODO Refactor logger so when a warn or error log is given to it it will push error or push warn
#		Then get rid of double log

func _reset_zoom() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.get(CONSTANTS.FOV, GLOBAL_SETTINGS.CAMERA_DEFAULTS.FOV)
	else:
		Logger.error(NULL_FALLBACK_MESSAGE, ["_reset_zoom()"], self)
		push_error("_reset_zoom() called but fallbackCamera is null")

func _zoom_in() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.get(CONSTANTS.FOV, GLOBAL_SETTINGS.CAMERA_DEFAULTS.FOV) - GLOBAL_SETTINGS.CAMERA.IN_ADJUST
	else:
		Logger.error(NULL_FALLBACK_MESSAGE, ["_zoom_in()"], self)
		push_error("_zoom_in() called but fallbackCamera is null")

func _zoom_out() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GLOBAL_SETTINGS.CAMERA.get(CONSTANTS.FOV, GLOBAL_SETTINGS.CAMERA_DEFAULTS.FOV) + GLOBAL_SETTINGS.CAMERA.OUT_ADJUST
	else:
		Logger.error(NULL_FALLBACK_MESSAGE, ["_zoom_out()"], self)
		push_error("_zoom_out() called but fallbackCamera is null")
