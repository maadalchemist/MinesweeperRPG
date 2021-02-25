extends KinematicBody2D


var velocity = Vector2.ZERO
var rot_velocity = 0;

export var rot_acc = .002
export var rot_fric = .003
export var max_rot_velocity = .1
export var acc = 10
export var speed = 100

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector.x != 0:
		rot_velocity = move_toward(rot_velocity, max_rot_velocity * sign(input_vector.x), rot_acc)
	else:
		rot_velocity = move_toward(rot_velocity, 0, rot_fric)
	rotation += rot_velocity
	
	# velocity = input_vector * speed
	
	move_and_slide(velocity)
