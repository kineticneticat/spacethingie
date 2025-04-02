extends Camera3D

var watch_pos = Vector3.ZERO
var watch_angle = 0
var watch_angle_vert = 60
var watch_radius = 100

@export var MOVE_SPEED = 100

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO

	if Input.is_action_pressed("strafe_right"):
		direction.x -= 1
	if Input.is_action_pressed("strafe_left"):
		direction.x += 1
	if Input.is_action_pressed("move_backwards"):
		direction.z -= 1
	if Input.is_action_pressed("move_forwards"):
		direction.z += 1
	if Input.is_action_pressed("move_up"):
		direction.y += 1
	if Input.is_action_pressed("move_down"):
		direction.y -= 1
		
	direction = direction.normalized()
	watch_pos += direction * delta * MOVE_SPEED
	
	position = watch_pos + Vector3(cos(watch_angle), sin(watch_angle_vert), sin(watch_angle))*watch_radius
	$/root/World/UI/Map/MapViewport/SystemMap/CameraWatchPos.position = watch_pos
	#basis = Basis.looking_at(watch_pos).inverse()
	
	print(position)
	
