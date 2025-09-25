# TODO Rename please for the love of god
class_name StateConfiguration

enum STATE {
	# Default
	READY = 0,
	# Throw action
	IS_WINDUP = 100,
	WINDUP_UNDERCOOKED = 110,
	WINDUP_VERY_EARLY = 120,
	WINDUP_EARLY = 125,
	WINDUP_PERFECT = 150,
	WINDUP_LATE = 175,
	WINDUP_VERY_LATE = 180,
	WINDUP_OVERCOOKED = 190,
	IS_THROWING = 200,
	THROWING_UNDER = 225,
	THROWING_PERFECT = 250,
	THROWING_OVER = 275,
	IS_FOLLOW_THRU = 300,
	FOLLOW_THRU_UNDER = 325,
	FOLLOW_THRU_PERFECT = 350,
	FOLLOW_THRU_OVER = 375,
	# Camera
	IS_TRACKING = 500,
	TRACKING_FULL = 501,
	TRACKING_POS = 502,
	TRACKING_FREE = 503,
	IDLE_ROTATE = 504,
	IS_FREELOOK = 550,
	FREELOOK_MOVE = 551,
	FREELOOK_STUCK = 552,
	DISABLED = 600,
	# General
	UNKNOWN = -999
}

static var _state_strings = {
	STATE.READY: "Ready",
	STATE.IS_WINDUP: "Is Windup",
	STATE.WINDUP_UNDERCOOKED: "Windup Undercooked",
	STATE.WINDUP_VERY_EARLY: "Windup Very Early",
	STATE.WINDUP_EARLY: "Windup Early",
	STATE.WINDUP_PERFECT: "Windup Perfect",
	STATE.WINDUP_LATE: "Windup Late",
	STATE.WINDUP_VERY_LATE: "Windup Very Late",
	STATE.WINDUP_OVERCOOKED: "Windup Overcooked",
	STATE.IS_THROWING: "Is Throwing",
	STATE.THROWING_UNDER: "Throwing Under",
	STATE.THROWING_PERFECT: "Throwing Perfect",
	STATE.THROWING_OVER: "Throwing Over",
	STATE.IS_FOLLOW_THRU: "Is Follow Through",
	STATE.FOLLOW_THRU_UNDER: "Follow Through Under",
	STATE.FOLLOW_THRU_PERFECT: "Follow Through Perfect",
	STATE.FOLLOW_THRU_OVER: "Follow Through Over",
	STATE.IS_TRACKING: "Is Tracking",
	STATE.TRACKING_FULL: "Full Tracking",
	STATE.TRACKING_POS: "Position Tracking",
	STATE.TRACKING_FREE: "Free Tracking",
	STATE.IDLE_ROTATE: "Idle Rotate",
	STATE.IS_FREELOOK: "Is Freelook",
	STATE.FREELOOK_MOVE: "Freelook Move",
	STATE.FREELOOK_STUCK: "Freelook Stuck",
	STATE.DISABLED: "Disabled",
	STATE.UNKNOWN: "Unknown"
}

static var _string_states = {}

static func _init_reverse_lookup():
	if _string_states.size() == 0:
		for state in _state_strings:
			_string_states[_state_strings[state].to_upper()] = state

static func get_state_string(incoming_state: STATE) -> String:
	return _state_strings.get(incoming_state, "Unknown")

static func get_state_from_string(state_string: String) -> STATE:
	_init_reverse_lookup()
	return _string_states.get(state_string.to_upper(), STATE.UNKNOWN)
