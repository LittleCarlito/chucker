# TODO Rename
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
	FULL_TRACKING = 501,
	POS_TRACKING = 502,
	FREE_TRACKING = 503,
	IDLE_ROTATE = 520,
	IS_FREELOOK = 550,
	FREELOOK_MOVE = 551,
	FREELOOK_STUCK = 552,
	DISABLED = 600,
	# General
	UNKNOWN = -999
}

const _READY: String = "Ready"
const _IS_WINDUP: String = "Is Windup"
const _WINDUP_UNDERCOOKED: String = "Windup Undercooked"
const _WINDUP_VERY_EARLY: String = "Windup Very Early"
const _WINDUP_EARLY: String = "Windup Early"
const _WINDUP_PERFECT: String = "Windup Perfect"
const _WINDUP_LATE: String = "Windup Late"
const _WINDUP_VERY_LATE: String = "Windup Very Late"
const _WINDUP_OVERCOOKED: String = "Windup Overcooked"
const _IS_THROWING: String = "Is Throwing"
const _THROWING_UNDER: String = "Throwing Under"
const _THROWING_PERFECT: String = "Throwing Perfect"
const _THROWING_OVER: String = "Throwing Over"
const _IS_FOLLOW_THRU: String = "Is Follow Through"
const _FOLLOW_THRU_UNDER: String = "Follow Through Under"
const _FOLLOW_THRU_PERFECT: String = "Follow Through Perfect"
const _FOLLOW_THRU_OVER: String = "Follow Through Over"
const _IS_TRACKING: String = "Is Tracking"
const _FULL_TRACKING: String = "Full Tracking"
const _POS_TRACKING: String = "Position Tracking"
const _FREE_TRACKING: String = "Free Tracking"
const _IDLE_ROTATE: String = "Idle Rotate"
const _IS_FREELOOK: String = "Is Freelook"
const _FREELOOK_MOVE: String = "Freelook Move"
const _FREELOOK_STUCK: String = "Freelook Stuck"
const _DISABLED: String = "Disabled"
const _UNKNOWN: String = "Unknown"

static func get_state_string(incoming_state: STATE) -> String:
	match incoming_state:
		STATE.READY:
			return _READY
		STATE.IS_WINDUP:
			return _IS_WINDUP
		STATE.WINDUP_UNDERCOOKED:
			return _WINDUP_UNDERCOOKED
		STATE.WINDUP_VERY_EARLY:
			return _WINDUP_VERY_EARLY
		STATE.WINDUP_EARLY:
			return _WINDUP_EARLY
		STATE.WINDUP_PERFECT:
			return _WINDUP_PERFECT
		STATE.WINDUP_LATE:
			return _WINDUP_LATE
		STATE.WINDUP_VERY_LATE:
			return _WINDUP_VERY_LATE
		STATE.WINDUP_OVERCOOKED:
			return _WINDUP_OVERCOOKED
		STATE.IS_THROWING:
			return _IS_THROWING
		STATE.THROWING_UNDER:
			return _THROWING_UNDER
		STATE.THROWING_PERFECT:
			return _THROWING_PERFECT
		STATE.THROWING_OVER:
			return _THROWING_OVER
		STATE.IS_FOLLOW_THRU:
			return _IS_FOLLOW_THRU
		STATE.FOLLOW_THRU_UNDER:
			return _FOLLOW_THRU_UNDER
		STATE.FOLLOW_THRU_PERFECT:
			return _FOLLOW_THRU_PERFECT
		STATE.FOLLOW_THRU_OVER:
			return _FOLLOW_THRU_OVER
		STATE.IS_TRACKING:
			return _IS_TRACKING
		STATE.FULL_TRACKING:
			return _FULL_TRACKING
		STATE.POS_TRACKING:
			return _POS_TRACKING
		STATE.FREE_TRACKING:
			return _FREE_TRACKING
		STATE.IDLE_ROTATE:
			return _IDLE_ROTATE
		STATE.IS_FREELOOK:
			return _IS_FREELOOK
		STATE.FREELOOK_MOVE:
			return _FREELOOK_MOVE
		STATE.FREELOOK_STUCK:
			return _FREELOOK_STUCK
		STATE.DISABLED:
			return _DISABLED
		STATE.UNKNOWN:
			return _UNKNOWN
		_:
			return _UNKNOWN
