extends Node
class_name DefaultLibrary

const PLACEHOLDER: String = "Placeholder"

## Stores references to each config types default dictionary for automated searches
const DEFAULTS: Dictionary = {
	CameraConfig.NAME: CameraConfig.DEFAULTS,
	DisplayConfig.NAME: DisplayConfig.DEFAULTS,
	DebugConfig.NAME: DebugConfig.DEFAULTS,
	ApplicationConfig.NAME: ApplicationConfig.DEFAULTS,
	InputConfig.NAME: InputConfig.DEFAULTS
}
