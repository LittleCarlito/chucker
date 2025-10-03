class_name STATE

const HEADER: String = "State"

################################################################################
#                                GAME ENUM                                     #
################################################################################

enum GAME {
	MAIN_MENU,
	PAUSE_MENU,
	RUNNING_SCENE,
	UNKNOWN
}

static var _game_strings = {
	GAME.MAIN_MENU: "Main Menu",
	GAME.PAUSE_MENU: "Pause Menu",
	GAME.RUNNING_SCENE: "Running Scene",
	GAME.UNKNOWN: GroupData.UNKNOWN
}

static var _string_games = {}

static func _init_game_reverse_lookup():
	if _string_games.size() == 0:
		for state in _game_strings:
			_string_games[_game_strings[state].to_upper()] = state

static func get_game_string(incoming_state: STATE.GAME) -> String:
	return _game_strings.get(incoming_state, "Unknown")

static func get_game_from_string(state_string: String) -> STATE.GAME:
	_init_game_reverse_lookup()
	return _string_games.get(state_string.to_upper(), GAME.UNKNOWN)

################################################################################
#                                ASSET ENUM                                    #
################################################################################

enum ASSET {
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
	IS_TRACKING = 500,
	TRACKING_FULL = 501,
	TRACKING_POS = 502,
	TRACKING_FREE = 503,
	IDLE_ROTATE = 504,
	IS_FREELOOK = 550,
	FREELOOK_MOVE = 551,
	FREELOOK_STUCK = 552,
	DISABLED = 999,
	UNKNOWN = -999
}

static var _state_strings = {
	ASSET.READY: "Ready",
	ASSET.IS_WINDUP: "Is Windup",
	ASSET.WINDUP_UNDERCOOKED: "Windup Undercooked",
	ASSET.WINDUP_VERY_EARLY: "Windup Very Early",
	ASSET.WINDUP_EARLY: "Windup Early",
	ASSET.WINDUP_PERFECT: "Windup Perfect",
	ASSET.WINDUP_LATE: "Windup Late",
	ASSET.WINDUP_VERY_LATE: "Windup Very Late",
	ASSET.WINDUP_OVERCOOKED: "Windup Overcooked",
	ASSET.IS_THROWING: "Is Throwing",
	ASSET.THROWING_UNDER: "Throwing Under",
	ASSET.THROWING_PERFECT: "Throwing Perfect",
	ASSET.THROWING_OVER: "Throwing Over",
	ASSET.IS_FOLLOW_THRU: "Is Follow Through",
	ASSET.FOLLOW_THRU_UNDER: "Follow Through Under",
	ASSET.FOLLOW_THRU_PERFECT: "Follow Through Perfect",
	ASSET.FOLLOW_THRU_OVER: "Follow Through Over",
	ASSET.IS_TRACKING: "Is Tracking",
	ASSET.TRACKING_FULL: "Full Tracking",
	ASSET.TRACKING_POS: "Position Tracking",
	ASSET.TRACKING_FREE: "Free Tracking",
	ASSET.IDLE_ROTATE: "Idle Rotate",
	ASSET.IS_FREELOOK: "Is Freelook",
	ASSET.FREELOOK_MOVE: "Freelook Move",
	ASSET.FREELOOK_STUCK: "Freelook Stuck",
	ASSET.DISABLED: "Disabled",
	ASSET.UNKNOWN: GroupData.UNKNOWN
}

static var _string_states = {}

static func _init_reverse_lookup():
	if _string_states.size() == 0:
		for state in _state_strings:
			_string_states[_state_strings[state].to_upper()] = state

static func get_state_string(incoming_state: STATE.ASSET) -> String:
	return _state_strings.get(incoming_state, "Unknown")

static func get_state_from_string(state_string: String) -> STATE.ASSET:
	_init_reverse_lookup()
	return _string_states.get(state_string.to_upper(), ASSET.UNKNOWN)

################################################################################
#                              UPDATE_TYPE ENUM                                #
################################################################################

const _STATE: String = "State"
const _TOGGLE: String = "Toggle"
const _POSITION: String = "Position"
const _SCALE: String = "Scale"
const _ROTATION: String = "Rotation"
const _FOCUS: String = "Focus"

enum UPDATE_TYPE {
	STATE,
	TOGGLE,
	POSITION,
	SCALE,
	ROTATION,
	FOCUS,
	UNKNOWN
}

static func get_update_type_string(incoming_type: UPDATE_TYPE) -> String:
	match incoming_type:
		UPDATE_TYPE.STATE:
			return _STATE
		UPDATE_TYPE.TOGGLE:
			return _TOGGLE
		UPDATE_TYPE.POSITION:
			return _POSITION
		UPDATE_TYPE.SCALE:
			return _SCALE
		UPDATE_TYPE.ROTATION:
			return _ROTATION
		UPDATE_TYPE.FOCUS:
			return _FOCUS
		_:
			return GroupData.UNKNOWN

static func get_update_type_from_string(incoming_string: String) -> UPDATE_TYPE:
	match incoming_string:
		_STATE:
			return UPDATE_TYPE.STATE
		_TOGGLE:
			return UPDATE_TYPE.TOGGLE
		_POSITION:
			return UPDATE_TYPE.POSITION
		_SCALE:
			return UPDATE_TYPE.SCALE
		_ROTATION:
			return UPDATE_TYPE.ROTATION
		_FOCUS:
			return UPDATE_TYPE.FOCUS
		_:
			push_error("Unknown UPDATE_TYPE string: " + incoming_string)
			return UPDATE_TYPE.UNKNOWN

################################################################################
#                               DATA_TYPE ENUM                                 #
################################################################################

const _WARN_STRING: String = "State data for \"%s\" doesn't exist yet; If this is occuring anywhere except startup there is a problem..."
const _PLAYER: String = "Player"
const _ITEM: String = "Item"
const _CAMERA: String = "Camera"

enum DATA_TYPE {
	PLAYER,
	ITEM,
	CAMERA,
	UNKNOWN
}

static func get_data_type_string(incoming_type: STATE.DATA_TYPE) -> String:
	match incoming_type:
		STATE.DATA_TYPE.PLAYER:
			return _PLAYER
		STATE.DATA_TYPE.ITEM:
			return _ITEM
		STATE.DATA_TYPE.CAMERA:
			return _CAMERA
		_:
			return GroupData.UNKNOWN

static func get_data_type_from_string(incoming_string: String) -> STATE.DATA_TYPE:
	match incoming_string:
		_PLAYER:
			return STATE.DATA_TYPE.PLAYER
		_ITEM:
			return STATE.DATA_TYPE.ITEM
		_CAMERA:
			return STATE.DATA_TYPE.CAMERA
		_:
			push_error("Unknown DATA_TYPE string: " + incoming_string)
			return STATE.DATA_TYPE.UNKNOWN