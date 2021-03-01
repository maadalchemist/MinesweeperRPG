extends Particles2D


func _on_Ship_splash_count(splash_amount):
	lifetime = splash_amount
	if lifetime <= .02:
		emitting = false
	else:
		emitting = true


func _on_Ship_turn(turn_direction):
	rotation = 90 * turn_direction
