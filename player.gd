extends CharacterBody3D

@export var roll_speed = TAU/360
@export var restitution = 0.1
@export var mass = 1
@export var max_speed = 5
@export var LOOKAROUND_SPEED = 0.002

var rot_x = 0
var rot_y = 0
var roll = 0
var roll_vel = 0

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if not Rails.is_in_map:
		if Input.is_action_pressed("strafe_right"):
			direction.x += 1
		if Input.is_action_pressed("strafe_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_backwards"):
			direction.z += 1
		if Input.is_action_pressed("move_forwards"):
			direction.z -= 1
		if Input.is_action_pressed("move_up"):
			direction.y += 1
		if Input.is_action_pressed("move_down"):
			direction.y -= 1
		if Input.is_action_pressed("slow_down"):
			if velocity.length_squared() > 0.01*0.01:
				direction -= global_transform.basis.inverse() * velocity.limit_length(1)
			
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			
		if Input.is_action_pressed("roll_clockwise"):
			roll -= roll_speed
		if Input.is_action_pressed("roll_anticlockwise"):
			roll += roll_speed
		transform.basis = Basis()
		var camera: Camera3D = get_node("Camera3D")
		rotate_object_local(camera.transform.basis.z, roll)
		rotate_object_local(Vector3.UP, rot_x)
		rotate_object_local(Vector3.RIGHT, rot_y)
		
	
	direction = global_transform.basis * direction
	velocity = velocity + (direction * delta)
	velocity = velocity.limit_length(max_speed)
	

	
	
	var collision = move_and_collide(velocity*delta)
	if collision:
		var bounce = velocity.bounce(collision.get_normal())
		if collision.get_collider() is RigidBody3D:
			if collision.get_collider().mass > 10 * mass:
				velocity = bounce * restitution
			else:
				var rigid : RigidBody3D = collision.get_collider()
				# force on rigid = dp/dt
				var player_momentum_before = mass*velocity
				var rigid_momentum_before = rigid.mass*rigid.linear_velocity
				var player_velocity = bounce * restitution
				var player_momentum_after = mass*player_velocity
				var rigid_momentum_after = (player_momentum_before + rigid_momentum_before) - player_momentum_after
				var delta_momentum = rigid_momentum_after - rigid_momentum_before
				var force = delta_momentum / delta
				var local_contact = collision.get_position() - rigid.global_position
				rigid.apply_force(force, local_contact)
				velocity = player_velocity - (force / mass * delta)
		else:
			# idfk just bounce
			velocity = bounce


func _input(event):
	if not Rails.is_in_map:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: # and event.button_mask & 1:
			rot_x -= event.relative.x * LOOKAROUND_SPEED
			rot_y -= event.relative.y * LOOKAROUND_SPEED
	#else:
		

	
	
