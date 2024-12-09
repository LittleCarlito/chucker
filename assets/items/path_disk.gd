extends ThrowableItem
class_name PathDisk

# TODO CONTINUE FROM HERE; Got Spawned in path disk on ground, now need to pick it up and throw it then have collision work
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

# TODO See if maybe this needs to be made programatically instead
@onready var pathDisk: PathDisk = $"."
@onready var path3d: Path3D = $Path3D
@onready var pathFollow3d: PathFollow3D = $Path3D/PathFollow3D
@onready var throwableMesh: ThrowableDiskMesh = $Path3D/PathFollow3D/ThrowableMesh
@onready var collisionArea: Area3D = $Path3D/PathFollow3D/CollisionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	throwableMesh.prepare_item(CONSTANTS.DISK_TYPE.PATH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(pathFollow3d):
		if self.launchPath.is_empty():
			_swap_disk()
		# If disk not collided or disk just launched process on path
		#path3d.curve.get_baked_length()
		elif pathFollow3d.progress_ratio < 1:
			var velocityMagnitude: float = GlobalSettings.DISK.LAUNCH_SPEED * self.launchSpeed 
			var distancePerSecond: float = velocityMagnitude * delta
			pathFollow3d.progress += distancePerSecond
			# TODO Everyting but the mesh moves; Need to add rotating/moving the mesh with everything else to this logic
			throwableMesh.global_transform = pathFollow3d.global_transform
			if throwableMesh.global_rotation.x != self.launchAngle:
				throwableMesh.global_rotation.x = self.launchAngle
		if pathFollow3d.progress_ratio >= 1:
			self.throwableMesh.collisionLocation = throwableMesh.global_position
			_swap_disk()

# Create a new path disk
static func new_disk() -> PathDisk:
	var newPathDisk: PathDisk = thrownDisk.instantiate()
	return newPathDisk

func prepare_item(incomingType: CONSTANTS.DISK_TYPE, incomingOwner: ChuckChucker = null, incomingCamera: Camera3D = null) -> void:
	super(incomingType, incomingOwner, incomingCamera)
	self.top_level = true
	var newThrowableMesh: ThrowableDiskMesh = ThrowableDiskMesh.new_disk()
	self.set_throwable_mesh(newThrowableMesh)
	newThrowableMesh.prepare_item(incomingType, incomingOwner, incomingCamera)

func set_throwable_mesh(newThrowableMesh: ThrowableDiskMesh) -> void:
	self.add_child(newThrowableMesh)
	var oldThrowableMesh: ThrowableDiskMesh = throwableMesh
	oldThrowableMesh.queue_free()
	self.throwableMesh = newThrowableMesh

func set_launch_parameters(incomingPath: Array[Vector3], incomingSpeed: float, incomingAngle: float) -> void:
	super(incomingPath, incomingSpeed, incomingAngle)
	var throwCurve: Curve3D = Curve3D.new()
	for throwPoint in incomingPath:
		throwCurve.add_point(to_local(throwPoint))
	self.path3d.curve = throwCurve
	self.toggle_camera()

func toggle_camera() -> void:
	throwableMesh.toggle_camera()

func _body_enter(body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	var ownerRid: RID
	if self.ownerVar != null:
		ownerRid = self.ownerVar.get_rid()
		if body_rid != ownerRid:
			# TODO Need to save the collision location here and set the location of the newDisk to that spot
			self.throwableMesh.collisionLocation = throwableMesh.global_position
			self._swap_disk()

# Breaks the disk from the path and adds velocity
func _swap_disk() -> void:
	# TODO Make shared code a method in Global DiskFactory script for generating Rigid3D disks
#			Should then add the preparation and building of other disk types to the class
	# Create a force disk
	var newDisk = ChuckDisk.new_disk()
	get_tree().root.add_child(newDisk)
	var prepareAngle: float
	if self.throwableMesh.collisionLocation == Vector3.INF:
		newDisk.global_position = self.global_position
		prepareAngle = self.launchAngle
	else:
		newDisk.global_position = throwableMesh.global_position
		prepareAngle = pathFollow3d.global_rotation.x
		self.launchSpeed = self.launchSpeed * .5
	newDisk.prepare_item(CONSTANTS.DISK_TYPE.PATH, ownerVar, fallbackCamera)
	newDisk.set_rigid_launch_parameters(self.launchPath, self.launchSpeed, prepareAngle)
	newDisk.rotate_x(self.launchAngle)
	# Get rid of Path3D and Mesh
	self.queue_free()
