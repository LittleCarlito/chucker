extends Node2D
class_name PullDraw

var origin_hold: Vector2 = Vector2.INF
var hold_current: Vector2 = Vector2.INF
var last_length: float = 0.0
var last_offset: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if last_length != 0:
		self.queue_redraw()

func begin_pull() -> void:
	if origin_hold == Vector2.INF:
		origin_hold = get_tree().root.get_viewport().get_mouse_position()
	hold_current = get_tree().root.get_viewport().get_mouse_position()
	calc_last_values()

func reset_pull() -> void:
	origin_hold = Vector2.INF
	hold_current = Vector2.INF
	calc_last_values()

func calc_last_values() -> void:
	# Calculate Y-axis pull for power line length
	var y_pull: float = abs(hold_current.y - origin_hold.y)
	last_length = min(GameConfig.DEFAULTS.max_pull, y_pull)
	# Calculate X-axis pull for aim line offset/length
	var x_pull: float = hold_current.x - origin_hold.x
	if x_pull > 0:
		last_offset = min(GameConfig.DEFAULTS.max_offset, x_pull)
	else:
		last_offset = max(-GameConfig.DEFAULTS.max_offset, x_pull)

func _draw() -> void:
	# Draw power line first
	var power_end_point: Vector2 = origin_hold.move_toward(hold_current, last_length)
	draw_line(origin_hold, power_end_point, Color.YELLOW, 1, true)
	# Draw aim line starting from end of power line
	var offset_point: Vector2 = power_end_point.move_toward(hold_current, abs(last_offset))
	draw_line(power_end_point, offset_point, Color.RED, .5, true)