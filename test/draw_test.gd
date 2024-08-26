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
	#var flightPath: Array = []
	#for n in 21:
		#flightPath.append(start.bezier_interpolate(startControl, endControl, end, (n * (1.0/20.0))))
		#print("n " + str(n) + "; n * " + str(1.0/20.0) + " = " + str(n * (1.0/20.0)))
	#for n in 20:
		#DrawUtil.line(flightPath[n], flightPath[n + 1])

# Desired amount = t; for t + 1; bezier_interpolate(startControl, endControl, end, (n * (1/t))
