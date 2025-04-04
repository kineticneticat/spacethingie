extends Node3D

@export var Name = "Blank"

const uipartnode = preload("res://ui_marker_part.tscn")
@onready var MarkersNode = get_node("/root/World/UI/Markers")
@onready var Player: CharacterBody3D = get_node("/root/World/Player")

var UIPart: Control

func _ready() -> void:
	UIPart = uipartnode.instantiate()
	(UIPart.get_node("Cross") as TextureRect).modulate = Color(0.5,1,1,1)
	MarkersNode.add_child(UIPart)

func _process(_delta: float) -> void:
	if not get_viewport().get_camera_3d().is_position_behind(position):
		UIPart.visible = true
		UIPart.position = get_viewport().get_camera_3d().unproject_position(global_position)
		(UIPart.get_node("Name") as Label).text = Name
		(UIPart.get_node("Distance") as Label).text = str(round(global_position.distance_to(Player.global_position)*10)/10) + "m"
	else:
		UIPart.visible = false
