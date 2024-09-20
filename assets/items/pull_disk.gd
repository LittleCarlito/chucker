extends ThrowableItem
class_name PullDisk

@onready var pullDraw: PullDraw = $PullDraw
@onready var chargeView: ChargeView = $ChargeView

var pullLength: float
var pullOffset: float
var throwCurve: Array[Vector3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	chargeView.set_progress(-1)
	Logger.set_log_level(Logger.LEVEL.DEBUG)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.handle_aiming()

func hold_action(_delta: float) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(USER_INPUT.ACTION.SECONDARY):
		pullDraw.reset_pull()
		chargeView.set_progress(-1)
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		pullLength = pullDraw.lastLength
		pullOffset = pullDraw.lastOffset * .01
		chargeView.set_progress((pullLength / GLOBAL_SETTINGS.DISK.MAX_PULL) * 100)
		var multiplier: float = (pullLength / 100) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		throwCurve = self.draw_aim_line(multiplier, pullOffset)

func release_action() -> void:
	# If right click is not held launch the disk
	if not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY) and pullLength > GLOBAL_SETTINGS.DISK.MIN_PULL:
		var multiplier: float = (pullLength / 100) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		self.launch_disk(multiplier, ThrowableItem.TYPE.PULL, throwCurve)
	chargeView.set_progress(-1)
