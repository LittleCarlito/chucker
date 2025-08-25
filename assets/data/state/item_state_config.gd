class_name ItemStateConfig


static func get_default_config(incoming_type: AssetData.TYPE) -> ItemStateConfig:
	match incoming_type:
		AssetData.TYPE.CHARGE:
			pass
		AssetData.TYPE.PULL:
			pass
		_:
			pass
	return ItemStateConfig.new()
