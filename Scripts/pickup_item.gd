extends Node2D
class_name PickupItem

@export var item_name: String
@export var icon: Texture2D
@export var is_stackable: bool = false
var scene_path: String = "res://Scenes/Lights/torch.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("items")
	pass # Replace with function body.

func _pickup_item():
	var item = {
		"item_name" : item_name,
		"icon" : icon,
		"quantity" : 1,
		"scene_path" : scene_path,
		}
	Inventory._add_item(item)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#pass
