extends Node3D

@onready var chuckChucker: ChuckChucker = $ChuckChucker
var newPathDisk:PathDisk

var debugCurve: Array[Vector3] = [Vector3(0.001666, 1.241508, 0.000112), Vector3(-0.012733, 2.085614, -2.727044), Vector3(-0.026994, 2.767997, -5.357461), Vector3(-0.04127, 3.299712, -7.910872), Vector3(-0.055714, 3.691816, -10.40701), Vector3(-0.070478, 3.955364, -12.86561), Vector3(-0.085714, 4.101413, -15.30641), Vector3(-0.101574, 4.141018, -17.74913), Vector3(-0.118211, 4.085238, -20.21352), Vector3(-0.135776, 3.945124, -22.7193), Vector3(-0.154423, 3.731735, -25.28621), Vector3(-0.174304, 3.456127, -27.93399), Vector3(-0.19557, 3.129355, -30.68237), Vector3(-0.218375, 2.762476, -33.55107), Vector3(-0.24287, 2.366545, -36.55984), Vector3(-0.269209, 1.952618, -39.72841), Vector3(-0.297542, 1.531752, -43.07652), Vector3(-0.328023, 1.115003, -46.62388), Vector3(-0.360803, 0.713426, -50.39024), Vector3(-0.396036, 0.338077, -54.39534), Vector3(-0.433873, 0.000013, -58.65891)]
var multiplier: float = 3.0
var launched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not launched:
		newPathDisk = PathDisk.new_disk()
		get_tree().get_root().add_child(newPathDisk)
		newPathDisk.prepare(debugCurve, multiplier, chuckChucker.get_camera(), chuckChucker)
		newPathDisk.top_level = true
		var diskMaterial: StandardMaterial3D = newPathDisk.chuckDisk.get_mesh().get_active_material(0)
		diskMaterial.albedo_color = Color.BLUE
		launched = true
