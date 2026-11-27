extends Node

const q_mark_scene = preload("res://Scenes/Commons/question_mark.tscn") 
const i_circle_scene = preload("res://Scenes/Commons/interact_circle.tscn") 
const opaque_res = preload("res://Resources/opaque_shader.tres")
enum LightTypes {NORMAL, HIDDEN, SECRET, SECRET_PHASE}
enum InteractTypes {DIALOGUE_ONLY, ITEM_PICKUP, ITEM_USE, REGION_TRIGGER, DIALOGUE_AND_CUTSCENE}
enum RepeatTypes {REPEAT, ONESHOT}
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
