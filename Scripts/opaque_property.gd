extends Node
@onready var opaque_body: Node2D = $".."
@onready var opaque_sprite: Sprite2D = $"../Sprite2D"
@onready var mat: ShaderMaterial = opaque_sprite.material


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GameManager.light_position_sent.connect(_on_light_position_received)
	mat.set_shader_parameter("object_pos", opaque_body.global_position)
	pass
	
	
#func _on_light_position_received(light_pos: Vector2):
	#mat.set_shader_parameter("light_pos", light_pos)
	#print_debug(torch_pos)
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#pass
	
#func _set_shader_param():
	#
	#print_debug(mat.get_shader_parameter("object_pos"))
	#pass

#func _input(_event: InputEvent) -> void:
	#if Input.is_action_just_pressed("right"): 
		#print_debug(mat.get_shader_parameter("object_pos"))
		#pass
