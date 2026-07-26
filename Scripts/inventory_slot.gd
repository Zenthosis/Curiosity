extends Panel
class_name InventorySlot

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label

#@export var inventory_item_scene: = preload("uid://tgbtkrmy25vi")

#@export var item #: Item
#@export var hint_item #: Item = null


func _ready() -> void:
	Inventory.item_switched.connect(_on_item_switched)
	pass # Replace with function body.

func _on_item_switched(item_name: String, icon: Texture2D):
	$Label.text = item_name
	$Sprite2D.texture = icon
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
