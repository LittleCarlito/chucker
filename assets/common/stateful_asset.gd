extends Node3D
class_name StatefulAsset

# TODO Move all the refreshing and getting of state/guid data into this class
#			Then make camera rig extend this as first test
#		After camera rig is over on this should be able to move base character over onto it
var _guid_ref: String
var _state_ref: StateData
var _dirty_state: bool = false

func sync_asset() -> void:
	pass

func set_state_dirty() -> void:
	self._dirty_state = true

func set_state_clean() -> void:
	self._dirty_state = false

func is_state_dirty() -> bool:
	return self._dirty_state

func _get_current_state() -> StateConfiguration.STATE:
	var found_state: StateData = self._get_state_ref()
	if found_state == null:
		return StateConfiguration.STATE.UNKNOWN
	return found_state.get_current_state()

func _get_guid_ref() -> Variant:
	# Only cares about null; Dirty state doesn't affect immutable thing like a GUID
	if self._guid_ref == null:
		if !self._refresh_refs():
			return null
	return self._guid_ref

func _get_state_ref() -> StateData:
	if self._state_ref == null or self.is_state_dirty():
		if !self._refresh_refs():
			# Don't need to log anything _refresh_refs should have logged failure enough
			return null
		return self._state_ref
	return null

func _refresh_refs() -> bool:
	self._guid_ref = self.get_meta(GroupData.GUID)
	# If still can't find a guid
	if self._guid_ref  == null or self._guid_ref.strip_edges().is_empty():
		Logger.error(self._MISSING_DATA, [GroupData.GUID], self)
		return false
	else:
		self._state_ref = GlobalStateController.get_header_data(self._guid_ref, StateHeaders.TYPE.DATA)
		if self._state_ref == null:
			Logger.error(self._MISSING_DATA, [self._NO_STATE_DATA], self)
			return false
	self.set_state_clean()
	return true
