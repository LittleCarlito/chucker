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
	MAXIMUM,
	UNKNOWN
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

const ICON_SCALE_MATRIX: Dictionary = {
	DisplaySize.SIZE.TEENY: .04,
	DisplaySize.SIZE.EXTRA_EXTRA_SMALL: .1,
	DisplaySize.SIZE.EXTRA_SMALL: .16,
	DisplaySize.SIZE.SMALL: .2,
	DisplaySize.SIZE.MEDIUM_SMALL: .26,
	DisplaySize.SIZE.MEDIUM: .32,
	DisplaySize.SIZE.MEDIUM_LARGE: .38,
	DisplaySize.SIZE.LARGE: .44,
	DisplaySize.SIZE.EXTRA_LARGE: .50,
	DisplaySize.SIZE.EXTRA_EXTRA_LARGE: .56,
	DisplaySize.SIZE.HUGE: .62,
	DisplaySize.SIZE.MAXIMUM: .68
}

const MENU_SCALE_MATRIX: Dictionary = {
	DisplaySize.SIZE.TEENY: 1,
	DisplaySize.SIZE.EXTRA_EXTRA_SMALL: 1,
	DisplaySize.SIZE.EXTRA_SMALL: 1,
	DisplaySize.SIZE.SMALL: 2,
	DisplaySize.SIZE.MEDIUM_SMALL: 2,
	DisplaySize.SIZE.MEDIUM: 2,
	DisplaySize.SIZE.MEDIUM_LARGE: 3,
	DisplaySize.SIZE.LARGE: 3,
	DisplaySize.SIZE.EXTRA_LARGE: 3,
	DisplaySize.SIZE.EXTRA_EXTRA_LARGE: 4,
	DisplaySize.SIZE.HUGE: 4,
	DisplaySize.SIZE.MAXIMUM: 4
}

## Determines associated SIZE from given screen_resolution
static func determine_display_size(screen_resolution: Vector2i) -> DisplaySize.SIZE:
	var display_size: DisplaySize.SIZE
	var window_width: int = screen_resolution.x
	var window_height: int = screen_resolution.y
	if window_width < TEENY.x:
		display_size = DisplaySize.SIZE.TEENY
	elif window_width < EXTRA_EXTRA_SMALL.x:
		display_size = DisplaySize.SIZE.EXTRA_EXTRA_SMALL
	elif window_width < EXTRA_SMALL.x:
		if window_height > EXTRA_EXTRA_SMALL.y:
			display_size = DisplaySize.SIZE.EXTRA_SMALL
		else:
			display_size = DisplaySize.SIZE.EXTRA_EXTRA_SMALL
	elif window_width < SMALL.x:
		if window_height > EXTRA_SMALL.y:
			display_size = DisplaySize.SIZE.SMALL
		else:
			display_size = DisplaySize.SIZE.EXTRA_SMALL
	elif window_width < MEDIUM_SMALL.x:
		if window_height > SMALL.y:
			display_size = DisplaySize.SIZE.MEDIUM_SMALL
		else:
			display_size = DisplaySize.SIZE.SMALL
	elif window_width < MEDIUM.x:
		if window_height > MEDIUM_SMALL.y:
			display_size = DisplaySize.SIZE.MEDIUM
		else:
			display_size = DisplaySize.SIZE.MEDIUM_SMALL
	elif window_width < MEDIUM_LARGE.x:
		if window_height > MEDIUM.y:
			display_size = DisplaySize.SIZE.MEDIUM_LARGE
		else:
			display_size = DisplaySize.SIZE.MEDIUM
	elif window_width < LARGE.x:
		if window_height > MEDIUM_LARGE.y:
			display_size = DisplaySize.SIZE.LARGE
		else:
			display_size = DisplaySize.SIZE.MEDIUM_LARGE
	elif window_width < EXTRA_LARGE.x:
		if window_height > LARGE.y:
			display_size = DisplaySize.SIZE.EXTRA_LARGE
		else:
			display_size = DisplaySize.SIZE.LARGE
	elif window_width < EXTRA_EXTRA_LARGE.x:
		if window_height > EXTRA_LARGE.y:
			display_size = DisplaySize.SIZE.EXTRA_EXTRA_LARGE
		else:
			display_size = DisplaySize.SIZE.EXTRA_LARGE
	elif window_width < HUGE.x:
		if window_height > EXTRA_EXTRA_LARGE.y:
			display_size = DisplaySize.SIZE.HUGE
		else:
			display_size = DisplaySize.SIZE.EXTRA_EXTRA_LARGE
	elif window_width < MAXIMUM.x:
		if window_height > HUGE.y:
			display_size = DisplaySize.SIZE.MAXIMUM
		else:
			display_size = DisplaySize.SIZE.HUGE
	return display_size
