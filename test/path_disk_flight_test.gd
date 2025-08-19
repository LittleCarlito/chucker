extends Node3D

const _RUN_PATH_TEST: String = "_run_path_test"

var _test_run: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !_test_run:
		var testResult: int = _run_path_test()
		_test_run = true
		if testResult == 0:
			Logger.info("%s PASSED", [_RUN_PATH_TEST], self)
		else:
			Logger.error("%s FAILED; Run code = %d", [_RUN_PATH_TEST, testResult], self)

func _run_path_test() -> int:
	# TODO Spawn in a PathDisk with a set path and velocity and see if you can get the mesh to travel until a collision is detected; Return 0 in that case
	var testTransform: Transform3D = Transform3D(Vector3(0.999998, -0.002236, 0.000878), Vector3(0.001349, 0.825238, 0.564784), Vector3(-0.001988, -0.564781, 0.82524), Vector3(1.644701, 1.241508, -1.595694))
	var testPath: Array[Vector3] = [Vector3(1.644701, 1.241508, -1.595694), Vector3(1.632978, 2.2656, -3.226686), Vector3(1.622894, 3.095902, -4.837415), Vector3(1.614465, 3.745655, -6.437603), Vector3(1.607703, 4.228102, -8.036968), Vector3(1.602622, 4.556486, -9.645232), Vector3(1.599235, 4.744051, -11.27211), Vector3(1.597556, 4.804039, -12.92734), Vector3(1.597599, 4.749695, -14.62062), Vector3(1.599377, 4.59426, -16.36168), Vector3(1.602904, 4.350977, -18.16025), Vector3(1.608192, 4.033089, -20.02604), Vector3(1.615257, 3.653841, -21.96877), Vector3(1.624111, 3.226474, -23.99817), Vector3(1.634768, 2.764232, -26.12395), Vector3(1.647241, 2.280357, -28.35584), Vector3(1.661545, 1.788093, -30.70355), Vector3(1.677692, 1.300682, -33.1768), Vector3(1.695696, 0.831369, -35.78533), Vector3(1.715571, 0.393395, -38.53884), Vector3(1.73733, 0.000004, -41.44706)]
	var testSpeed: float = 20.0181167945439
	var testAngle: float = 0.60016733407974
	var testPathDisk: PathDisk = AssetFactory.new_path_disk()
	testPathDisk.global_transform = testTransform
	get_tree().root.add_child(testPathDisk)
	testPathDisk.prepare_item(AssetData.TYPE)
	var path_flight_data: FlightData = FlightData.new(testSpeed, testTransform.basis, testPath, false)
	testPathDisk._set_flight_data(path_flight_data)
	testPathDisk._launch()
	#testPathDisk.set_launch_parameters(testPath, testSpeed, testAngle)
	return 1
