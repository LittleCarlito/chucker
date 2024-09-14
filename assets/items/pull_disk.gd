extends ThrowableItem
class_name PullDisk

@onready var pullDraw: PullDraw = $PullDraw
@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite
var pullLength: float

# TODO Get side pull of line and add offset to control nodes to add "curve"
# TODO Make this disk follow the path laid out by the aim nodes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	chargeControl.set_progress(-1)
	Logger.set_log_level(Logger.LEVEL.DEBUG)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.handle_aiming()
	# TODO Get chargeControl to ThrowableItem so it can be refactored out (it is repeated)
	if float(chargeControl.chargeAmount.text) >= 0:
		chargeSprite.visible = true
	else:
		chargeSprite.visible = false

func hold_action(_delta: float) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(USER_INPUT.ACTION.SECONDARY):
		pullDraw.reset_pull()
		chargeControl.set_progress(-1)
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		pullLength = pullDraw.lastLength
		chargeControl.set_progress((pullLength / GLOBAL_SETTINGS.DISK.MAX_PULL) * 100)
		var multiplier: float = (pullLength / 100) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		self.draw_aim_line(multiplier)

func release_action() -> void:
	# If right click is not held launch the disk
	if not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		chargeControl.set_progress(-1)
		var multiplier: float = (pullLength / 100) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		self.launch_disk(multiplier, ThrowableItem.TYPE.PULL)
