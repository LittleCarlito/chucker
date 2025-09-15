class_name ThrowableStateConfiguration


# TODO None of this shit is right anymore; all of those constants have moved

const WINDOW_VALUES: Dictionary = {
	StateConfiguration.STATE.READY: 0,
	StateConfiguration.STATE.WINDUP_UNDERCOOKED: 0.3,
	StateConfiguration.STATE.WINDUP_VERY_EARLY: 0.6,
	StateConfiguration.STATE.WINDUP_EARLY: 1,
	StateConfiguration.STATE.WINDUP_PERFECT: 1.3,
	StateConfiguration.STATE.WINDUP_LATE: 1.6,
	StateConfiguration.STATE.WINDUP_VERY_LATE: 2,
	StateConfiguration.STATE.WINDUP_OVERCOOKED: 2.3
}

const VALID_TRANSITIONS: Dictionary = {
	StateConfiguration.STATE.READY: 	[
				StateConfiguration.STATE.WINDUP_UNDERCOOKED,
				StateConfiguration.STATE.WINDUP_VERY_EARLY,
				StateConfiguration.STATE.WINDUP_EARLY,
				StateConfiguration.STATE.WINDUP_PERFECT,
				StateConfiguration.STATE.WINDUP_LATE,
				StateConfiguration.STATE.WINDUP_VERY_LATE,
				StateConfiguration.STATE.WINDUP_OVERCOOKED
	],
	StateConfiguration.STATE.WINDUP_UNDERCOOKED: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.WINDUP_VERY_EARLY, 
				StateConfiguration.STATE.THROWING_UNDER
	],
	StateConfiguration.STATE.WINDUP_VERY_EARLY: [
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.WINDUP_EARLY,
				StateConfiguration.STATE.THROWING_UNDER
	],
	StateConfiguration.STATE.WINDUP_EARLY: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.WINDUP_PERFECT, 
				StateConfiguration.STATE.THROWING_UNDER
	],
	StateConfiguration.STATE.WINDUP_PERFECT: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.WINDUP_LATE, 
				StateConfiguration.STATE.THROWING_PERFECT
	],
	StateConfiguration.STATE.WINDUP_LATE: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.WINDUP_VERY_LATE, 
				StateConfiguration.STATE.THROWING_OVER
	],
	StateConfiguration.STATE.WINDUP_VERY_LATE: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.WINDUP_OVERCOOKED, 
				StateConfiguration.STATE.THROWING_OVER
	],
	StateConfiguration.STATE.WINDUP_OVERCOOKED: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.THROWING_OVER
	],
	StateConfiguration.STATE.THROWING_UNDER: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.FOLLOW_THRU_UNDER
	],
	StateConfiguration.STATE.THROWING_PERFECT: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.FOLLOW_THRU_PERFECT
	],
	StateConfiguration.STATE.THROWING_OVER: [
				StateConfiguration.STATE.READY, 
				StateConfiguration.STATE.FOLLOW_THRU_OVER
	],
	StateConfiguration.STATE.FOLLOW_THRU_UNDER: [StateConfiguration.STATE.READY],
	StateConfiguration.STATE.FOLLOW_THRU_PERFECT: [StateConfiguration.STATE.READY],
	StateConfiguration.STATE.FOLLOW_THRU_OVER: [StateConfiguration.STATE.READY]
}

const SPIN_VALUES: Dictionary = {
	StateConfiguration.STATE.READY: 0,
	StateConfiguration.STATE.WINDUP_UNDERCOOKED: 0.2,
	StateConfiguration.STATE.WINDUP_VERY_EARLY: 0.3,
	StateConfiguration.STATE.WINDUP_EARLY: .6,
	StateConfiguration.STATE.WINDUP_PERFECT: 1.0,
	StateConfiguration.STATE.WINDUP_LATE: 1.4,
	StateConfiguration.STATE.WINDUP_VERY_LATE: 1.7,
	StateConfiguration.STATE.WINDUP_OVERCOOKED: 2.0
}
