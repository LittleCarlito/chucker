extends Node3D
class_name StatefulAsset

var _guid_ref: String
var _state_ref: StateData
var _dirty_state: bool = false
var _skip_tags: Array[String] = [GameAction.SYNC]

func sync_asset() -> void:
	var self_guid: String = self._get_guid_ref()
	var current_position: Vector3 = self.global_position
	var position_dictionary: Dictionary = {
		GameAction.X: current_position.x,
		GameAction.Y: current_position.y,
		GameAction.Z: current_position.z
	}
	var current_rotation: Vector3 = self.global_rotation
	var rotation_dictionary: Dictionary = {
		GameAction.X: current_rotation.x,
		GameAction.Y: current_rotation.y,
		GameAction.Z: current_rotation.z
	}
	var current_scale: Vector3 = self.scale
	var scale_dictionary: Dictionary = {
		GameAction.X: current_scale.x,
		GameAction.Y: current_scale.y,
		GameAction.Z: current_scale.z
	}
	var tag_list: Array[String] = [GameAction.SYNC]
	var sync_action_dictionary: Dictionary = {
		GameAction.OWNER_GUID: self_guid,
		GameAction.POSITION: position_dictionary,
		GameAction.ROTATION: rotation_dictionary,
		GameAction.SCALE: scale_dictionary,
		GameAction.TAGS: tag_list
	}
	var sync_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, sync_action_dictionary)
	GlobalStateController.dispatch(sync_action)

func set_state_dirty() -> void:
	self._dirty_state = true

func set_state_clean() -> void:
	self._dirty_state = false

func is_state_dirty() -> bool:
	return self._dirty_state

func _handle_new_state_signal(update_details: Dictionary) -> bool:
	var self_guid: String = self._get_guid_ref()
	# If null or not in update details return false
	if self_guid == null || !(self_guid in update_details):
		if self_guid == null:
			Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._HANDLE_STATE_SIGNAL], self)
		return false
	elif self_guid in update_details:
		var self_details: Dictionary = update_details[self_guid]
		if self_details.has(GameAction.TAGS):
			var found_tags: Array[String] = self_details[GameAction.TAGS]
			return !self._skip_tags.any(func(tag): return tag in found_tags) 
	return true

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
