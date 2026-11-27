extends Node

signal inventory_updated

var player: CharacterBody2D
var inventory: Array = []
var current_slot: int = 0 
var current_size: int = 0
@export var curr_item_name: String
@export var curr_item_icon: Texture2D
@export var curr_item_path: String

const EMPTY = preload("uid://dc2u4834vwv1c")

signal item_switched(curr_item_name: String, curr_item_icon: Texture2D)
signal in_hand_switched(curr_item_path: String)

func _ready() -> void:
	var empty_hand= {
	"item_name" : "",
	"icon" : EMPTY,
	"scene_path" : "",
	}
	_add_item(empty_hand)
	scroll_inventory(0)
	pass

func _add_item(item):
	inventory.resize(current_size+1)
	current_size = inventory.size()
	var i: int = inventory.size() - 1
	if inventory[i] == null:
		inventory[i] = item 
		inventory_updated.emit()
		print("inventory updated")
		
	
func _remove_item():
	pass
	
func scroll_inventory(scroll_dir): #-> String:
	current_slot = current_slot + scroll_dir
	if current_size == 1:
		current_slot = 0
	elif current_slot <0:
		current_slot = current_size - 1
	elif current_slot > current_size - 1:
		current_slot = 0
	
	var curr_item_dict: Dictionary = inventory[current_slot]
	curr_item_name = curr_item_dict["item_name"]
	curr_item_icon = curr_item_dict["icon"]
	curr_item_path = curr_item_dict["scene_path"]
	#print("Name: ", curr_item_name)
	#print("Icon: ", curr_item_icon)
	#print("Path: ", curr_item_path)
	if current_size > 1:
		item_switched.emit(curr_item_name, curr_item_icon)
		in_hand_switched.emit(curr_item_path)
		#print_debug("curr item path ", curr_item_path)
	#return curr_item_path
	
func _set_player(play_ref: CharacterBody2D):
	player = play_ref
