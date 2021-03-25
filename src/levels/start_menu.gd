extends MarginContainer


func new_game():
	get_tree().change_scene("res://levels/World.tscn")


func exit():
	get_tree().quit()
