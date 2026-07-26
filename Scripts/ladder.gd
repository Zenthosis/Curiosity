extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2).timeout
	animation_player.play("ladder_idle")
	#_on_animation_player_animation_finished("")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	await get_tree().create_timer(randi_range(10,20)).timeout
	animation_player.play("ladder_idle")
