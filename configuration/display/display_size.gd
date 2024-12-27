extends Object
class_name DisplaySize

const DISPLAY_OVERRIDE: String = "display_override"
const MINIUMUM: Vector2i = Vector2i(870, 570)
const EXTRA_SMALL: Vector2i = Vector2i(1120, 735)
const SMALL: Vector2i = Vector2i(1370, 898)
const MEDIUM: Vector2i = Vector2i(1620, 1060)
const LARGE: Vector2i = Vector2i(1870, 1223)
const EXTRA_LARGE: Vector2i = Vector2i(2120, 1386)
const MAXIMUM: Vector2i = Vector2i(2370, 1549)

enum SIZE {
	MINIMUM,
	EXTRA_SMALL,
	SMALL,
	MEDIUM,
	LARGE,
	EXTRA_LARGE,
	MAXIMUM
}

# TODO Slowly increase step distance between each increase (linear is too fast)
const FONT_MATRIX: Dictionary = {
	DisplaySize.SIZE.MINIMUM: 16,
	DisplaySize.SIZE.EXTRA_SMALL: 23,
	DisplaySize.SIZE.SMALL: 30,
	DisplaySize.SIZE.MEDIUM: 37,
	DisplaySize.SIZE.LARGE: 44,
	DisplaySize.SIZE.EXTRA_LARGE: 51,
	DisplaySize.SIZE.MAXIMUM: 58
}

## Determines associated SIZE from given screen_resolution
static func determine_display_size(screen_resolution: Vector2i) -> DisplaySize.SIZE:
	var display_size: DisplaySize.SIZE
	var window_width: int = screen_resolution.x
	if window_width < MINIUMUM.x:
		display_size = DisplaySize.SIZE.MINIMUM
	elif window_width < EXTRA_SMALL.x:
		display_size = DisplaySize.SIZE.EXTRA_SMALL
	elif window_width < SMALL.x:
		display_size = DisplaySize.SIZE.SMALL
	elif window_width < MEDIUM.x:
		display_size = DisplaySize.SIZE.MEDIUM
	elif window_width < LARGE.x:
		display_size = DisplaySize.SIZE.LARGE
	elif window_width < LARGE.x:
		display_size = DisplaySize.SIZE.LARGE
	elif window_width < MAXIMUM.x:
		display_size = DisplaySize.SIZE.EXTRA_LARGE
	else:
		display_size = DisplaySize.SIZE.MAXIMUM
	return display_size
