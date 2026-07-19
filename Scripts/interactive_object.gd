extends Node2D
@onready var target_object : Node2D = $".."
@onready var object_sprite : Node2D = $"../Sprite2D"
@onready var detection_area_2d: Area2D = $"../detectionArea2D"
@onready var notif_marker_2d: Marker2D = $NotifMarker2D
@onready var interaction_area_2d: Area2D = $InteractionArea2D

enum InteractionTypes {NORMAL, HIDDEN, SECRET}
@export var interaction_type: InteractionTypes

var q_mark: Node2D
var i_circle: Node2D
var light_below_object: bool = true
var base_light_mask: int

signal object_found(target_object: Node2D, object_detected: bool)
signal i_circle_entered(target_object: Node2D, interactabool: bool)

func _set_interactions() -> void:
	match interaction_type:
		InteractionTypes.NORMAL:
			detection_area_2d.set_collision_mask_value(9, true)
			detection_area_2d.monitoring = true
			base_light_mask = 1+2+4
		InteractionTypes.HIDDEN:
			detection_area_2d.set_collision_mask_value(10, true)
			detection_area_2d.monitoring = false
			base_light_mask = 2
		InteractionTypes.SECRET:
			detection_area_2d.set_collision_mask_value(11, true)
			detection_area_2d.monitoring = false
			base_light_mask = 4
	object_sprite.light_mask = base_light_mask
	
func _ready() -> void:
	_set_interactions()
	GameManager.light_position_sent.connect(_on_light_position_received)
	GameManager.objects_revealed.connect(_on_objects_revealed)
	detection_area_2d.area_entered.connect(_on_detection_area_2d_area_entered)
	detection_area_2d.area_exited.connect(_on_detection_area_2d_area_exited)
	
	
func _on_detection_area_2d_area_entered(_area: Area2D) -> void:
	object_found.emit(target_object, true)
	#print_debug (target_object," found by ", area)
	
func _on_detection_area_2d_area_exited(_area: Area2D) -> void:
	object_found.emit(target_object, false)
	#print_debug (target_object," lost")

func _on_objects_revealed(light_type: InteractionTypes, revealed: bool):
	
	if light_type == InteractionTypes.HIDDEN:
		if interaction_type == InteractionTypes.HIDDEN:
			detection_area_2d.monitoring = revealed
	if light_type == InteractionTypes.SECRET:
		print_debug(light_type," ", revealed)
		#if interaction_type == InteractionTypes.SECRET:
		detection_area_2d.monitoring = revealed
			
func _object_notify(activated: bool):
	interaction_area_2d.monitoring = activated
	if activated == true:
		if not has_node("QuestionMark"):
			q_mark = Global1.q_mark_scene.instantiate()
			add_child(q_mark)
			q_mark.position = notif_marker_2d.position
		elif has_node("QuestionMark"):
			q_mark._notif_handling("entering", "question_mark")
	elif activated == false:
		if has_node("QuestionMark"):
			q_mark._notif_handling("exiting", "question_mark")
		elif not has_node("QuestionMark"):
			pass
			
	if activated == true:
		if not has_node("InteractCircle"):
			i_circle = Global1.i_circle_scene.instantiate()
			add_child(i_circle)
			i_circle.position = interaction_area_2d.position
		elif has_node("InteractCircle"):
			i_circle._notif_handling("entering", "interact_circle")
	elif activated == false:
		if has_node("InteractCircle"):
			i_circle._notif_handling("exiting", "interact_circle")
		elif not has_node("InteractCircle"):
			pass
		

func _on_interaction_area_2d_area_entered(_area: Area2D) -> void:
	i_circle_entered.emit(target_object, true)
	#print_debug("i_circle_entered", target_object)
	
func _on_interaction_area_2d_area_exited(_area: Area2D) -> void:
	i_circle_entered.emit(target_object, false)
	#print_debug("i_circle_exited", target_object)
	

func _on_light_position_received(light_pos: Vector2):
	light_below_object = (light_pos.y - position.y) > 0
	#if not light_below_object:
	#match interaction_type:
		#InteractionTypes.NORMAL:
			#pass
			##detection_area_2d.set_collision_mask_value(9, true)
			##detection_area_2d.monitoring = true
			##base_light_mask = 
		#InteractionTypes.HIDDEN:
			#detection_area_2d.set_collision_mask_value(10, light_below_object)
			#detection_area_2d.monitoring = light_below_object
			##base_light_mask = 
		#InteractionTypes.SECRET:
			#detection_area_2d.set_collision_mask_value(11, light_below_object)
			#detection_area_2d.monitoring = light_below_object
	pass
