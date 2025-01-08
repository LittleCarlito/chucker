extends Node3D

# TODO Practice passing camera between different camera containers moving on paths and falling or doing other physics actions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# Spawn in Character so a camera exists
	var chuck_data: AssetData = AssetDelivery.create_asset_data(AssetData.TYPE.PLAYER, AssetData.ITEM_STATE.ACTIVATED, AssetData.CAMERA_STATE.ACTIVE)
	var chuck_location: Vector3 = Vector3(0, 1, 0)
	var new_chuck: ChuckChucker = AssetDelivery.spawn_asset(chuck_data, chuck_location, self) as ChuckChucker
	# Create test disks
	var test_transform: Transform3D = Transform3D(Vector3(0.999998, -0.002236, 0.000878), Vector3(0.001349, 0.825238, 0.564784), Vector3(-0.001988, -0.564781, 0.82524), Vector3(1.644701, 1.241508, -1.595694))
	var test_path: Array[Vector3] = [Vector3(1.644701, 1.241508, -1.595694), Vector3(1.632978, 2.2656, -3.226686), Vector3(1.622894, 3.095902, -4.837415), Vector3(1.614465, 3.745655, -6.437603), Vector3(1.607703, 4.228102, -8.036968), Vector3(1.602622, 4.556486, -9.645232), Vector3(1.599235, 4.744051, -11.27211), Vector3(1.597556, 4.804039, -12.92734), Vector3(1.597599, 4.749695, -14.62062), Vector3(1.599377, 4.59426, -16.36168), Vector3(1.602904, 4.350977, -18.16025), Vector3(1.608192, 4.033089, -20.02604), Vector3(1.615257, 3.653841, -21.96877), Vector3(1.624111, 3.226474, -23.99817), Vector3(1.634768, 2.764232, -26.12395), Vector3(1.647241, 2.280357, -28.35584), Vector3(1.661545, 1.788093, -30.70355), Vector3(1.677692, 1.300682, -33.1768), Vector3(1.695696, 0.831369, -35.78533), Vector3(1.715571, 0.393395, -38.53884), Vector3(1.73733, 0.000004, -41.44706)]
	# TODO Refactor FlightData to be Transform and not Basis
	var path_disk_data: AssetData = AssetDelivery.create_asset_data(AssetData.TYPE.PATH, AssetData.ITEM_STATE.DISABLED, AssetData.CAMERA_STATE.TRACKABLE, AssetData.TYPE.FORCE, new_chuck.asset_data.group_name)
	var path_flight_data: FlightData = FlightData.create_flight_data(15, test_transform.basis, test_path, false)
	var new_path_disk: PathDisk = AssetDelivery.create_and_launch(path_flight_data, path_disk_data)
	#new_path_disk.global_transform = test_transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
