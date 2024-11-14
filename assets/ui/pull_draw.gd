extends Node2D
class_name PullDraw

var ownerVar: ChuckChucker
var originHold: Vector2 = Vector2.INF
var holdCurrent: Vector2 = Vector2.INF
var lastLength: float = 0.0
var lastOffset: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chuckResult = NodeUtil.find_chucker(self)
	if chuckResult is ChuckChucker:
		ownerVar = chuckResult

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if ownerVar != null:
		if Input.is_action_pressed(CONSTANTS.USER_INPUT.PRIMARY) and not Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY) and ownerVar.is_equipped():
			if originHold == Vector2.INF:
				originHold = get_tree().root.get_viewport().get_mouse_position()
			holdCurrent = get_tree().root.get_viewport().get_mouse_position()
			self._calc_last_values()
		elif Input.is_action_just_released(CONSTANTS.USER_INPUT.PRIMARY):
			self.reset_pull()
		if lastLength != 0:
			self.queue_redraw()

func reset_pull() -> void:
		originHold = Vector2.INF
		holdCurrent = Vector2.INF
		self._calc_last_values()

func _calc_last_values() -> void:
	var xVal: float = pow((holdCurrent.x - originHold.x), 2)
	var yVal: float = pow((holdCurrent.y - originHold.y), 2)
	lastLength = min(GLOBAL_SETTINGS.DISK.MAX_PULL, sqrt(xVal + yVal))
	var offset: float = originHold.x - holdCurrent.x
	if offset > 0:
		lastOffset = min(GLOBAL_SETTINGS.DISK.MAX_OFFSET, offset)
	else:
		lastOffset = max(-GLOBAL_SETTINGS.DISK.MAX_OFFSET, offset)

func _draw() -> void:
	# Draw aim line
	var offsetPoint: Vector2 = originHold.move_toward(holdCurrent, abs(lastOffset))
	draw_line(originHold, offsetPoint, Color.RED, .5, true)
	# Draw power line
	var drawPoint: Vector2 = originHold.move_toward(holdCurrent, lastLength)
	draw_line(originHold, drawPoint, Color.YELLOW, 1, true)
