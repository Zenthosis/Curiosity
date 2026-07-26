extends Resource
class_name dialog_dictionary_resource

@export var dialog_dict:Dictionary[String, String] = { 
	}


func _find_dialog(key: String):
	return dialog_dict[key]
