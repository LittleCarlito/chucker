extends Node3D

@onready var start: Vector3 = $Start.position
@onready var startControl: Vector3 = $StartControl.position
@onready var endControl: Vector3 = $EndControl.position
@onready var end: Vector3 = $End.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	DrawUtil.curve(start, startControl, endControl, end)
