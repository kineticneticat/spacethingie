extends Node

#func _physics_process(delta: float) -> void:
	#print($/root)
	
var is_in_map = false

func _ready() -> void:
	$/root/World/UI/Map.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		is_in_map = not is_in_map
		$/root/World/UI/Map.visible = is_in_map
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
