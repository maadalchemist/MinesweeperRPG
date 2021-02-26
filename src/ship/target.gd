extends Sprite


func _process(delta):
	position.x = floor(position.x / 16) * 16
	position.y = floor(position.y / 16) * 16

func getTile():
	return Vector2(floor(position.x / 16), floor(position.y / 16))
