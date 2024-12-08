extends ThrowableItem
class_name PathDisk

# TODO Lock x rotation until collision is detected
# BUG Mouse capture is not returned if thrown over the edge
# TODO Make disk tilt in the air when curve is added
# TODO If above doesn't fix follow camera jiggling on path lock the diskCamera's container's global x rotation as well
# TODO Need to allow holding power consistent while still pulling offset curve
#		Consider making another disk that is a multi click disk
#			First click starts the shot and draws a line to the mouse (to max line length)
#			Second click sets power and draws offset line to the mouse (to max offset line length)
#			Third click launches the disk
#			Right clicking during the process resets the shot
# TODO Add original launch velocity on z axis to disk when collision is detected
#		Need to make collision with ground more realistic

const thrownDisk: PackedScene = preload(SceneLibrary.DISK.PATH_SCENE)

const _BODY_EXIT: String = "body_exit"
const _BODY_ENTER: String = "body_enter"

@onready var pathDisk: PathDisk = $"."
@onready var path3d: Path3D = $Path3D
@onready var pathFollow3d: PathFollow3D = $Path3D/PathFollow3D
@onready var throwableMesh: ThrowableDiskMesh = $Path3D/PathFollow3D/CollisionArea/ThrowableMesh
@onready var collisionArea: Area3D = $Path3D/PathFollow3D/CollisionArea

var _pre_collide: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var activeMaterial: StandardMaterial3D = throwableMesh.get_active_material()
	activeMaterial.albedo_color = GlobalSettings.COLOR.PATH
	throwableMesh.itemType = CONSTANTS.ITEM_TYPE.PATH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If disk not collided or disk just launched process on path
	if pathFollow3d.progress_ratio < 1:
		var velocityMagnitude: float = self.launchSpeed
		var distancePerSecond: float = velocityMagnitude * delta
		pathFollow3d.progress += distancePerSecond

# Create a new path disk
static func new_disk(incomingOwnerVar: ChuckChucker, incomingFallbackCamera: Camera3D, incomingType: CONSTANTS.ITEM_TYPE) -> PathDisk:
	var newPathDisk: PathDisk = thrownDisk.instantiate()
	# TODO Not sure if setting all this does anything as its in a static method; Look at variable returned outside of method
	newPathDisk.prepare_item(incomingOwnerVar, incomingFallbackCamera, incomingType)
	var newMesh: ThrowableDiskMesh = ThrowableDiskMesh.new_disk()
	newPathDisk.throwableMesh = newMesh
	return newPathDisk

# TODO Refactor to prepare_launch
func set_launch_parameters(incomingPath: Array[Vector3], multiplier: float, incomingAngle: float) -> void:
	super(incomingPath, multiplier, incomingAngle)
	var throwCurve: Curve3D = Curve3D.new()
	for throwPoint in incomingPath:
		throwCurve.add_point(throwPoint)
	self.path3d.curve = throwCurve

func toggle_camera() -> void:
	throwableMesh.toggle_camera()

func _body_enter(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	var ownerRid: RID
	if self.ownerVar != null:
		ownerRid = self.ownerVar.get_rid()
		if body_rid != ownerRid:
			self._swap_disk()

# Breaks the disk from the path and adds velocity
func _swap_disk() -> void:
	# Create a force disk
	var newDisk = ChuckDisk.new_disk()
	# Override its default settings to make it appear as a PATH disk
	newDisk.diskMesh.itemType = CONSTANTS.ITEM_TYPE.PATH
	var activeMaterial: StandardMaterial3D = newDisk.get_mesh().get_active_material()
	activeMaterial.albedo_color = GlobalSettings.COLOR.PATH
	# Set rotation to launchAngle
	newDisk.rotate_x(launchAngle)
	# Add force to collision and spawn
	newDisk.linear_velocity = -newDisk.global_transform.basis.z * (self.launchSpeed/2)
	pathDisk.add_child(newDisk)
