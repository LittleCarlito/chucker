extends Node3D
class_name PathDisk

const thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.PATH_SCENE)

@onready var chuckDisk: ChuckDisk = $Path3D/PathFollow3D/ChuckDisk
var path3d: Path3D = Path3D.new()
var pathFollow3d: PathFollow3D = PathFollow3D.new()
var launchSpeed: float = 0.0
var _prepared: bool = false
var _launched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# TODO Make Prepareable an interface
func prepare(throwPath: Array[Vector3], multiplier: float) -> void:
	chuckDisk.sleeping = true
	pathFollow3d.add_child(chuckDisk)
	path3d.add_child(pathFollow3d)
	var throwCurve: Curve3D = Curve3D.new()
	for throwPoint in throwPath:
		throwCurve.add_point(throwPoint)
	path3d.curve = throwCurve
	launchSpeed = GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier
	self._prepared = true

# TODO Make part of Prepareable interface
func engage() -> void:
	if self._prepared:
		self._launched = true
	else:
		push_error("PathDisk must be prepared before launching")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !chuckDisk.collided:
		var velocityMagnitude: float = launchSpeed
		var distancePerSecond: float = velocityMagnitude * delta
		pathFollow3d.progress += distancePerSecond

# TODO Need some sort of timer for just launched to keep thrower 
func _on_chuck_disk_body_entered(_body: Node) -> void:
	if !self._launched:
		chuckDisk.collided = true
		chuckDisk.sleeping = false

# TODO Make this part of an interface
static func new_disk(newDisk: ChuckDisk, newThrowPath: Array[Vector3], newMultiplier: float) -> PathDisk:
	# Create a new path disk
	var newPathDisk: PathDisk = thrownDisk.instantiate()
	# Set up chuck disk to run on a path
	newDisk.sleeping = true
	# Create a new chuck disk and add it to the path disk
	newPathDisk.chuckDisk = newDisk
	# Prepare the path disk with passed in variables and return
	newPathDisk.prepare(newThrowPath, newMultiplier)
	return newPathDisk

# TODO Make this part of an interface
func toggle_camera() -> void:
	self.chuckDisk.toggle_camera()

# TODO Make this part of an interface
func _idle_rotate(delta: float) -> void:
	self.chuckDisk._idle_rotate(delta)

func _on_launch_timer_timeout() -> void:
	self._launched = false
