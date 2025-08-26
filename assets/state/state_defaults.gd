class_name STATE_DEFAULTS

const DEFAULT_STATE_VALUES: Dictionary = {
	ItemState.STATE.READY: 0,
	ItemState.STATE.WINDUP_UNDERCOOKED: 0.3,
	ItemState.STATE.WINDUP_VERY_EARLY: 0.6,
	ItemState.STATE.WINDUP_EARLY: 1,
	ItemState.STATE.WINDUP_PERFECT: 1.3,
	ItemState.STATE.WINDUP_LATE: 1.6,
	ItemState.STATE.WINDUP_VERY_LATE: 2,
	ItemState.STATE.WINDUP_OVERCOOKED: 2.3
}

static var DEFAULT_ITEM_STATE_CONFIG = ItemStateConfig.new(
	# Starting state
	0,
	#Ready
	DEFAULT_STATE_VALUES[ItemState.STATE.READY],
	# Windup windows
	DEFAULT_STATE_VALUES[ItemState.STATE.WINDUP_UNDERCOOKED], 
	DEFAULT_STATE_VALUES[ItemState.STATE.WINDUP_VERY_EARLY], 
	DEFAULT_STATE_VALUES[ItemState.STATE.WINDUP_EARLY],
	DEFAULT_STATE_VALUES[ItemState.STATE.WINDUP_PERFECT],
	DEFAULT_STATE_VALUES[ItemState.STATE.WINDUP_LATE],
	DEFAULT_STATE_VALUES[ItemState.STATE.WINDUP_VERY_LATE],
	DEFAULT_STATE_VALUES[ItemState.STATE.WINDUP_OVERCOOKED]
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
	if incoming_type == AssetData.TYPE.PULL || incoming_type == AssetData.TYPE.CHARGE:
		return STATE_DEFAULTS.DEFAULT_ITEM_STATE_CONFIG
	else:
		return ItemStateConfig.new(0)

const SPIN: Dictionary = {
	ItemState.STATE.READY: 0,
	ItemState.STATE.WINDUP_UNDERCOOKED: 0.2,
	ItemState.STATE.WINDUP_VERY_EARLY: 0.3,
	ItemState.STATE.WINDUP_EARLY: .6,
	ItemState.STATE.WINDUP_PERFECT: 1.0,
	ItemState.STATE.WINDUP_LATE: 1.4,
	ItemState.STATE.WINDUP_VERY_LATE: 1.7,
	ItemState.STATE.WINDUP_OVERCOOKED: 2.0
}

static func get_spin_amount(incoming_state: ItemState.STATE) -> float:
	if SPIN.has(incoming_state):
		return SPIN[incoming_state]
	else:
		var incoming_state_string: String = ItemState.get_state_string(incoming_state)
		var warning_string: String = "Incoming state %s does not have an associated spin amount" % [incoming_state_string]
		push_warning(warning_string)
		return 0
