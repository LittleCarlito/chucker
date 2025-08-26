class_name ItemState

enum STATE {
	READY = 0,
	WINDUP_UNDERCOOKED = 10,
	WINDUP_VERY_EARLY = 11,
	WINDUP_EARLY = 12,
	WINDUP_PERFECT = 13,
	WINDUP_LATE = 14,
	WINDUP_VERY_LATE = 15,
	WINDUP_OVERCOOKED = 16,
	THROWING_UNDER = 30,
	THROWING_PERFECT = 31,
	THROWING_OVER = 32,
	FOLLOW_THRU_UNDER = 50,
	FOLLOW_THRU_PERFECT = 51,
	FOLLOW_THRU_OVER = 52
}

const VALID_TRANSITIONS: Dictionary = {
	self.STATE.READY: 	[
				self.STATE.WINDUP_UNDERCOOKED,
				self.STATE.WINDUP_VERY_EARLY,
				self.STATE.WINDUP_EARLY,
				self.STATE.WINDUP_PERFECT,
				self.STATE.WINDUP_LATE,
				self.STATE.WINDUP_VERY_LATE,
				self.STATE.WINDUP_OVERCOOKED
	],
	self.STATE.WINDUP_UNDERCOOKED: [self.STATE.READY, self.STATE.THROWING_UNDER],
	self.STATE.WINDUP_VERY_EARLY: [self.STATE.READY, self.STATE.THROWING_UNDER],
	self.STATE.WINDUP_EARLY: [self.STATE.READY, self.STATE.THROWING_UNDER],
	self.STATE.WINDUP_PERFECT: [self.STATE.READY, self.STATE.THROWING_PERFECT],
	self.STATE.WINDUP_LATE: [self.STATE.READY, self.STATE.THROWING_OVER],
	self.STATE.WINDUP_VERY_LATE: [self.STATE.READY, self.STATE.THROWING_OVER],
	self.STATE.WINDUP_OVERCOOKED: [self.STATE.READY, self.STATE.THROWING_OVER],
	self.STATE.THROWING_UNDER: [self.STATE.READY, self.STATE.FOLLOW_THRU_UNDER],
	self.STATE.THROWING_PERFECT: [self.STATE.READY, self.STATE.FOLLOW_THRU_PERFECT],
	self.STATE.THROWING_OVER: [self.STATE.READY, self.STATE.FOLLOW_THRU_OVER]
}

static var DEFAULT_STATE_CONFIG = ItemStateConfig.new(
	# Starting state
	0,
	#Ready
	0,
	# Windup windows
	.3, 
	.6, 
	1,
	1.3,
	1.6,
	2,
	2.3
	# TODO Dynamically get throwing animation time values
	# ?,
	# ?,
	# ?,
	# TODO Dynamically get follow thru animation time values
	# ?,
	# ?,
	# ?
)

static func get_default_config(incoming_type: AssetData.TYPE) -> ItemStateConfig:
	match incoming_type:
		AssetData.TYPE.CHARGE || AssetData.TYPE.PULL:
			return DEFAULT_STATE_CONFIG
		_:
			return ItemStateConfig.new(0)
