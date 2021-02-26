extends KinematicBody2D


var velocity = Vector2.ZERO
var rot_velocity = 0;

export var rot_acc = .002
export var rot_fric = .002
export var max_rot_velocity = .05
export var acc = .02
export var fric = .7
export var max_speed = 70;


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# rotational input
	if input_vector.x != 0:
		rot_velocity = move_toward(rot_velocity, max_rot_velocity * sign(input_vector.x), rot_acc)
	else:
		rot_velocity = move_toward(rot_velocity, 0, rot_fric)
	rotation += rot_velocity
	
	# velocity input
	if input_vector.y != 0:
		velocity += -sign(input_vector.y) * max_speed * Vector2(cos(rotation), sin(rotation)) * acc
	velocity = velocity.move_toward(Vector2.ZERO, fric)
	velocity = velocity.clamped(max_speed)
	move_and_slide(velocity)
	
