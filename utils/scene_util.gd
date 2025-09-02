class_name SceneUtil

## Focuses the first found character using the first found camera rig
static func focus_character(incoming_assets: Dictionary) -> void:
	# Focus main character
	if incoming_assets.has(AssetData.TYPE.CAMERA) && incoming_assets.has(AssetData.TYPE.PLAYER):
		var player_characters: Array = incoming_assets[AssetData.TYPE.PLAYER]
		var main_character: ChuckChucker = player_characters[0]
		var camera_rigs: Array = incoming_assets[AssetData.TYPE.CAMERA]
		var main_rig: CameraRig = camera_rigs[0]
		main_rig.make_current()
		main_rig.set_integration_point(main_character, true)
