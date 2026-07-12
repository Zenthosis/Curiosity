extends Node2D

@onready var boy = $".."
@onready var marker = $"../OnHandMarker"
@onready var torchsprite = $TorchSprite
@onready var torchlight = $TorchSprite/TorchLight2D
@onready var base_rotation: float
var torch_on: bool = false
var special_active: bool = false
var special_target: Vector2


signal special_activated (special_active_bool: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_in_hand_toggled(current_in_hand: Node2D):
	if current_in_hand == self: ## checks if torch is in hand
		torch_on = !torch_on ## turns on/off the torch
		## turns the light on/off based on torch_on state
		if torch_on == false: 
			torchlight.visible = false
		elif torch_on == true:
			torchlight.visible = true
	else: pass
	
func _on_in_hand_special(current_in_hand: Node2D, special_bool: bool):
	if current_in_hand == self: ## checks if torch is in hand
		if torch_on == true: ## checks if torch is on
			if special_bool == true:
				special_activated.emit(true)
				special_active = true
			elif special_bool == false:
				special_activated.emit(false)
				special_active = false
				#rotation_degrees = base_rotation
				#print_debug("returning to base ", base_rotation)
		else: 
			special_active = false
			special_activated.emit(false)
	else: pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = marker.position+Vector2(0,-30)
	#if boy.velocity != Vector2.ZERO:
	if boy.direction_facing.x < 0:
		#scale.x = 1
		#base_rotation = 0
		torchsprite.rotation_degrees = 0
	elif boy.direction_facing.x > 0:
		#scale.x = -1
		#base_rotation = 180
		torchsprite.rotation_degrees = 180
		
	if torch_on == true and special_active == true:
		#print_debug (rotation_degrees)
		special_target = get_global_mouse_position()
		torchsprite.look_at(special_target)
		torchsprite.rotation_degrees += 180
		print_debug("2")
