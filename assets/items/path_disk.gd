extends Node3D
class_name PathDisk

const thrownDisk: PackedScene = preload(ASSET_MANAGEMENT.DISK.PATH_SCENE)

@onready var path3d: Path3D = $Path3D
@onready var pathFollow3d: PathFollow3D = $Path3D/PathFollow3D
@onready var chuckDisk: ChuckDisk = $Path3D/PathFollow3D/ChuckDisk
@onready var launchTimer: Timer = $LaunchTimer

var launchSpeed: float = 0.0
var _prepared: bool = false
var _launched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# TODO Make Prepareable an interface
func prepare(throwPath: Array[Vector3], multiplier: float, newFallbackCamera: Camera3D, newThrower: ChuckChucker) -> void:
	var throwCurve: Curve3D = Curve3D.new()
	for throwPoint in throwPath:
		throwCurve.add_point(throwPoint)
	self.path3d.curve = throwCurve
	self.launchSpeed = GLOBAL_SETTINGS.DISK.LAUNCH_SPEED * multiplier
	self.chuckDisk.fallbackCamera = newFallbackCamera
	self.chuckDisk.thrower = newThrower
	self._prepared = true

# TODO Make part of Prepareable interface
func engage() -> void:
	if self._prepared:
		self._launched = true
		self.launchTimer.start(.1)
	else:
		push_error("PathDisk must be prepared before launching")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If disk not collided or disk just launched process on path
	if not chuckDisk.collided or self._launched:
		var velocityMagnitude: float = launchSpeed
		var distancePerSecond: float = velocityMagnitude * delta
		pathFollow3d.progress += distancePerSecond

# TODO Need some sort of timer for just launched to keep thrower 
func _on_chuck_disk_body_entered(_body: Node) -> void:
	if !self._launched:

		chuckDisk.sleeping = false

# TODO Make this part of an interface
static func new_disk() -> PathDisk:
	# Create a new path disk
	# TODO How does ChuckDisk set its Fallback and ownerVar? Will probably need to take in vars and set them manually here
	var newPathDisk: PathDisk = thrownDisk.instantiate()
	# Prepare the path disk with passed in variables and return
	return newPathDisk

# TODO Make this part of an interface
func toggle_camera() -> void:
	self.chuckDisk.toggle_camera()

# TODO Make this part of an interface
func _idle_rotate(delta: float) -> void:
	self.chuckDisk._idle_rotate(delta)

func _on_launch_timer_timeout() -> void:
	self._launched = false
