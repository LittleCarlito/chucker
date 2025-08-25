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

static var DEFAULT_STATE_CONFIG = ItemStateConfig.new(
	15, 
	30, 
	45, 
	60,
	75,
	90,
	105,
	120,
	135,
	150,
	165,
	180,
	195,
	210
)

static func get_default_config(incoming_type: AssetData.TYPE) -> ItemStateConfig:
	match incoming_type:
		AssetData.TYPE.CHARGE || AssetData.TYPE.PULL:
			return DEFAULT_STATE_CONFIG
		_:
			return ItemStateConfig.new()
