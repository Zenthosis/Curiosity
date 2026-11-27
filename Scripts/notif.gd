extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "question_mark_in":
		animation_player.play("question_mark_idle")
		
	if anim_name == "interact_circle_in":
		animation_player.play("interact_circle_idle")
		
func _notif_handling(state: String, animating: String) -> void:
	var anim_str: String = animating
	match state:
		"entering":
			if animation_player.current_animation == anim_str + "_in":
				pass
			elif animation_player.current_animation == anim_str + "_out":
				var reverse_anim_end: float = animation_player.current_animation_position
				var reverse_anim_start: float = 0.0 
				animation_player.play_section_backwards(anim_str + "_out",reverse_anim_start,reverse_anim_end)
				await animation_player.animation_finished
				animation_player.play(anim_str + "_idle")
		"exiting":
			if animation_player.current_animation == anim_str + "_in":
				var reverse_anim_end: float = animation_player.current_animation_position
				var reverse_anim_start: float = 0.0 
				animation_player.play_section_backwards(anim_str + "_out",reverse_anim_start,reverse_anim_end)
				await animation_player.animation_finished
				queue_free()
			elif animation_player.current_animation == anim_str + "_idle":
				animation_player.play(anim_str + "_out")
