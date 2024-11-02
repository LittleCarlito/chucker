extends Node3D

@onready var scorecard: ScorecardView = $ScorecardView
@onready var pauseMenu: PauseMenu = $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scorecard.set_pixel_size(GLOBAL_SETTINGS.MENU.SCORECARD.PLAYER_PIXEL_SIZE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO Make sure this handles scorecard stuff proper
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(USER_INPUT.MENU.MAIN):
		pauseMenu.visible = true
		get_tree().paused = true
		set_process_input(false)
	if event.is_action_pressed(USER_INPUT.MENU.SCORE):
		get_tree().paused = true
		scorecard.scorecardSprite.visible = true
		get_viewport().get_camera_3d().look_at(scorecard.scorecardSprite.global_position)
	if event.is_action_released(USER_INPUT.MENU.SCORE):
		get_tree().paused = false
		scorecard.scorecardSprite.visible = false
		get_viewport().get_camera_3d().rotation = Vector3.ZERO

func _close_menu() -> void:
	pauseMenu.visible = false
	get_tree().paused = false
	set_process_input(true)
