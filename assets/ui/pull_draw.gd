extends Node2D

var originHold: Vector2 = Vector2.INF
var holdCurrent: Vector2 = Vector2.INF
var justClicked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed(USER_INPUT.ACTION.PRIMARY):
		if originHold == Vector2.INF:
			originHold = get_tree().root.get_viewport().get_mouse_position()
		holdCurrent = get_tree().root.get_viewport().get_mouse_position()
		justClicked = true
	elif Input.is_action_just_released(USER_INPUT.ACTION.PRIMARY):
		originHold = Vector2.INF
		holdCurrent = Vector2.INF
		justClicked = true
	if justClicked:
		self.queue_redraw()
		justClicked = false

func _draw() -> void:
	draw_line(originHold, holdCurrent, Color.YELLOW, 1, true)
