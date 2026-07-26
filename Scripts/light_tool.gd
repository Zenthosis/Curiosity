#extends Item
extends Node2D

@onready var boy = $".."
@onready var marker = $"../OnHandMarker"
@onready var light_sprite = $LightSprite
@onready var base_rotation: float
@onready var light_detection_area: Area2D = $LightSprite/Light2D/LightDetectionArea2D
@onready var light_2d: PointLight2D = $LightSprite/Light2D
enum LightTypes {NORMAL, HIDDEN, SECRET}
@export var light_type: LightTypes


var light_on: bool = false
var special_active: bool = false
var special_target: Vector2

signal light_turned_on (light_type: LightTypes, light_on_bool: bool)
#signal torch_position_sent (torch_position :Vector2)
#signal boy_can_move (special_active_bool: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_in_hand_toggled():
	light_on = !light_on ## turns on/off the light
	light_turned_on.emit(light_type, light_on)
	if light_on == false: 
		light_2d.visible = false
		#light_detection_area.monitorable = false
	elif light_on == true:
		light_2d.visible = true
		#light_detection_area.monitorable = true
		
func _on_in_hand_special(special_bool: bool):
	if light_on == true: ## checks if light is on
		special_active = special_bool ## toggles special on/off
	else: 
		special_active = false ## keeps it off if light is not on

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = marker.position#+Vector2(0,-30)
	#if boy.velocity != Vector2.ZERO:
	if boy.velocity != Vector2.ZERO:
		if boy.direction_facing.x < 0: 
			#scale.x = 1
			base_rotation = 0
			light_sprite.rotation_degrees = 0
			#scale.x=1
		elif boy.direction_facing.x > 0: 
			#
			base_rotation = 180
			light_sprite.rotation_degrees = 180
			#scale.x = -1
		
	if light_on == true:
		#light_position_sent.emit(position)
		#print_debug(position)
		if special_active == true:
			#print_debug (rotation_degrees)
			special_target = get_global_mouse_position()
			light_sprite.look_at(special_target)
			light_sprite.rotation_degrees += 180
		
