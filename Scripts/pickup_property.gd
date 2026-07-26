extends Node

@onready var attached_item: Node2D = $".."
@export var item_name: String
@export var icon: Texture2D
@export var is_stackable: bool = false
@export var scene_path: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _pickup_item():
	var item = {
		"item_name" : item_name,
		"icon" : icon,
		"scene_path" : scene_path,
		}
	#attached_item.get_node("interactive_object").get_node("InteractionArea2D").monitoring = false
	attached_item.get_node("detectionArea2D").monitoring = false
	print("waiting 3 secs")
	#await get_tree().create_timer(3).timeout
	#print("3 secs over")
	await GameManager.pickup_anim_finished
	print("pickup anim received")
	Inventory._add_item(item)
	attached_item.queue_free()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#pass
