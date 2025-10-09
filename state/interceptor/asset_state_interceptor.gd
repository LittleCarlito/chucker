class_name AssetStateInterceptor

const _CONVERT_DETAIL_VALUES: String = "convert_detail_values"
const _TRACKED_ASSET_DATA: String = "tracked asset data"

static func convert_detail_values(incoming_asset_state: AssetState, incoming_update: StateUpdate) -> bool:
	var update_type: STATE.UPDATE_TYPE = incoming_update.get_update_type()
	match update_type:
		STATE.UPDATE_TYPE.FOCUS:
			var update_details: Dictionary = incoming_update.get_update_details()
			var missing_keys: Array[String] = StateUtil.get_missing_keys(update_details, [StateHeaders.TARGET_GUID])
			if missing_keys.is_empty():
				var target_guid: String = update_details[StateHeaders.TARGET_GUID]
				var tracked_data: AssetState = incoming_asset_state.get_tracked_data_for(target_guid)
				if tracked_data != null:
					var target_position: Vector3 = tracked_data.get_current_position()
					var new_details: Dictionary = {
						StateHeaders. TARGET_GUID: target_guid,
						StateHeaders.TARGET_POSITION:target_position
					}
					incoming_update.set_update_details(new_details)
					return true
				else:
					Log.error(Log._CANT_PERFORM, [_TRACKED_ASSET_DATA, _CONVERT_DETAIL_VALUES], null)
				# TODO Need to create a details payload for StateUpdate
				# TODO Need to make a new setter for StateUpdate for detail payload
			else:
				Log.error(Log._CANT_PERFORM, [missing_keys, _CONVERT_DETAIL_VALUES], null)
	return false
