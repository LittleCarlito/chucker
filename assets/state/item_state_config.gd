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

var current_state: ItemState.STATE

func _init(
			incoming_state: ItemState.STATE = 0,
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

# TODO Implement structure to make it finite state machine
#			Reconfigure variables to be an Array[float]
#			Only can increase/decrease states via calls
#				Have the get next valid state search the array for the next non NumbersFloatMax window value
#				Have get next state search the array for next value regardless of window set for it
#				Make get last valid and normal functions as well
#				Make a reset state function
#					Resets to 0 value state (right now that means READY; But we will treat it as 0 in code)
#				Make is state function
#				Make find state function
#					Takes in a state and gives out a - 0 + value for how far that status is from the current

func reset_state() -> void:
	self.current_state = 0

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