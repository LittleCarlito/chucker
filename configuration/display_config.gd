extends Node
class_name DisplayConfig

# Display configs
const NAME: String = "display"
const UI_SCALE: String = "UI_Scale"
const WINDOW_BORDERLESS: String = "window_borderless"
const WINDOW_INITIAL_POSITION: String = "window_initial_position"
const WINDOW_INITIAL_SCREEN: String = "window_initial_screen"
const WINDOW_MODE: String = "Window_Mode"
# Properties
const _WINDOW_MODE_PROPERTY:String = "window/size/mode"
const _WINDOW_SCALE_PROPERTY: String = "window/stretch/scale"
const _WINDOW_BORDERLESS_PROPERTY: String = "window/size/borderless"
const _WINDOW_INITIAL_POSITION_PROPERTY: String = "window/size/initial_position_type" # 2 is centered on other screen; 1 is centered on Primary screen
const _WINDOW_INITIAL_SCREEN_PROPERTY: String = "window/size/initial_screen" # INTIIAL_POSITION MUST but 2 for this to work; Determines what screen window is on

const DEFAULTS: Dictionary = {
	UI_SCALE: 1.3,
	WINDOW_BORDERLESS: false,
	WINDOW_INITIAL_POSITION: 2,
	WINDOW_INITIAL_SCREEN: 0,
	WINDOW_MODE: 4,
}

const CONFIG_LIBRARY: Dictionary = {
		WINDOW_MODE: _WINDOW_MODE_PROPERTY,
		UI_SCALE: _WINDOW_SCALE_PROPERTY,
		WINDOW_BORDERLESS: _WINDOW_BORDERLESS_PROPERTY,
		WINDOW_INITIAL_POSITION: _WINDOW_INITIAL_POSITION_PROPERTY,
		WINDOW_INITIAL_SCREEN: _WINDOW_INITIAL_SCREEN_PROPERTY
}
