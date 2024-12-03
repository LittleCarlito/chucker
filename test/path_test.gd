extends Node3D

@onready var chuckDisk: ChuckDisk = $Path3D/PathFollow3D/ChuckDisk
@onready var path3d: Path3D = $Path3D
@onready var pathFollow3d: PathFollow3D = $Path3D/PathFollow3D
var launchSpeed: float =  GlobalSettings.DISK.LAUNCH_SPEED * 3
var _prepared: bool = false
var _launched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func prepare_path(multiplier: float) -> void:
	launchSpeed = GlobalSettings.DISK.LAUNCH_SPEED * multiplier
	self._prepared = true

func launch() -> void:
	if self._prepared:
		self._launched = true
	else:
		push_error("PathDisk must be prepared before launching")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !chuckDisk.collided and !_launched:
		var velocityMagnitude: float = launchSpeed
		var distancePerSecond: float = velocityMagnitude * delta
		pathFollow3d.progress += distancePerSecond

func _on_chuck_disk_body_entered(_body: Node) -> void:
	chuckDisk.collided = true
	chuckDisk.sleeping = false
