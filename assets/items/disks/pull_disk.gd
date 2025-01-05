# TODO Refactor this to be an actual ThrowableItem with an internal camera and functions
extends Node3D
class_name PullDisk

# TODO Allow for holding space or something to set power but still pull for offset
# TODO Make a maximum pull time like charge disk
#		Probably make that part of ThrowableItem and not have it in both
#		Make it shake the disk as timer gets closer until it finally just inaccurately launches

@export var pull_draw: PullDraw
@export var charge_view: ChargeView
var item_data: AssetData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	charge_view.set_progress(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Perform pull disk calls
	#var is_owner_equipped: bool = item_owner != null && item_owner.is_equipped()
	#var only_primary_held: bool = Input.is_action_pressed(GroupData.USER_INPUT.PRIMARY) and not Input.is_action_pressed(GroupData.USER_INPUT.SECONDARY)
	#if only_primary_held and is_owner_equipped:
		#pull_draw.begin_pull()
	#elif Input.is_action_just_released(GroupData.USER_INPUT.PRIMARY):
		#pull_draw.reset_pull()
	# Use ThrowableItem aim handling
	pass

func _input(_event: InputEvent) -> void:
	#handle_input(event)
	pass

# TODO Need to refactor to use AimLine and not extend anything
func hold_action(_delta: float) -> void:
	pass
	## If right click is pressed while holding left reset throw
	#if Input.is_action_just_pressed(GroupData.USER_INPUT.SECONDARY):
		#pull_draw.reset_pull()
		#charge_view.set_progress(-1)
		#reset_launch_parameters()
	## If right click isn't held while holding left click calculate throw distance
	#elif not Input.is_action_pressed(GroupData.USER_INPUT.SECONDARY):
		#charge_view.set_progress((pull_draw.last_length / GlobalSettings.DISK.MAX_PULL) * 100)
		#var multiplier: float = (pull_draw.last_length / 100) * GlobalSettings.DISK.HOLD_MULTIPLIER
		#launch_path = draw_aim_line(multiplier, pull_draw.last_offset * .01)

# TODO Need to refactor to use FlightData and DiskFactory
func release_action() -> void:
	pass
	## If right click is not held launch the disk
	#if not Input.is_action_pressed(GroupData.USER_INPUT.SECONDARY) and pull_draw.last_length > GlobalSettings.DISK.MIN_PULL:
		#var multiplier: float = min(GlobalSettings.DISK.MAX_HOLD, (pull_draw.last_length / 100)) * GlobalSettings.DISK.HOLD_MULTIPLIER
		#set_launch_parameters(launch_path, multiplier, self.global_basis.get_euler().x)
		#launch_disk()
	#charge_view.set_progress(-1)
