class_name ItemStateConfig

var ready_window: float
var windup_undercooked_window: float
var windup_very_early_window: float
var windup_early_window: float
var windup_perfect_window: float
var windup_late_window: float
var windup_very_late_window: float
var windup_overcooked_window: float
var throwing_under_window: float
var throwing_perfect_window: float
var throwing_over_window: float
var follow_thru_under_window: float
var follow_thru_perfect_widow: float
var follow_thru_over_window:float



func _init(
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
	self.ready_window = p_ready_window
	self.windup_undercooked_window = p_windup_undercooked_window
	self.windup_very_early_window = p_windup_very_early_window
	self.windup_early_window = p_windup_early_window
	self.windup_perfect_window = p_windup_perfect_window
	self.windup_late_window = p_windup_late_window
	self.windup_very_late_window = p_windup_very_late_window
	self.windup_overcooked_window = p_windup_overcooked_window
	self.throwing_under_window = p_throwing_under_window
	self.throwing_perfect_window = p_throwing_perfect_window
	self.throwing_over_window = p_throwing_over_window
	self.follow_thru_under_window = p_follow_thru_under_window
	self.follow_thru_perfect_widow = p_follow_thru_perfect_widow
	self.follow_thru_over_window = p_follow_thru_over_window

func is_valid_state() -> bool:
	var windows = [
		ready_window,
		windup_undercooked_window,
		windup_very_early_window,
		windup_early_window,
		windup_perfect_window,
		windup_late_window,
		windup_very_late_window,
		windup_overcooked_window,
		throwing_under_window,
		throwing_perfect_window,
		throwing_over_window,
		follow_thru_under_window,
		follow_thru_perfect_widow,
		follow_thru_over_window
	]
	var valid_windows = []
	for window in windows:
		if window != NUMBERS.FLOAT16_MAX:
			valid_windows.append(window)
	for i in range(valid_windows.size() - 1):
		if valid_windows[i] > valid_windows[i + 1]:
			return false
	return true