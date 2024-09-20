extends ThrowableItem
class_name ChargeDisk

@onready var chargeView: ChargeView = $ChargeView

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	chargeView.set_progress(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.handle_aiming()

func hold_action(delta: float) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(USER_INPUT.ACTION.SECONDARY):
		stopWatch.reset()
		chargeView.set_progress(-1)
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		var heldTime: float = stopWatch.isHeld(delta)
		chargeView.set_progress((heldTime / GLOBAL_SETTINGS.DISK.MAX_HOLD) * 100)
		var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, heldTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		self.draw_aim_line(multiplier)

## Launch disk and reset objects
func release_action() -> void:
	if not Input.is_action_pressed(USER_INPUT.ACTION.SECONDARY):
		chargeView.set_progress(-1)
		var finalTime: float = stopWatch.reset()
		var multiplier: float = min(GLOBAL_SETTINGS.DISK.MAX_HOLD, finalTime) * GLOBAL_SETTINGS.DISK.HOLD_MULTIPLIER
		self.launch_disk(multiplier, ThrowableItem.TYPE.CHARGE)
