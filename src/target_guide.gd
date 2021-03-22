extends Node2D


onready var target = get_node("../Target")

func _process(delta):
	target.move_toward_pos(position)
