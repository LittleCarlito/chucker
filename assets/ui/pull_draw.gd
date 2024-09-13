extends Node2D
class_name PullDraw

var originHold: Vector2 = Vector2.INF
var holdCurrent: Vector2 = Vector2.INF
var lastLength: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed(USER_INPUT.ACTION.PRIMARY):
		if originHold == Vector2.INF:
			originHold = get_tree().root.get_viewport().get_mouse_position()
		holdCurrent = get_tree().root.get_viewport().get_mouse_position()
		self._calc_last_length()
	elif Input.is_action_just_released(USER_INPUT.ACTION.PRIMARY):
		print("Lastlength " + str(lastLength))
		originHold = Vector2.INF
		holdCurrent = Vector2.INF
		self._calc_last_length()
	if lastLength != 0:
		self.queue_redraw()

func _calc_last_length() -> void:
	var xVal: float = pow((holdCurrent.x - originHold.x), 2)
	var yVal: float = pow((holdCurrent.y - originHold.y), 2)
	lastLength = min(GLOBAL_SETTINGS.DISK.MAX_PULL, sqrt(xVal + yVal))

func _draw() -> void:
	var drawPoint: Vector2 = originHold.move_toward(holdCurrent, lastLength)
	draw_line(originHold, drawPoint, Color.YELLOW, 1, true)
