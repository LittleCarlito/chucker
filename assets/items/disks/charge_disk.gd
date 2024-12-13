# TODO See if this and pull disk really need to be of the same inheritance type; If they do make their scene structure similar to others
extends ThrowableItem
class_name ChargeDisk

const disk_scene: PackedScene = preload(SceneLibrary.MESH.CHARGE_SCENE)

@onready var charge_view: ChargeView = $ChargeView

var stopwatch: Stopwatch = Stopwatch.new()

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
	charge_view.set_progress(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	handle_aiming()

func _input(event: InputEvent) -> void:
	handle_input(event)

static func new_object(incoming_type: CONSTANTS.DISK_TYPE, incoming_owner: ChuckChucker, incoming_camera: Camera3D) -> ChargeDisk:
	var new_disk: ChargeDisk = disk_scene.instantiate()
	new_disk.name = new_disk.name + "-" + str(new_disk.get_instance_id())
	new_disk.prepare_item(incoming_type, incoming_owner, incoming_camera)
	return new_disk

func hold_action(delta: float) -> void:
	# If right click is pressed while holding left reset throw
	if Input.is_action_just_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		stopwatch.reset()
		charge_view.set_progress(-1)
		reset_launch_parameters()
	# If right click isn't held while holding left click calculate throw distance
	elif not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		var held_time: float = stopwatch.isHeld(delta)
		charge_view.set_progress((held_time / GlobalSettings.DISK.MAX_HOLD) * 100)
		var multiplier: float = min(GlobalSettings.DISK.MAX_HOLD, held_time) * GlobalSettings.DISK.HOLD_MULTIPLIER
		launch_path = draw_aim_line(multiplier)

## Launch disk and reset objects
func release_action() -> void:
	if not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		charge_view.set_progress(-1)
		var final_time: float = stopwatch.reset()
		var final_speed: float = min(GlobalSettings.DISK.MAX_HOLD, final_time) * GlobalSettings.DISK.HOLD_MULTIPLIER
		set_launch_parameters(launch_path, final_speed, self.global_basis.get_euler().x)
		launch_disk()
