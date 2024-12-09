extends ThrowableItem
class_name PullDisk

# TODO Allow for holding space or something to set power but still pull for offset
# TODO Make a maximum pull time like charge disk
#		Probably make that part of ThrowableItem and not have it in both
#		Make it shake the disk as timer gets closer until it finally just inaccurately launches

const diskMesh: PackedScene = preload(SceneLibrary.MESH.PULL_SCENE)

@onready var pullDraw: PullDraw = $PullDraw
@onready var chargeView: ChargeView = $ChargeView

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	chargeView.set_progress(-1)
	Logger.set_log_level(Logger.LEVEL.DEBUG)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Perform pull disk calls
	var isOwnerEquipped: bool = ownerVar != null && ownerVar.is_equipped()
	var onlyPrimaryHeld: bool = Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY) and not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY)
	if onlyPrimaryHeld and isOwnerEquipped:
		pullDraw.begin_pull()
	elif Input.is_action_just_released(CONSTANTS.USER_INPUT.PRIMARY):
		pullDraw.reset_pull()
	# Use ThrowableItem aim handling
	self.handle_aiming()

static func new_disk(newThrower: ChuckChucker, newDiskCamera: Camera3D, newType: CONSTANTS.DISK_TYPE) -> PullDisk:
	var newDisk: PullDisk = diskMesh.instantiate()
	newDisk.prepare_item(newType, newThrower, newDiskCamera)
	return newDisk

func hold_action(_delta: float) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		pullDraw.reset_pull()
		chargeView.set_progress(-1)
		self.reset_launch_parameters()
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		chargeView.set_progress((pullDraw.lastLength / GlobalSettings.DISK.MAX_PULL) * 100)
		var multiplier: float = (pullDraw.lastLength / 100) * GlobalSettings.DISK.HOLD_MULTIPLIER
		self.launchPath = self.draw_aim_line(multiplier, pullDraw.lastOffset * .01)

func release_action() -> void:
	# If right click is not held launch the disk
	if not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY) and pullDraw.lastLength > GlobalSettings.DISK.MIN_PULL:
		# TODO This gives a bit too much gusto
		var multiplier: float = (pullDraw.lastLength / 100) * GlobalSettings.DISK.HOLD_MULTIPLIER
		self.set_launch_parameters(self.launchPath, multiplier, self.global_basis.get_euler().x)
		self.launch_disk()
	chargeView.set_progress(-1)
