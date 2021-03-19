extends KinematicBody2D


var velocity = Vector2.ZERO
var rot_velocity = 0
var splash_amount = 0
var old_splash_amount = 0

export var rot_acc = .002
export var rot_fric = .002
export var max_rot_velocity = .05
export var acc = .02
export var fric = .7
export var max_speed = 70
export var max_splash_amount = .5

signal splash_count # for particle count
#signal turn # for particle angles

onready var engine_sound = $engine_sound


func _physics_process(delta):
	# determine inputs
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# rotational input
	if input_vector.x != 0:
		rot_velocity = move_toward(rot_velocity, max_rot_velocity * sign(input_vector.x), .0003 + (acc * (velocity.length() / (max_speed * 5))))
#		emit_signal("turn_direction",input_vector.x) 
	else:
		rot_velocity = move_toward(rot_velocity, 0, rot_fric)
#		emit_signal("turn_direction",0)
	rotation += rot_velocity
	
	# velocity input
	if input_vector.y != 0:
		velocity += -sign(input_vector.y) * max_speed * Vector2(cos(rotation), sin(rotation)) * acc
	velocity = velocity.move_toward(Vector2.ZERO, fric)
	velocity = velocity.clamped(max_speed)
	
	# movement
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.normal)
	
	# effects
	if input_vector.y != 0:
		engine_sound.pitch_scale = move_toward(engine_sound.pitch_scale, 3, .05)
		splash_amount = move_toward(splash_amount, max_splash_amount, .005)
	else:
		engine_sound.pitch_scale = move_toward(engine_sound.pitch_scale, 1, .1)
		splash_amount = move_toward(splash_amount, 0, .02)
	if old_splash_amount != splash_amount:
		emit_signal("splash_count", splash_amount)
	old_splash_amount = splash_amount
	
