extends Node2D
class_name PullDraw

var _originHold: Vector2 = Vector2.INF
var _holdCurrent: Vector2 = Vector2.INF
var lastLength: float = 0.0
var lastOffset: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if lastLength != 0:
		self.queue_redraw()

func begin_pull() -> void:
	if _originHold == Vector2.INF:
		_originHold = get_tree().root.get_viewport().get_mouse_position()
	_holdCurrent = get_tree().root.get_viewport().get_mouse_position()
	self._calc_last_values()

func reset_pull() -> void:
		_originHold = Vector2.INF
		_holdCurrent = Vector2.INF
		self._calc_last_values()

func _calc_last_values() -> void:
	var xVal: float = pow((_holdCurrent.x - _originHold.x), 2)
	var yVal: float = pow((_holdCurrent.y - _originHold.y), 2)
	lastLength = min(GlobalSettings.DISK.MAX_PULL, sqrt(xVal + yVal))
	var offset: float = _originHold.x - _holdCurrent.x
	if offset > 0:
		lastOffset = min(GlobalSettings.DISK.MAX_OFFSET, offset)
	else:
		lastOffset = max(-GlobalSettings.DISK.MAX_OFFSET, offset)

func _draw() -> void:
	# Draw aim line
	var offsetPoint: Vector2 = _originHold.move_toward(_holdCurrent, abs(lastOffset))
	draw_line(_originHold, offsetPoint, Color.RED, .5, true)
	# Draw power line
	var drawPoint: Vector2 = _originHold.move_toward(_holdCurrent, lastLength)
	draw_line(_originHold, drawPoint, Color.YELLOW, 1, true)
