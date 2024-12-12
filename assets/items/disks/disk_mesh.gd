# TODO Override the EquipableItem methods with ones using camera_container methods
extends EquipableItem
class_name DiskMesh

const mesh_scene: PackedScene = preload(SceneLibrary.MESH.DISK_MESH)

const _UNSUPPORTED_TYPE_LOG: String = "Given type \"%s\" is not supported"

@onready var camera_container: CameraContainer = $CameraContainer
@onready var internal_mesh: MeshInstance3D = $InternalMesh

var collision_location: Vector3 = Vector3.INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	camera_container.focus_camera(self.global_position)

func _input(event: InputEvent) -> void:
	# Looking controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and camera_container.is_current():
		if event is InputEventMouseMotion:
			# Determine amount to rotate camera
			var horizontal_rotate_amount: float = deg_to_rad(event.relative.x) * GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
			camera_container.horizontal_rotate(horizontal_rotate_amount, self.global_position)

static func new_object() -> DiskMesh:
	var new_mesh: DiskMesh = mesh_scene.instantiate()
	new_mesh.name = new_mesh.name + "-" + str(new_mesh.get_instance_id())
	return new_mesh

func prepare_item(incoming_type: CONSTANTS.DISK_TYPE, incoming_owner: ChuckChucker = null, incoming_camera: Camera3D = null) -> void:
	super(incoming_type, incoming_owner, incoming_camera)
	var active_material: StandardMaterial3D = internal_mesh.get_active_material(0)
	active_material.albedo_color = CONSTANTS.DISK_COLOR.get(incoming_type, GlobalSettings.COLOR_DEFAULTS.DISK)
	camera_container.prepare_item(incoming_camera, incoming_owner)

func _set_type(new_type: CONSTANTS.DISK_TYPE) -> void:
	var disk_material: StandardMaterial3D = internal_mesh.get_active_material(0)
	match new_type:
		CONSTANTS.DISK_TYPE.FORCE:
			disk_material.albedo_color = GlobalSettings.COLOR.FORCE
		CONSTANTS.DISK_TYPE.PATH:
			disk_material.albedo_color = GlobalSettings.COLOR.PATH
		_:
			Logger.error(_UNSUPPORTED_TYPE_LOG, [str(new_type)], self)
			disk_material.albedo_color = GlobalSettings.COLOR.FORCE

func toggle_camera() -> void:
	camera_container.toggle_camera()

func _reset_zoom() -> void:
	camera_container.get_camera().fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV)

func _zoom_in() -> void:
	camera_container.get_camera().fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) - GlobalSettings.CAMERA.IN_ADJUST

func _zoom_out() -> void:
	camera_container.get_camera().fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) + GlobalSettings.CAMERA.OUT_ADJUST

func _on_lose_focus() -> void:
	item_owner.enable_movement()
	fallback_camera.current = true
	collision_location = Vector3.INF

func idle_rotate(delta: float) -> void:
	camera_container.idle_rotate(delta, self.global_position)

func get_disk_camera() -> Camera3D:
	return camera_container.get_camera()

func set_disk_camera(new_camera: Camera3D) -> void:
	camera_container.set_camera(new_camera)
