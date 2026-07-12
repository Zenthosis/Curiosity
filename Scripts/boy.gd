extends CharacterBody2D

@onready var _animation_player = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var current_in_hand: Node2D = $Torch # when scaling this up, use a dictionary
@export var base_speed: float = 70.0
@export var speed: float = base_speed
@export var direction: Vector2
@export var direction_input: Vector2
@export var direction_facing: Vector2
signal in_hand_toggled(in_hand_name: Node2D)
#signal in_hand_special(in_hand_name: Node2D, special_bool: bool)

var can_move: bool = true
var normal_direction_mode: bool = true

func _ready():
	current_in_hand.special_activated.connect(_on_special_activated)

func get_input():
	## Movement input, set velocity
	direction_input = Input.get_vector("left", "right", "up", "down")
	direction = direction_input
	if direction_input != Vector2.ZERO:
		direction_facing = direction_input
	velocity = direction * speed
	
	## Toggle in-hand item on/off
	if Input.is_action_just_pressed("item_use"):
		in_hand_toggled.emit(current_in_hand)
		current_in_hand._on_in_hand_toggled(current_in_hand)
	
	## Toggle in-hand item special (Item script will check if it's on or off)
	if Input.is_action_pressed("item_special"):
		#in_hand_special.emit(current_in_hand, true)
		current_in_hand._on_in_hand_special(current_in_hand, true)
	if Input.is_action_just_released("item_special"):
		#in_hand_special.emit(current_in_hand, false)
		current_in_hand._on_in_hand_special(current_in_hand, false)
		
	if Input.is_action_just_pressed("converse"):
		Dialogic.start("timeline")
		
func _on_special_activated(special_active_bool):
	can_move = !special_active_bool
	normal_direction_mode = !special_active_bool

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
