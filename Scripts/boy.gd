extends CharacterBody2D

@onready var _animation_player = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var current_in_hand: Node2D = $Flashlight # when scaling this up, use a dictionary
@export var base_speed: float = 300.0#70.0
@export var speed: float = base_speed
@export var direction: Vector2
@export var direction_input: Vector2
@export var direction_facing: Vector2
#@onready var game_manager: Node = get_tree().root.get_node("World").get_node("GameManager")

signal dialogue_triggered(object_ID: String)

var can_move: bool = true
var normal_direction_mode: bool = true
var can_interact: bool = false


func _ready():
	pass

func get_input():
	## Movement input, set velocity
	direction_input = Input.get_vector("left", "right", "up", "down")
	direction = direction_input
	if direction_input.x != 0:
		direction_facing = direction_input
	velocity = direction * speed
	
	## Toggle in-hand item on/off
	if Input.is_action_just_pressed("item_use"):
		current_in_hand._on_in_hand_toggled()
	
	## Toggle in-hand item special (Item script will check if it's on or off)
	if Input.is_action_pressed("item_special"):
		current_in_hand._on_in_hand_special(true)
	if Input.is_action_just_released("item_special"):
		current_in_hand._on_in_hand_special(false)
	
	if can_interact == true and Input.is_action_just_pressed("interact"):
		dialogue_triggered.emit()
		
		
func _can_move(movabool: bool):
	can_move = movabool
	normal_direction_mode = movabool
	
func _interact_enabled(enabool: bool) -> void:
	can_interact = enabool
	
func animation_handler():
		## Check direction
	if normal_direction_mode == true:
		if direction_facing.x < 0:
			sprite.flip_h = false
		elif direction_facing.x > 0:
			sprite.flip_h = true
	
	## If player is moving, play walk animation
	if velocity != Vector2.ZERO:
		if _animation_player.current_animation != "walk":
			_animation_player.play("walk")
	
	## If player is static, play idle animation
	else:
		if _animation_player.current_animation != "idle":
			_animation_player.play("idle")
		
func _physics_process(_delta: float) -> void:
	if can_move == false:
		speed = 0
	elif can_move == true:
		speed = base_speed
		
	animation_handler() ## handle animations
	get_input() ## Run get_input every physics frame
	move_and_slide() ## Movement
