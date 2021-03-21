extends AnimatedSprite

var sfx_list = {
	0: preload("res://effects/explosions/sfx/sfx_explosion1.tres"),
	1: preload("res://effects/explosions/sfx/sfx_explosion2.tres"),
	2: preload("res://effects/explosions/sfx/sfx_explosion3.tres"),
	3: preload("res://effects/explosions/sfx/sfx_explosion4.tres"),
	4: preload("res://effects/explosions/sfx/sfx_explosion5.tres"),
	5: preload("res://effects/explosions/sfx/sfx_explosion6.tres"),
	6: preload("res://effects/explosions/sfx/sfx_explosion7.tres"),
}
var sfx_finished = false
var ani_finished = false

onready var sfx = $sfx


func _ready():
	sfx.stream = sfx_list[randi() % 7]
	play()
	sfx.play()


func _process(delta):
	if ani_finished and sfx_finished:
		queue_free()


func _on_animation_finished():
	ani_finished = true


func _on_sfx_finished():
	sfx_finished = true
