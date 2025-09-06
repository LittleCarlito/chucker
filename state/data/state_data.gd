class_name StateData

const _NAME: String = "[StateData]"
const _GET_STATE_DATA: String = "get_state_data"

func get_state_data() -> Dictionary:
	Logger.error(Logger.UNIMPLEMENTED_LOG, [self._NAME, _GET_STATE_DATA], self)
	return {}