extends ThrowableItem
class_name ChargeDisk

const diskMesh: PackedScene = preload(SceneLibrary.MESH.CHARGE_SCENE)

@onready var chargeView: ChargeView = $ChargeView

var stopWatch: StopWatch = StopWatch.new()

# TODO Have charge and line decrease after reaching max and increase after reaching min on long holds
# TODO Add charge effects
#		Wobble if held too long
#		Will just inaccurately launch after x amount of time
# TODO Add "perfect" release window
# TODO Give "perfect" release different effects
# TODO Ability to put spin on disk and curve it

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	chargeView.set_progress(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.handle_aiming()

static func new_disk(newThrower: ChuckChucker, newDiskCamera: Camera3D, newType: CONSTANTS.ITEM_TYPE) -> ChargeDisk:
	var newDisk: ChargeDisk = diskMesh.instantiate()
	# TODO Not sure if this does anything as method is static; Look at variables in returned object outside of the method
	newDisk.prepare_item(newThrower, newDiskCamera, newType)
	return newDisk

func hold_action(delta: float) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		stopWatch.reset()
		chargeView.set_progress(-1)
		self.reset_launch_parameters()
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		var heldTime: float = stopWatch.isHeld(delta)
		chargeView.set_progress((heldTime / GlobalSettings.DISK.MAX_HOLD) * 100)
		var multiplier: float = min(GlobalSettings.DISK.MAX_HOLD, heldTime) * GlobalSettings.DISK.HOLD_MULTIPLIER
		self.launchPath = self.draw_aim_line(multiplier)

## Launch disk and reset objects
func release_action() -> void:
	if not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		chargeView.set_progress(-1)
		var finalTime: float = stopWatch.reset()
		var launchSpeed: float = min(GlobalSettings.DISK.MAX_HOLD, finalTime) * GlobalSettings.DISK.HOLD_MULTIPLIER
		self.set_launch_parameters(self.launchPath, launchSpeed, self.global_basis.get_euler().x)
		self.launch_disk()
