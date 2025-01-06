extends Node2D
class_name PullDraw

var _origin_hold: Vector2 = Vector2.INF
var _hold_current: Vector2 = Vector2.INF
var last_length: float = 0.0
var last_offset: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if last_length != 0:
		self.queue_redraw()

func begin_pull() -> void:
	if _origin_hold == Vector2.INF:
		_origin_hold = get_tree().root.get_viewport().get_mouse_position()
	_hold_current = get_tree().root.get_viewport().get_mouse_position()
	_calc_last_values()

func reset_pull() -> void:
		_origin_hold = Vector2.INF
		_hold_current = Vector2.INF
		_calc_last_values()

func _calc_last_values() -> void:
	var x_val: float = pow((_hold_current.x - _origin_hold.x), 2)
	var y_val: float = pow((_hold_current.y - _origin_hold.y), 2)
	last_length = min(GameConfig.DEFAULTS.max_pull, sqrt(x_val + y_val))
	var offset: float = _origin_hold.x - _hold_current.x
	if offset > 0:
		last_offset = min(GameConfig.DEFAULTS.max_offset, offset)
	else:
		last_offset = max(-GameConfig.DEFAULTS.max_offset, offset)

func _draw() -> void:
	# Draw aim line
	var offset_point: Vector2 = _origin_hold.move_toward(_hold_current, abs(last_offset))
	draw_line(_origin_hold, offset_point, Color.RED, .5, true)
	# Draw power line
	var draw_point: Vector2 = _origin_hold.move_toward(_hold_current, last_length)
	draw_line(_origin_hold, draw_point, Color.YELLOW, 1, true)
