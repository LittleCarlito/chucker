extends ThrowableItem
class_name ChargeDisk

@onready var chargeControl: ChargeBar = $ChargeView/ChargeControl
@onready var chargeSprite: Sprite3D = $ChargeSprite
var stopWatch: StopWatch = StopWatch.new()

# TODO Get rid of scroll making disk tilt and make that how power is set instead
# TODO Make dynamic scorecard
#		Make each part of the scorecard a node object
#		Make a script to create the scorecard based off how many holes the scene contains
#		Also adds the number of players dynamically
#		Creates scroll bars to allow for more than 18 holes and more than 4 players
# TODO Add charge effects
#		Wobble if held too long
#		Will just inaccurately launch after x amount of time
# TODO Add "perfect" release window
# TODO Give "perfect" release different effects
# TODO Ability to put spin on disk and curve it
# TODO Make a disk that makes flight path based off physics (there is some method that can be called to get expected path)
#		This will take the flight time to simulate
#		Have a dot show where it is in calculating and a line follow behind it
#			Use draws ability to hold the line for a few seconds before disappearing
# TODO Make a disk that forces the flight of the released disk along the calculated path
#		Can be done with PathFolow node apparently

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

func hold_action(delta: float) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(USER_INPUT.ACTION.SECONDARY):
		stopWatch.reset()
		chargeControl.set_progress(-1)
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		var heldTime: float = stopWatch.isHeld(delta)
		chargeControl.set_progress((heldTime / GLOBAL_SETTINGS.DISK.MAX_HOLD) * 100)
		var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, heldTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		self.draw_aim_line(multiplier)

## Launch disk and reset objects
func release_action() -> void:
	if not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		chargeControl.set_progress(-1)
		var finalTime: float = stopWatch.reset()
		var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, finalTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		self.launch_disk(multiplier, ThrowableItem.TYPE.CHARGE)
