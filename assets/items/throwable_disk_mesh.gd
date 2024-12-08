extends ThrowableItem
class_name ThrowableDiskMesh

const thrownDisk: PackedScene = preload(SceneLibrary.MESH.THROWABLE_SCENE)

@onready var diskMesh: DiskMesh = $DiskMesh

var collisionLocation: Vector3 = Vector3.INF
var focused: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

static func new_disk() -> ThrowableDiskMesh:
	var newThrowableMesh: ThrowableDiskMesh = thrownDisk.instantiate()
	return newThrowableMesh

func start_focus() -> void:
	if !diskMesh.focused:
		diskMesh.start_focus()
	
func idle_rotate(delta: float) -> void:
	diskMesh.idle_rotate(delta)

func _handle_lose_focus() -> void:
	ownerVar.disableMovement = false
	fallbackCamera.current = true

func toggle_camera() -> void:
	diskMesh.diskCamera.current = not diskMesh.diskCamera.current

func is_camera_current() -> bool:
	return diskMesh.diskCamera.current

func get_active_material() -> StandardMaterial3D:
	return diskMesh.get_active_material(0)
