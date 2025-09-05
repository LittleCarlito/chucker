extends Node

# TODO Centralized cursor control hub
#	- All code should call this; nowhere else should call Input.set_mouse_mode
#	- Requests persist until cleared (or until the object is freed)
#	- Requests made during frame N are resolved at the START of frame N+1 (batching)
#	- Only call Input.set_mouse_mode when effective state actually changes
#	- Log detailed diagnostics for conflicts (who asked, what they wanted, who won)
#	- Expose small API: request_state, request_visible/captured/confined/hidden, clear_request, clear_all

signal state_changed(old_state: int, new_state: int, deciders: Array)

enum CursorState {
	VISIBLE,
	CAPTURED,
	CONFINED,
	HIDDEN,
}

# Highest precedence first. Reorder to change priority.
const RESOLUTION_ORDER: Array = [
	CursorState.VISIBLE,
	CursorState.CAPTURED,
	CursorState.CONFINED,
	CursorState.HIDDEN,
]

@export var default_state: CursorState = CursorState.VISIBLE
@export var debug_enabled: bool = true
# Map[int(instance_id) -> Dictionary{
#	"weak": WeakRef,
#	"state": CursorState,
#	"reason": String,
#	"frame_added": int
# }]
var _frame_requests: Dictionary = {}
var _current_state: CursorState = CursorState.VISIBLE
# Frame-batching helpers:
# Requests made in frame N set _dirty_this_frame = true.
# At end of every frame we copy _dirty_last_frame = _dirty_this_frame.
# At the START of each frame we resolve only if _dirty_last_frame was true
# (this ensures "requests during frame N" are collected and applied at start of N+1).
var _dirty_this_frame: bool = false
var _dirty_last_frame: bool = false
var _frame_index: int = 0

func _ready() -> void:
	set_process(true)
	_apply_state(default_state, "initialization", [])

func _process(_delta: float) -> void:
	# START of frame: increment frame index, then resolve if last frame had requests
	_frame_index += 1
	if _dirty_last_frame:
		_resolve_and_apply()
	# END of frame: shift dirty flags so requests made this frame are resolved next frame
	_dirty_last_frame = _dirty_this_frame
	_dirty_this_frame = false

# Generic request method
func request_state(requester: Object, state: CursorState, reason: String = "") -> void:
	# Defensive: ignore null.
	if requester == null:
		return
	var id := requester.get_instance_id()
	_frame_requests[id] = {
		"weak": weakref(requester),
		"state": state,
		"reason": reason,
		"frame_added": _frame_index
	}
	# Mark dirty for batching (will be handled at next frame start)
	_dirty_this_frame = true

# Convenience helpers
func request_visible(requester: Object, reason: String = "") -> void:
	request_state(requester, CursorState.VISIBLE, reason)

func request_captured(requester: Object, reason: String = "") -> void:
	request_state(requester, CursorState.CAPTURED, reason)

func request_confined(requester: Object, reason: String = "") -> void:
	request_state(requester, CursorState.CONFINED, reason)

func request_hidden(requester: Object, reason: String = "") -> void:
	request_state(requester, CursorState.HIDDEN, reason)

# Remove a caller's request (manual cleanup)
func clear_request(requester: Object) -> void:
	if requester == null:
		return
	_frame_requests.erase(requester.get_instance_id())
	_dirty_this_frame = true

# Remove all requests (scene changes, resets)
func clear_all() -> void:
	_frame_requests.clear()
	_dirty_this_frame = true

# Query current applied state (what OS currently has)
func get_current_state() -> CursorState:
	return _current_state

# State checking functions
func is_visible_current() -> bool:
	return _current_state == CursorState.VISIBLE

func is_captured_current() -> bool:
	return _current_state == CursorState.CAPTURED

func is_confined_current() -> bool:
	return _current_state == CursorState.CONFINED

func is_hidden_current() -> bool:
	return _current_state == CursorState.HIDDEN

# Get a list of active request descriptions (helpful for debugging)
func get_all_requests() -> Array:
	var arr := []
	for id in _frame_requests.keys():
		var req = _frame_requests[id]
		var desc = _format_req_desc(req)
		arr.append(desc)
	return arr

# Get who is requesting a specific state
func get_effective_requesters(state: CursorState) -> Array:
	var arr := []
	for id in _frame_requests.keys():
		var req = _frame_requests[id]
		if req.state == state and req.weak.get_ref() != null:
			arr.append(req.weak.get_ref())
	return arr

func _resolve_and_apply() -> void:
	var alive_requests: Array = []
	for id in _frame_requests.keys():
		var req: Dictionary = _frame_requests[id]
		var w: WeakRef = req["weak"]
		if w.get_ref() != null:
			alive_requests.append(req)
		else:
			# The requester was freed — drop their vote
			_frame_requests.erase(id)
	# No active requests -> apply default (but only if different)
	if alive_requests.is_empty():
		if _current_state != default_state:
			_apply_state(default_state, "fallback(default_state)", [])
		return
	# Find highest-precedence state that has at least one requester
	var decided_state: CursorState = default_state
	var deciders: Array = []
	for state in RESOLUTION_ORDER:
		deciders.clear()
		for req in alive_requests:
			if req.state == state:
				deciders.append(req)
		if not deciders.is_empty():
			decided_state = state
			break
	# Logging about conflicts (before applying) — do this even if state won't change so you have record
	if debug_enabled:
		_log_conflicts(alive_requests, decided_state, deciders)
	# Only apply when it actually changes to avoid spam
	if decided_state != _current_state:
		_apply_state(decided_state, _first_decider_name(deciders), deciders)
	_frame_requests.clear()

# Apply OS mouse mode and emit signal
func _apply_state(state: CursorState, decided_by: String, deciders: Array) -> void:
	var old_state := _current_state
	_current_state = state
	match state:
		CursorState.VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		CursorState.CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		CursorState.CONFINED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		CursorState.HIDDEN:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		_:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if debug_enabled:
		Logger.debug(
			"GlobalCursorController: applied %s (was %s) — decided_by=%s frame=%d",
			[ _state_name(state), _state_name(old_state), decided_by, _frame_index ],
			self
		)
	emit_signal("state_changed", old_state, state, deciders)

func _log_conflicts(all_reqs: Array, decided_state: CursorState, deciders: Array) -> void:
	# Build winners list
	var winners := []
	for r in deciders:
		winners.append(_format_req_desc(r))
	# For every request that lost, emit a debug line
	for r in all_reqs:
		if r.state != decided_state:
			Logger.debug(
				"GlobalCursorController: NOT fulfilled — %s asked for %s, but %s was set (overruled by %s)",
				[
					_format_req_desc(r),
					_state_name(r.state),
					_state_name(decided_state),
					_first_decider_name(deciders)
				],
				self
			)
	# Summary
	Logger.debug(
		"GlobalCursorController: frame %d summary — decided=%s; winners=%s; total_requests=%d",
		[ _frame_index, _state_name(decided_state), ", ".join(winners), all_reqs.size() ],
		self
	)

func _format_req_desc(req: Dictionary) -> String:
	var w: WeakRef = req["weak"]
	var who: Object = w.get_ref()
	var name: String = "unknown"
	if who != null:
		# Prefer to_string() so it prints something meaningful for nodes
		name = str(who)
	var reason: String = req.get("reason", "")
	var f: int = req.get("frame_added", -1)
	if reason == "":
		return "%s@frame%d" % [name, f]
	return "%s@frame%d(reason=%s)" % [name, f, reason]

func _first_decider_name(deciders: Array) -> String:
	if deciders.is_empty():
		return "none"
	return _format_req_desc(deciders[0])

func _state_name(s: CursorState) -> String:
	match s:
		CursorState.VISIBLE: return "VISIBLE"
		CursorState.CAPTURED: return "CAPTURED"
		CursorState.CONFINED: return "CONFINED"
		CursorState.HIDDEN: return "HIDDEN"
		_: return "UNKNOWN"
