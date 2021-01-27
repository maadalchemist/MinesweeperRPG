tool
extends Sprite


func move():
	pass

func update_shader_info():
	material.set_shader_param("global_position", get_global_position())
	material.set_shader_param("scale", scale)
