extends Node
class_name DefaultLibrary

# TODO Get Controls into here
## Stores references to each config types default dictionary for automated searches
const DEFAULTS: Dictionary = {
	CameraConfig.NAME: CameraConfig.DEFAULTS,
	DisplayConfig.NAME: DisplayConfig.DEFAULTS,
	DebugConfig.NAME: DebugConfig.DEFAULTS,
	ApplicationConfig.NAME: ApplicationConfig.DEFAULTS
}
