extends Node

signal inventory_updated

var player: CharacterBody2D
var inventory: Array = []


func _ready() -> void:
	inventory.resize(30)
	

func _add_item(item):
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item 
			inventory_updated.emit()
	
func _remove_item():
	pass
	
func _set_player(play_ref: CharacterBody2D):
	player = play_ref
