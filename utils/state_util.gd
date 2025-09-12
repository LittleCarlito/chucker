class_name StateUtil

const _MISSING_GUID: String = "Incoming node \"%s\" is missing guid meta"

static func get_state_string(state_value: int) -> String:
	match state_value:
		StateConfiguration.STATE.READY:
			return "READY"
		StateConfiguration.STATE.WINDUP_UNDERCOOKED:
			return "WINDUP_UNDERCOOKED"
		StateConfiguration.STATE.WINDUP_VERY_EARLY:
			return "WINDUP_VERY_EARLY"
		StateConfiguration.STATE.WINDUP_EARLY:
			return "WINDUP_EARLY"
		StateConfiguration.STATE.WINDUP_PERFECT:
			return "WINDUP_PERFECT"
		StateConfiguration.STATE.WINDUP_LATE:
			return "WINDUP_LATE"
		StateConfiguration.STATE.WINDUP_VERY_LATE:
			return "WINDUP_VERY_LATE"
		StateConfiguration.STATE.WINDUP_OVERCOOKED:
			return "WINDUP_OVERCOOKED"
		StateConfiguration.STATE.THROWING_UNDER:
			return "THROWING_UNDER"
		StateConfiguration.STATE.THROWING_PERFECT:
			return "THROWING_PERFECT"
		StateConfiguration.STATE.THROWING_OVER:
			return "THROWING_OVER"
		StateConfiguration.STATE.FOLLOW_THRU_UNDER:
			return "FOLLOW_THRU_UNDER"
		StateConfiguration.STATE.FOLLOW_THRU_PERFECT:
			return "FOLLOW_THRU_PERFECT"
		StateConfiguration.STATE.FOLLOW_THRU_OVER:
			return "FOLLOW_THRU_OVER"
		_:
			return "UNKNOWN"
