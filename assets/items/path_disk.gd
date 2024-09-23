extends Node3D
class_name PathDisk

# TODO Make ChuckDisk global x rotation locked at launch angle until collision detected
# TODO Add original launch velocity on z axis to disk when collision is detected
#		Need to make collision with ground more realistic

const thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.PATH_SCENE)

@onready var path3d: Path3D = $Path3D
@onready var pathFollow3d: PathFollow3D = $Path3D/PathFollow3D
@onready var chuckDisk: ChuckDisk = $Path3D/PathFollow3D/ChuckDisk

var launchSpeed: float = 0.0
var _prepared: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chuckDisk.diskType = ThrowableItem.TYPE.PATH
	var activeMaterial: StandardMaterial3D = chuckDisk.get_mesh().get_active_material(0)
	activeMaterial.albedo_color = GLOBAL_SETTINGS.COLOR.PATH

func prepare(throwPath: Array[Vector3], multiplier: float, newFallbackCamera: Camera3D, newThrower: ChuckChucker) -> void:
	var throwCurve: Curve3D = Curve3D.new()
	for throwPoint in throwPath:
		throwCurve.add_point(throwPoint)
	self.path3d.curve = throwCurve
	self.launchSpeed = GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier
	self.chuckDisk.fallbackCamera = newFallbackCamera
	self.chuckDisk.thrower = newThrower
	self._prepared = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If disk not collided or disk just launched process on path
	if chuckDisk != null and not chuckDisk.collided and pathFollow3d.progress_ratio != 1:
		var velocityMagnitude: float = launchSpeed
		var distancePerSecond: float = velocityMagnitude * delta
		pathFollow3d.progress += distancePerSecond

static func new_disk() -> PathDisk:
	# Create a new path disk
	var newPathDisk: PathDisk = thrownDisk.instantiate()
	# Prepare the path disk with passed in variables and return
	return newPathDisk

func toggle_camera() -> void:
	self.chuckDisk.toggle_camera()

func _idle_rotate(delta: float) -> void:
	self.chuckDisk._idle_rotate(delta)
