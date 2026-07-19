extends Node

@onready var boy: CharacterBody2D = get_tree().get_root().get_node("World/Environment/Boy")
@export var dialog_dict: Resource = preload("res://Resources/dialogue_dict.tres")
@onready var light: Node2D = get_tree().get_root().get_node("World/Environment/Boy/Flashlight")
@export var hidden_objects_visible: bool = false
@export var secret_objects_visible: bool = false

enum LightTypes {NORMAL, HIDDEN, SECRET}

var hidden_light_on: bool = false
var secret_light_on: bool = false
var light_is_on: bool = false
var target_object_ID : String

signal objects_revealed(reveal_type: String, visible: bool)
signal light_position_sent(torch_position: Vector2)


func _ready() -> void:
	await get_tree().process_frame
	Inventory._set_player(boy)

	boy.dialogue_triggered.connect(_on_dialogue_triggered)
	Dialogic.timeline_started.connect(_dialogic_timeline_starter)
	Dialogic.timeline_ended.connect(_dialogic_timeline_ender)
	
	for light_tool in get_tree().get_nodes_in_group("lights"):
		light_tool.light_turned_on.connect(_on_light_turned_on)
	for interactive in get_tree().get_nodes_in_group("interactives"):
		interactive.object_found.connect(_on_object_found)
		interactive.i_circle_entered.connect(_on_i_circle_entered)
	#for opaque in get_tree().get_nodes_in_group("opaques"):
		#pass
	
func _on_dialogue_triggered() -> void:
	var timeline_ID: String = dialog_dict._find_dialog(target_object_ID)
	Dialogic.start(timeline_ID)

func _dialogic_timeline_starter() -> void:
	boy._interact_enabled(false)
	boy._can_move(false)

func _dialogic_timeline_ender() -> void:
	boy._interact_enabled(true)
	boy._can_move(true)
	

func _on_light_turned_on(light_type: LightTypes, light_on: bool) -> void:
	if light_type == LightTypes.HIDDEN:
		hidden_light_on = light_on
		objects_revealed.emit(light_type, hidden_light_on) 
		print_debug("hidden")
	if light_type == LightTypes.SECRET:
		secret_light_on = light_on
		#print_debug(light_type, " ", secret_light_on)
		objects_revealed.emit(light_type, secret_light_on) 
		print_debug("secret")
		
	if hidden_light_on or secret_light_on: ##if any light is on
		light_is_on = true
	else: 
		light_is_on = false

	#print_debug ("secret objects visible ", secret_objects_visible)
	
func _on_object_found(target_object: Node2D, found: bool) -> void:
	#print_debug (target_object," found")
	target_object.get_node("interactive_object")._object_notify(found)
	#print("target_object ", target_object, "triggered for notification ", found)
	
func _on_i_circle_entered(target_object: Node2D, interactabool: bool) -> void:
	#print("on_i_circle_entered ", target_object, " ", interactabool)
	boy._interact_enabled(interactabool)
	target_object_ID = target_object.name
	

func _process(_delta: float) -> void:
	if light_is_on == true:
		light_position_sent.emit(light.global_position)
		#opaque_material.set_shader_parameter("light_y_pos",torch.global_position.y)
		#opaque_material.set_shader_parameter("opaque_body_y_pos",0)
		#print_debug(opaque_material.get_shader_parameter("light_y_pos")-opaque_material.get_shader_parameter("opaque_body_y_pos"))
	pass
