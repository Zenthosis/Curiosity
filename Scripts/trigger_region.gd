extends Node

@onready var detection_area_2d: Area2D = $detectionArea2D
@export var region_ID: String
signal region_triggered(regionID:String)

func _ready():
	if region_ID.is_empty():
		region_ID = name


func _on_detection_area_2d_area_entered(_area: Area2D) -> void:
	region_triggered.emit(region_ID)
