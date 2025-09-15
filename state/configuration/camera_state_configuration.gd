class_name CameraStateConfiguration

const VALID_TRANSITIONS: Dictionary = {
	StateConfiguration.STATE.READY: 			[
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.IS_TRACKING: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.FULL_TRACKING: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.POS_TRACKING: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],	
	StateConfiguration.STATE.FREE_TRACKING: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.IDLE_ROTATE: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.IS_FREELOOK: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.FREELOOK_MOVE,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.FREELOOK_MOVE: 	[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.DISABLED
	],
	StateConfiguration.STATE.DISABLED: 		[
				StateConfiguration.STATE.READY,
				StateConfiguration.STATE.IS_TRACKING,
				StateConfiguration.STATE.FULL_TRACKING,
				StateConfiguration.STATE.POS_TRACKING,
				StateConfiguration.STATE.FREE_TRACKING,
				StateConfiguration.STATE.IDLE_ROTATE,
				StateConfiguration.STATE.IS_FREELOOK,
				StateConfiguration.STATE.FREELOOK_MOVE
	]
}

const SPIN_VALUES: Dictionary = {
	StateConfiguration.STATE.IDLE_ROTATE: CameraConfig.DEFAULTS.IDLE_ROTATE_SPEED
}
