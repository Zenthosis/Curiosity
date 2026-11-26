extends Camera2D

@onready var main_cam: Camera2D = $"../Environment/Boy/MainCam"
@onready var object_cam: Camera2D = $"../ObjectCam"
@onready var transition_cam: Camera2D = $"."
@onready var curr_cam: Camera2D = object_cam
@export var target_object: Node2D

var TransTween: Tween
var ZoomTween: Tween
var OffsetTween: Tween
var TweenType = Tween.TRANS_SINE
enum CamStatus {STARTED, ENDED}
	
signal cam_transitioned(status: CamStatus)
 
func _ready() -> void:
	object_cam.global_position = Vector2(-480,-80)
	pass # Replace with function body.
	
func switch_camera_instant(target_cam: Camera2D):
	target_cam.make_current()
	
	
func switch_camera(target_pos: Vector2, switch_duration: float):
	print("Current cam: ", curr_cam)
	transition_cam.global_transform = curr_cam.global_transform
	transition_cam.zoom = curr_cam.zoom
	transition_cam.offset = curr_cam.offset
	if main_cam.is_current():
		if target_object != null:
			object_cam.global_position = target_object.global_position
		else:
			object_cam.global_position = target_pos
		curr_cam = object_cam
	else:
		curr_cam = main_cam
	print("Switching to: ", curr_cam)
	#print(curr_cam)
	cam_transitioned.emit(CamStatus.STARTED)
	transition_cam.make_current()
	if TransTween:
		TransTween.kill()
	TransTween = create_tween()
	var target_transform: Transform2D = curr_cam.global_transform
	TransTween.tween_property(transition_cam, "global_transform", target_transform, switch_duration).set_trans(TweenType)
	
	if ZoomTween:
		ZoomTween.kill()
	ZoomTween = create_tween()
	var target_zoom: Vector2 = curr_cam.zoom
	ZoomTween.tween_property(transition_cam, "zoom", target_zoom, switch_duration).set_trans(TweenType)

	if OffsetTween:
		OffsetTween.kill()
	OffsetTween = create_tween()
	var target_offset: Vector2 = curr_cam.offset
	OffsetTween.tween_property(transition_cam, "offset", target_offset, switch_duration).set_trans(TweenType)
	
	await TransTween.finished
	cam_transitioned.emit(CamStatus.ENDED)
	if curr_cam == main_cam:
		main_cam.make_current()
	else:
		object_cam.make_current()
	
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
