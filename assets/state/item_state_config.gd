class_name ItemStateConfig

var current_state: ItemState.STATE
var windows: Array[float] = []

func _init(
				incoming_state: ItemState.STATE = ItemState.STATE.READY,
				p_ready_window: float = NUMBERS.FLOAT16_MAX,
				p_windup_undercooked_window: float = NUMBERS.FLOAT16_MAX,
				p_windup_very_early_window: float = NUMBERS.FLOAT16_MAX,
				p_windup_early_window: float = NUMBERS.FLOAT16_MAX,
				p_windup_perfect_window: float = NUMBERS.FLOAT16_MAX,
				p_windup_late_window: float = NUMBERS.FLOAT16_MAX,
				p_windup_very_late_window: float = NUMBERS.FLOAT16_MAX,
				p_windup_overcooked_window: float = NUMBERS.FLOAT16_MAX,
				p_throwing_under_window: float = NUMBERS.FLOAT16_MAX,
				p_throwing_perfect_window: float = NUMBERS.FLOAT16_MAX,
				p_throwing_over_window: float = NUMBERS.FLOAT16_MAX,
				p_follow_thru_under_window: float = NUMBERS.FLOAT16_MAX,
				p_follow_thru_perfect_widow: float = NUMBERS.FLOAT16_MAX,
				p_follow_thru_over_window: float = NUMBERS.FLOAT16_MAX
			):
	self.current_state = incoming_state
	var max_state = ItemState.STATE.FOLLOW_THRU_OVER
	windows.resize(max_state + 1)
	windows[ItemState.STATE.READY] = p_ready_window
	windows[ItemState.STATE.WINDUP_UNDERCOOKED] = p_windup_undercooked_window
	windows[ItemState.STATE.WINDUP_VERY_EARLY] = p_windup_very_early_window
	windows[ItemState.STATE.WINDUP_EARLY] = p_windup_early_window
	windows[ItemState.STATE.WINDUP_PERFECT] = p_windup_perfect_window
	windows[ItemState.STATE.WINDUP_LATE] = p_windup_late_window
	windows[ItemState.STATE.WINDUP_VERY_LATE] = p_windup_very_late_window
	windows[ItemState.STATE.WINDUP_OVERCOOKED] = p_windup_overcooked_window
	windows[ItemState.STATE.THROWING_UNDER] = p_throwing_under_window
	windows[ItemState.STATE.THROWING_PERFECT] = p_throwing_perfect_window
	windows[ItemState.STATE.THROWING_OVER] = p_throwing_over_window
	windows[ItemState.STATE.FOLLOW_THRU_UNDER] = p_follow_thru_under_window
	windows[ItemState.STATE.FOLLOW_THRU_PERFECT] = p_follow_thru_perfect_widow
	windows[ItemState.STATE.FOLLOW_THRU_OVER] = p_follow_thru_over_window
	if not is_state_configuration_valid():
		push_error("ItemStateConfig state window values must be sequential and increasing.")

func _is_valid_state(state: int) -> bool:
	if state < 0 or state >= windows.size(): return false
	return windows[state] != NUMBERS.FLOAT16_MAX

func _get_next_state(from_state: int, only_valid: bool) -> int:
	for s in range(from_state + 1, windows.size()):
		if not only_valid or _is_valid_state(s): return s
	return from_state

func _get_previous_state(from_state: int, only_valid: bool) -> int:
	for s in range(from_state - 1, -1, -1):
		if not only_valid or _is_valid_state(s): return s
	return from_state

func can_transition(to_state: ItemState.STATE) -> bool:
	if not ItemState.VALID_TRANSITIONS.has(self.current_state): return false
	return to_state in ItemState.VALID_TRANSITIONS[self.current_state]

func try_set_state(to_state: ItemState.STATE) -> bool:
	if can_transition(to_state):
		self.current_state = to_state
		return true
	return false

func peak_next_valid() -> ItemState.STATE: 
	return _get_next_state(self.current_state, true)

func peak_next_actual() -> ItemState.STATE: 
	return _get_next_state(self.current_state, false)

func set_next_valid() -> ItemState.STATE: 
	var candidate = _get_next_state(self.current_state, true)
	if try_set_state(candidate): return self.current_state
	return self.current_state

func set_next_actual() -> ItemState.STATE: 
	var candidate = _get_next_state(self.current_state, false)
	if try_set_state(candidate): return self.current_state
	return self.current_state

func peak_previous_valid() -> ItemState.STATE: 
	return _get_previous_state(self.current_state, true)

func peak_previous_actual() -> ItemState.STATE: 
	return _get_previous_state(self.current_state, false)

func set_previous_valid() -> ItemState.STATE: 
	var candidate = _get_previous_state(self.current_state, true)
	if try_set_state(candidate): return self.current_state
	return self.current_state

func set_previous_actual() -> ItemState.STATE: 
	var candidate = _get_previous_state(self.current_state, false)
	if try_set_state(candidate): return self.current_state
	return self.current_state

func reset_state() -> void: 
	self.current_state = ItemState.STATE.READY

func get_valid_states() -> Array[ItemState.STATE]: 
	var result: Array[ItemState.STATE] = []
	for s in range(windows.size()):
		if _is_valid_state(s): 
			result.append(s)
	return result

func get_all_states() -> Array[ItemState.STATE]: 
	return range(windows.size())

func is_state(state: ItemState.STATE) -> bool: 
	return self.current_state == state

func find_state(target: ItemState.STATE) -> int: 
	return target - self.current_state

func is_state_configuration_valid() -> bool:
	var last_value: float = -INF
	for s in range(windows.size()):
		var w = windows[s]
		if w != NUMBERS.FLOAT16_MAX:
			if w < last_value: return false
			last_value = w
	return true
