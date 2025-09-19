class_name CameraStateConfiguration

const VALID_TRANSITIONS: Dictionary = {
	StateConfiguration.STATE.READY: 			[
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.IS_TRACKING: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.TRACKING_FULL: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.TRACKING_POS: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],	
	StateConfiguration.STATE.TRACKING_FREE: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.IDLE_ROTATE: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.IS_FREELOOK: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.FREELOOK_MOVE: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.DISABLED: 		[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.TRACKING_FULL,
				StateConfiguration.STATE.TRACKING_POS,
				StateConfiguration.STATE.TRACKING_FREE,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE
	]
}

const SPIN_VALUES: Dictionary = {
	StateConfiguration.STATE.IDLE_ROTATE: CameraConfig.DEFAULTS.IDLE_ROTATE_SPEED
}
