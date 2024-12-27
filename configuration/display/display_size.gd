extends Object
class_name DisplaySize

const DISPLAY_OVERRIDE: String = "display_override"
const MINIUMUM: Vector2i = Vector2i(870, 570)
const TEENY: Vector2i = Vector2i(1438, 883)
const EXTRA_EXTRA_SMALL: Vector2i = Vector2i(2006, 1196)
const EXTRA_SMALL: Vector2i = Vector2i(2574, 1509)
const SMALL: Vector2i = Vector2i(3142, 1822)
const MEDIUM_SMALL: Vector2i = Vector2i(3710, 2135)
const MEDIUM: Vector2i = Vector2i(4278, 2448)
const MEDIUM_LARGE: Vector2i = Vector2i(4846, 2761)
const LARGE: Vector2i = Vector2i(5414, 3074)
const EXTRA_LARGE: Vector2i = Vector2i(5982, 3387)
const EXTRA_EXTRA_LARGE: Vector2i = Vector2i(6550, 3700)
const HUGE: Vector2i = Vector2i(7118, 4013)
const MAXIMUM: Vector2i = Vector2i(7686, 4326)

enum SIZE {
	MINIMUM,
	TEENY,
	EXTRA_EXTRA_SMALL,
	EXTRA_SMALL,
	SMALL,
	MEDIUM_SMALL,
	MEDIUM,
	MEDIUM_LARGE,
	LARGE,
	EXTRA_LARGE,
	EXTRA_EXTRA_LARGE,
	HUGE,
	MAXIMUM
}

const FONT_MATRIX: Dictionary = {
	DisplaySize.SIZE.TEENY: 12,
	DisplaySize.SIZE.EXTRA_EXTRA_SMALL: 18,
	DisplaySize.SIZE.EXTRA_SMALL: 24,
	DisplaySize.SIZE.SMALL: 30,
	DisplaySize.SIZE.MEDIUM_SMALL: 36,
	DisplaySize.SIZE.MEDIUM: 42,
	DisplaySize.SIZE.MEDIUM_LARGE: 48,
	DisplaySize.SIZE.LARGE: 54,
	DisplaySize.SIZE.EXTRA_LARGE: 60,
	DisplaySize.SIZE.EXTRA_EXTRA_LARGE: 66,
	DisplaySize.SIZE.HUGE: 72,
	DisplaySize.SIZE.MAXIMUM: 78
}

## Determines associated SIZE from given screen_resolution
static func determine_display_size(screen_resolution: Vector2i) -> DisplaySize.SIZE:
	var display_size: DisplaySize.SIZE
	var window_width: int = screen_resolution.x
	if window_width < TEENY.x:
		display_size = DisplaySize.SIZE.TEENY
	elif window_width < EXTRA_EXTRA_SMALL.x:
		display_size = DisplaySize.SIZE.EXTRA_EXTRA_SMALL
	elif window_width < EXTRA_SMALL.x:
		display_size = DisplaySize.SIZE.EXTRA_SMALL
	elif window_width < SMALL.x:
		display_size = DisplaySize.SIZE.SMALL
	elif window_width < MEDIUM_SMALL.x:
		display_size = DisplaySize.SIZE.MEDIUM_SMALL
	elif window_width < MEDIUM.x:
		display_size = DisplaySize.SIZE.MEDIUM
	elif window_width < MEDIUM_LARGE.x:
		display_size = DisplaySize.SIZE.MEDIUM_LARGE
	elif window_width < LARGE.x:
		display_size = DisplaySize.SIZE.LARGE
	elif window_width < EXTRA_LARGE.x:
		display_size = DisplaySize.SIZE.EXTRA_LARGE
	elif window_width < EXTRA_EXTRA_LARGE.x:
		display_size = DisplaySize.SIZE.EXTRA_EXTRA_LARGE
	elif window_width < HUGE.x:
		display_size = DisplaySize.SIZE.HUGE
	else:
		display_size = DisplaySize.SIZE.MAXIMUM
	return display_size
