extends Node3D

@onready var chuckTee: ChuckTee = $ChuckTee
@onready var chuckChucker: ChuckChucker = $ChuckChucker
var chuckCamera: Camera3D
var teeOneCamera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chuckCamera = chuckChucker.get_camera()
	teeOneCamera = chuckTee.get_camera()
	teeOneCamera.current = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self._handle_menu()

# TODO This should be in the Teebox object
# TODO Disable chucks movement/rotations when scorecard is held
func _handle_menu() -> void:
	if Input.is_action_pressed(USER_INPUT.MENU.SCORE):
		teeOneCamera.current = false
		chuckCamera.rotation = Vector3.ZERO
		chuckCamera.current = true
	if Input.is_action_just_released(USER_INPUT.MENU.SCORE):
		teeOneCamera.current = true
		chuckCamera.current = false
