# TODO Refactor this to use ECS structure instead of inheritance
extends ThrowableItem
class_name ChargeDisk

const disk_scene: PackedScene = preload(SceneLibrary.MESH.CHARGE_SCENE)

@onready var charge_view: ChargeView = $ChargeView
@onready var camera_container: CameraContainer = $CameraContainer
@onready var aim_line: AimLine = $AimLine

var stopwatch: Stopwatch = Stopwatch.new()
@export var flight_data: FlightData

# TODO Have charge and line decrease after reaching max and increase after reaching min on long holds
# TODO Add charge effects
#		Wobble if held too long
#		Will just inaccurately launch after x amount of time
# TODO Add "perfect" release window
# TODO Give "perfect" release different effects
# TODO Ability to put spin on disk and curve it

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	charge_view.set_progress(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

static func new_object() -> ChargeDisk:
	var new_disk: ChargeDisk = disk_scene.instantiate()
	new_disk.name = new_disk.name + "-" + str(new_disk.get_instance_id())
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
		var speed_multiplier: float = min(GlobalSettings.DISK.MAX_HOLD, held_time) * GlobalSettings.DISK.HOLD_MULTIPLIER
		# TODO Need to get draw_aim_line functionality into global node or resource
		flight_data.flight_path = aim_line.draw_aim_line(speed_multiplier)

## Launch disk and reset objects
func release_action() -> void:
	if not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		charge_view.set_progress(-1)
		var final_time: float = stopwatch.reset()
		var speed_multiplier: float = min(GlobalSettings.DISK.MAX_HOLD, final_time) * GlobalSettings.DISK.HOLD_MULTIPLIER
		flight_data.flight_path = aim_line.draw_aim_line(speed_multiplier)
		# TODO Added this last multiplier bit in from force disks method (should be done by caller) don't know if its necessary though
		#		If it is should be simplified into the calculation above instead of 2 separate lines
		var final_speed: float = GlobalSettings.DISK.LAUNCH_SPEED * speed_multiplier
		flight_data = FlightData.create_flight_data(final_speed, self.global_basis.get_euler().x, flight_data.flight_path, flight_data.focus_flight)
		# TODO Launcd disk needs to be refactored into this class
		launch_disk()

func reset_launch_parameters() -> void:
	flight_data = null
