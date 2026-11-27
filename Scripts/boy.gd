extends CharacterBody2D

#@onready var _animation_player = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite = $AnimatedSprite2D
@onready var current_in_hand: Node2D #= $Torch # when scaling this up, use a dictionary
@export var base_speed: float = 70.0
@export var speed: float = base_speed
@export var direction: Vector2
@export var direction_input: Vector2 
@export var direction_facing: Vector2 #= Vector2(1, 0)
#@onready var game_manager: Node = get_tree().root.get_node("World").get_node("GameManager")

signal dialogue_triggered(object_ID: String)
signal inventory_triggered
signal camera_switch_triggered

@export var can_input: bool = true
@export var can_move: bool = true
@export var normal_direction_mode: bool = true
@export var can_interact: bool = false

enum BoyStates {LYING_DOWN, SITTING, STANDING}
@export var boy_state = BoyStates.LYING_DOWN
var cutscene_mode: bool = false


func _ready():
	Inventory.in_hand_switched.connect(_on_in_hand_switched)

func get_input():
	## Movement input, set velocity
	if can_input == true:
		if can_move == true:
			direction_input = Input.get_vector("left", "right", "up", "down")
			direction = direction_input
			if direction_input.x != 0:
				direction_facing = direction_input
			velocity = direction * speed
	
		## Toggle in-hand item on/off
		if Input.is_action_just_pressed("item_use") and current_in_hand != null:
			current_in_hand._on_in_hand_toggled()
	
		## Toggle in-hand item special (Item script will check if it's on or off)
		if Input.is_action_pressed("item_special") and current_in_hand != null:
			current_in_hand._on_in_hand_special(true)
		if Input.is_action_just_released("item_special") and current_in_hand != null:
			current_in_hand._on_in_hand_special(false)
	
		## Interact with object
		if can_interact == true and Input.is_action_just_pressed("interact"):
			dialogue_triggered.emit()
			
		## Trigger inventory
		if Input.is_action_just_pressed("inventory"):
			inventory_triggered.emit()
			
		if Input.is_action_just_pressed("inv_scroll_down"):
			Inventory.scroll_inventory(+1)
			
		if Input.is_action_just_pressed("inv_scroll_up"):
			Inventory.scroll_inventory(-1)
			
			
func _set_cutscene_mode(scene_bool):
	cutscene_mode = scene_bool
	_can_move(true)
	_can_input(!scene_bool)
	_can_interact(!scene_bool)
	
func _can_input(inputabool: bool):
		can_input = inputabool
	
func _can_move(movabool: bool):
	can_move = movabool
	if !can_move:
		velocity = Vector2.ZERO
	
func _can_interact(enabool: bool) -> void:
	can_interact = enabool
	
func animation_handler():
		## Check direction
	if direction_facing.x < 0:
		sprite.flip_h = false
	elif direction_facing.x > 0:
		sprite.flip_h = true
	
	animation_tree.set("parameters/MoveBlend/blend_position", velocity.normalized())
	
func _on_in_hand_switched(item_path: String):
	#print_debug("on in hand switched")
	#print_debug("Current in hand: ", current_in_hand)
	if current_in_hand != null:
		if current_in_hand.is_in_group("lights") and GameManager.light_is_on == true:
			current_in_hand._on_in_hand_toggled()
		current_in_hand.queue_free()
		current_in_hand = null
		
	if item_path != "":
		var new_in_hand = load(item_path)
		current_in_hand = new_in_hand.instantiate()
		add_child(current_in_hand)
		if current_in_hand.is_in_group("lights"):
			GameManager.connect_light_tool(current_in_hand)
		
	
func _physics_process(_delta: float) -> void:
	if can_move == false:
		speed = 0
	elif can_move == true:
		speed = base_speed
		
	animation_handler() ## handle animations
	get_input() ## Run get_input every physics frame
	move_and_slide() ## Movement
	#print(direction_facing)
