extends ThrowableItem
class_name PullDisk

@onready var pullDraw: PullDraw = $PullDraw
@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite
var pullLength: float

# TODO Everything is weird in this one and works in charge one
#		Must be logic in chuck or in charge disk doing something right
# TODO Launches multiple at a time sometimes (though that is my mouse being shit and double clicking)
# TODO Can launch when shouldn't be able to
# TODO Look controls are messed up (holding right click and looking around without disk doesn't work right)
# TODO When disk is launched camera doesn't follow it properly
# TODO Need to add logic to handle what to do when holding left click and right click is pressed and vice versa
#		For holding left click and then having right click it should cancel throw reset power to zero and reset aiming
#			Should be able to let go of left click without launch
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
	pullLength = pullDraw.lastLength
	chargeControl.set_progress((pullLength / GLOBAL_SETTINGS.DISK.MAX_PULL) * 100)
	var multiplier: float = (pullLength / 100) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
	self.draw_aim_line(multiplier)

func release_action() -> void:
	chargeControl.set_progress(-1)
	var multiplier: float = (pullLength / 100) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
	self.launch_disk(multiplier)
