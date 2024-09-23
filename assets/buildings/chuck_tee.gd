extends StaticBody3D
class_name ChuckTee

@onready var teeCamera: Camera3D = $CameraController/CameraTarget/TeeboxCamera
@onready var scorecard: ScorecardView = $ScorecardView

const _CURRENT_CAMERA_LOG: String = "Current camera is %s"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scorecard.set_pixel_size(GLOBAL_SETTINGS.MENU.SCORECARD.TEEBOX_PIXEL_SIZE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self._handle_menus()

func _handle_menus() -> void:
	if teeCamera.current:
		if Input.is_action_pressed(USER_INPUT.MENU.SCORE):
			scorecard.scorecardSprite.visible = true
			get_viewport().get_camera_3d().look_at(scorecard.scorecardSprite.global_position)
		if Input.is_action_just_released(USER_INPUT.MENU.SCORE):
			scorecard.scorecardSprite.visible = false
			get_viewport().get_camera_3d().rotation = Vector3.ZERO

func _on_tee_box_area_body_entered(body: Node3D) -> void:
	if body is ChuckChucker:
		var bodyCamera: Camera3D = body.get_camera()
		bodyCamera.current = false
		teeCamera.current = true
		if(get_viewport().get_camera_3d() != null):
			var formatString: String = _CURRENT_CAMERA_LOG
			Logger.debug(formatString, [get_viewport().get_camera_3d().name], self)

func _on_tee_box_area_body_exited(body: Node3D) -> void:
	if body is ChuckChucker:
		scorecard.scorecardSprite.visible = false
		var bodyCamera: Camera3D = body.get_camera()
		bodyCamera.current = true
		teeCamera.current = false
		if(get_viewport().get_camera_3d() != null):
			var formatString: String = _CURRENT_CAMERA_LOG
			Logger.debug(formatString, [get_viewport().get_camera_3d().name], self)

func get_camera() -> Camera3D:
	return $CameraController/CameraTarget/TeeboxCamera
