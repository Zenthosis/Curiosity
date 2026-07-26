extends Node

func dialog_caller(obj_name: String):
	GameManager.set_timeline_ID(obj_name)
	GameManager._on_dialogue_triggered()
	 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
