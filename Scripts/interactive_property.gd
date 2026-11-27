## This is a node added to any objects that are intended to be interacted with.
## It governs how lights interact with it (revealing + triggering interactions)
## It also sends signals to GameManager to let it know *which* interactive object it is dealing with
## It also spawns in the notifications (question mark, interaction circle) at the object's location once it's detected.

extends Node

@onready var target_object : Node2D = $".."
@onready var detection_area_2d: Area2D = $"../detectionArea2D"
@onready var notif_marker_2d: Marker2D = $NotifMarker2D
@onready var interaction_area_2d: Area2D = $InteractionArea2D

@export var light_type: Constants.LightTypes
@export var interact_type: Constants.InteractTypes
@export var repeat_type: Constants.RepeatTypes

var col_poly_2d: CollisionPolygon2D
var q_mark: Node2D
var i_circle: Node2D
var light_below_object: bool = true
var base_light_mask: int

signal object_found(target_object: Node2D, object_detected: bool)
signal i_circle_entered(target_object: Node2D, interactabool: bool, interact_type: Constants.InteractTypes)


## _set_light behaviour: Sets how different lights interact with and detact the object.
func _set_light_behaviour() -> void:
	## Player's detection radius is monitoring on collision layer 9. 
	## Additional light tools monitor on layer 10 and 11. They also have different item cull masks (1,2,3).
	## NORMAL: Visible without being lit by additional light. 
	## 			Detected on collision mask 9. Lit by all cull masks.
	## HIDDEN: Visible only under additional "normal" light sources i.e. flashlight and torches. 
	## 			Detected on collision mask 10. Lit by cull mask 2.
	## SECRET: Visible only under "secret-revealing light sources i.e. purple light. 
	## 			Detected on collision mask 11. Lit by cull mask 3.
	## SECRET_PHASE: Visible under ALL light, but under "secret-revaling" light, it will allow the player to "phase" through.
	## 			Detected on collision mask 11. Lit by all cull masks.
	match light_type:
		Constants.LightTypes.NORMAL:
			detection_area_2d.set_collision_mask_value(9, true)
			detection_area_2d.monitoring = true
			base_light_mask = 1+2+4
		Constants.LightTypes.HIDDEN:
			detection_area_2d.set_collision_mask_value(10, true)
			detection_area_2d.monitoring = false
			base_light_mask = 2
		Constants.LightTypes.SECRET:
			detection_area_2d.set_collision_mask_value(11, true)
			detection_area_2d.monitoring = false
			base_light_mask = 4
		Constants.LightTypes.SECRET_PHASE:
			detection_area_2d.set_collision_mask_value(11, true)
			detection_area_2d.monitoring = false
			base_light_mask = 1+2+4
	## Makes sure any Sprite2D children share the object's light_mask
	for child in target_object.get_children():
		if child is Sprite2D:
			child.light_mask = base_light_mask
	#print_debug(object_sprite.light_mask)

## _set_interactions: Sets the different interaction types based on the export variable, based on InteractTypes ENUM
func _set_interactions() -> void:
	match interact_type:
		Constants.InteractTypes.ITEM_PICKUP:
			pass
		Constants.InteractTypes.ITEM_USE:
			pass
		Constants.InteractTypes.DIALOGUE_ONLY:
			pass
		Constants.InteractTypes.REGION_TRIGGER: ## Intended to be one-shot
			interaction_area_2d.queue_free()
			notif_marker_2d.queue_free()
		Constants.InteractTypes.DIALOGUE_AND_CUTSCENE:
			pass

func _ready() -> void:
	_set_light_behaviour()
	_set_interactions()
	GameManager.objects_revealed.connect(_on_objects_revealed)
	detection_area_2d.area_entered.connect(_on_detection_area_2d_area_entered)
	detection_area_2d.area_exited.connect(_on_detection_area_2d_area_exited)
	## Only accesses the object's collision properties if it's a SECRET_PHASE InteractType
	if light_type == Constants.LightTypes.SECRET_PHASE:
		col_poly_2d = $"../CollisionPolygon2D"

## Handles when object's detection area is entered
func _on_detection_area_2d_area_entered(_area: Area2D) -> void:
	object_found.emit(target_object, true)
	## For RegionTriggers, it will immediately trigger the interaction. (See _object_notify function)
	## Monitoring set to false after current frame so player stops moving properly (or else they will keep moving through the region)
	if interact_type == Constants.InteractTypes.REGION_TRIGGER:
		detection_area_2d.set_deferred("monitoring",false)
	#print_debug (target_object," found by ", area)

## Handles when object's detection area is exited
func _on_detection_area_2d_area_exited(_area: Area2D) -> void:
	object_found.emit(target_object, false)
	#print_debug (target_object," lost")

## Toggles the object's detection area's monitoring based on the active light, signal from GameManager (may need to tweak this) 
func _on_objects_revealed(tool_light_type: Constants.LightTypes, revealed: bool):
	match tool_light_type:
		Constants.LightTypes.HIDDEN:
			if light_type == Constants.LightTypes.HIDDEN:
				detection_area_2d.monitoring = revealed
		Constants.LightTypes.SECRET:
			if light_type == Constants.LightTypes.SECRET or light_type == Constants.LightTypes.HIDDEN or light_type == Constants.LightTypes.SECRET_PHASE:
				detection_area_2d.monitoring = revealed
				#print_debug("secret revealed")
			
			

## Instantiates the interaction notifications (interact circle and question mark)
## and toggles the interaction area. In the case of REGION_TRIGGER, immediately triggers
## the interaction.
func _object_notify(activated: bool):
	## For anything that's not REGION_TRIGGER,
	if interact_type != Constants.InteractTypes.REGION_TRIGGER:
		interaction_area_2d.monitoring = activated
		
		## Question mark handler
		if activated == true:
			## Instantiates qmark if it does not exist yet
			if not has_node("QuestionMark"):
				q_mark = Constants.q_mark_scene.instantiate()
				add_child(q_mark)
				q_mark.position = notif_marker_2d.position
			## Triggers the "entering" animation if qmark is already instantiated
			## This is to handle when the player re-enters the detection area before
			## an existing qmark is cleared from the queue
			elif has_node("QuestionMark"):
				q_mark._notif_handling("entering", "question_mark")
		# Same logic as when activated = true, queue_free is in qmark "exiting" animation
		elif activated == false:
			if has_node("QuestionMark"):
				q_mark._notif_handling("exiting", "question_mark")
			elif not has_node("QuestionMark"):
				pass
				
		## Interaction circle handler (same logic as qmark handler)
		if activated == true:
			if not has_node("InteractCircle"):
				i_circle = Constants.i_circle_scene.instantiate()
				add_child(i_circle)
				i_circle.position = interaction_area_2d.position
			elif has_node("InteractCircle"):
				i_circle._notif_handling("entering", "interact_circle")
		elif activated == false:
			if has_node("InteractCircle"):
				i_circle._notif_handling("exiting", "interact_circle")
			elif not has_node("InteractCircle"):
				pass
#==============================================================================
		## Toggles the SECRET_PHASE object's collision based on active light
		if light_type == Constants.LightTypes.SECRET_PHASE:
			col_poly_2d.set_deferred("disabled", activated)
#==============================================================================
	## Exclusive logic for REGION_TRIGGER
	elif interact_type == Constants.InteractTypes.REGION_TRIGGER:
		i_circle_entered.emit(target_object, true, interact_type, repeat_type)

## Handles when the interaction area is entered
func _on_interaction_area_2d_area_entered(_area: Area2D) -> void:
	i_circle_entered.emit(target_object, true, interact_type, repeat_type)
	#print_debug("i_circle_entered ", target_object)

## Handles when the interaction area is exited
func _on_interaction_area_2d_area_exited(_area: Area2D) -> void:
	i_circle_entered.emit(target_object, false, interact_type, repeat_type)
	#print_debug("i_circle_exited ", target_object)
