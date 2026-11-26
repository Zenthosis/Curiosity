extends Node

@onready var boy: CharacterBody2D = get_tree().get_root().get_node("World/Environment/Boy")
@onready var cutscene_player: AnimationPlayer = get_tree().get_root().get_node("World/CutscenePlayer")
@onready var current_light: Node2D
@onready var ui_inventory: Node = get_tree().get_root().get_node("World/UILayer/Inventory")
@onready var trans_cam: Camera2D = get_tree().get_root().get_node("World/TransitionCam")


@export var hidden_objects_visible: bool = false
@export var secret_objects_visible: bool = false
@export var dialog_dict: Resource = preload("res://Resources/dialogue_dict.tres")

var hidden_light_on: bool = false
var secret_light_on: bool = false
@export var light_is_on: bool = false
var interact_object: Node2D
var interact_object_ID : String
var obj_interact_type: Global1.InteractTypes
var obj_repeat_type: Global1.RepeatTypes

signal objects_revealed(reveal_type: String, visible: bool)
signal light_position_sent(torch_position: Vector2)
signal pickup_anim_finished()


func _ready() -> void:
	await get_tree().process_frame
	Inventory._set_player(boy)
	boy.dialogue_triggered.connect(_on_dialogue_triggered)
	boy.inventory_triggered.connect(_on_inventory_triggered)
	Dialogic.timeline_started.connect(_dialogic_timeline_starter)
	Dialogic.timeline_ended.connect(_dialogic_timeline_ender)
	
	boy.camera_switch_triggered.connect(_on_camera_switch_triggered)
	
	for interactive in get_tree().get_nodes_in_group("interactives"):
		connect_interactive(interactive)
	
	#INTRO CUTSCENE        
	#trigger_cutscene("Intro1")
	
	#Game test
	#trigger_cutscene("Intro2")
	
func trigger_cutscene(cutscene_id:String):
	boy._set_cutscene_mode(true)
	cutscene_player.play(cutscene_id)

func connect_light_tool(light_tool) -> void:
		current_light = light_tool
		light_tool.light_turned_on.connect(_on_light_turned_on)

func connect_interactive(interactive: Node2D) -> void:
		interactive.object_found.connect(_on_object_found)
		interactive.i_circle_entered.connect(_on_i_circle_entered)

func set_interact_type(type: Global1.InteractTypes):
	obj_interact_type = type

func set_repeat_type(type: Global1.RepeatTypes):
	obj_repeat_type = type
	
func set_timeline_ID(obj_name: String):
	interact_object_ID = obj_name

func _on_dialogue_triggered() -> void:
	var timeline_ID: String = dialog_dict._find_dialog(interact_object_ID)
	Dialogic.start(timeline_ID)


func _dialogic_timeline_starter() -> void:
	print_debug("timelinestarted")
	change_boy_input_mode(false)
	change_boy_interact_mode(false)
	change_boy_move_mode(false)

func _dialogic_timeline_ender() -> void:
	print_debug("timeline ended")
	print_debug(obj_interact_type)
	match obj_interact_type:
		Global1.InteractTypes.DIALOGUE_ONLY:
			await get_tree().create_timer(0.5).timeout
			change_boy_input_mode(true)
			change_boy_interact_mode(true)
			change_boy_move_mode(true)
		Global1.InteractTypes.ITEM_PICKUP:
			_pickup_trigger()
			await Inventory.inventory_updated
			change_boy_input_mode(true)
			change_boy_move_mode(true)
		Global1.InteractTypes.REGION_TRIGGER: #or Global1.InteractTypes.DIALOGUE_AND_CUTSCENE:
			print_debug("region trigger")
			print_debug("awaiting sequence finish signal")
			await cutscene_player.sequence_finished
			print("sequence_finished_received")
			boy._set_cutscene_mode(false)

		
	if obj_repeat_type == Global1.RepeatTypes.ONESHOT:
		interact_object.get_node("detectionArea2D").monitoring = false
		#change_boy_input_mode(false)
		#change_boy_interact_mode(false)
		#change_boy_move_mode(false)
		await get_tree().create_timer(2.5).timeout
		interact_object.get_node("interactive_property").queue_free()
		#change_boy_input_mode(true)
		#change_boy_interact_mode(true)
		#change_boy_move_mode(true)
		
	#boy._can_input(true)

func change_boy_input_mode(inputabool: bool):
	print_debug("input mode: ",inputabool)
	boy._can_input(inputabool)

func change_boy_move_mode(movabool: bool):
	print_debug("move mode: ",movabool)
	boy._can_move(movabool)
	
func change_boy_interact_mode(interactabool: bool):
	print_debug("interact mode: ",interactabool)
	boy._can_interact(interactabool)
	
func _on_camera_switch_triggered():
	trans_cam.switch_camera(Vector2(0,0), 1.5)
	
func _on_inventory_triggered() -> void:
	ui_inventory.visible = !ui_inventory.visible
	
func _on_light_turned_on(light_type: Global1.LightTypes, light_on: bool) -> void:
	if light_type == Global1.LightTypes.HIDDEN:
		hidden_light_on = light_on
		objects_revealed.emit(light_type, hidden_light_on) 
		#print_debug("hidden")
	if light_type == Global1.LightTypes.SECRET: #or light_type == Global1.LightTypes.SECRET_PHASE:
		secret_light_on = light_on
		#print_debug(light_type, " ", secret_light_on)
		objects_revealed.emit(light_type, secret_light_on) 
		#print_debug("secret")
		
	if hidden_light_on or secret_light_on: ##if any light is on
		light_is_on = true
	else: 
		light_is_on = false

	#print_debug ("secret objects visible ", secret_objects_visible)
	
func _on_object_found(target_object: Node2D, found: bool) -> void:
	#print_debug (target_object," found")
	target_object.get_node("interactive_property")._object_notify(found)
	#print("target_object ", target_object, "triggered for notification ", found)
	
func _on_i_circle_entered(target_object: Node2D, interactabool: bool, interact_behaviour: Global1.InteractTypes, repeat_behaviour: Global1.RepeatTypes) -> void:
	#print("on_i_circle_entered ", target_object, " ", interactabool)
	change_boy_interact_mode(interactabool)
	interact_object = target_object
	set_timeline_ID(target_object.name)
	if interactabool == true: 
		obj_interact_type = interact_behaviour
		obj_repeat_type = repeat_behaviour
		if obj_interact_type == Global1.InteractTypes.REGION_TRIGGER:
			_on_dialogue_triggered()


func _pickup_trigger() -> void:
	print("pickup triggered")
	interact_object.get_node("pickup_property")._pickup_item()
	await get_tree().create_timer(3).timeout
	pickup_anim_finished.emit()
	
func _process(_delta: float) -> void:
	if light_is_on == true:
		light_position_sent.emit(current_light.global_position)
	pass
