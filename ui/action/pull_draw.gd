extends Node2D
class_name PullDraw

var origin_hold: Vector2 = Vector2.INF
var hold_current: Vector2 = Vector2.INF
var last_length: float = 0.0
var last_offset: float = 0.0
var x_axis_aim_ratio: float = 0.8
var x_axis_power_ratio: float = 0.2

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if last_length != 0:
		self.queue_redraw()

func begin_pull() -> PullData:
	if origin_hold == Vector2.INF:
		origin_hold = get_tree().root.get_viewport().get_mouse_position()
	hold_current = get_tree().root.get_viewport().get_mouse_position()
	return calc_last_values()

func reset_pull() -> void:
	origin_hold = Vector2.INF
	hold_current = Vector2.INF
	calc_last_values()

func calc_last_values() -> PullData:
	var y_pull: float = abs(hold_current.y - origin_hold.y)
	var x_pull: float = hold_current.x - origin_hold.x
	var x_pull_abs: float = abs(x_pull)
	var x_power_contribution: float = x_pull_abs * x_axis_power_ratio
	var total_power: float = y_pull + x_power_contribution
	last_length = min(GameConfig.DEFAULTS.max_pull, total_power)
	var x_aim_contribution: float = x_pull * x_axis_aim_ratio
	if x_aim_contribution > 0:
		last_offset = min(GameConfig.DEFAULTS.max_offset, x_aim_contribution)
	else:
		last_offset = max(-GameConfig.DEFAULTS.max_offset, x_aim_contribution)
	return self.get_pull_details()

func get_pull_details() -> PullData:
	return PullData.new(last_length, last_offset)

func _draw() -> void:
	var power_end_point: Vector2 = origin_hold.move_toward(hold_current, last_length)
	draw_line(origin_hold, power_end_point, Color.YELLOW, 1, true)
	var offset_point: Vector2 = power_end_point.move_toward(hold_current, abs(last_offset))
	draw_line(power_end_point, offset_point, Color.RED, .5, true)
