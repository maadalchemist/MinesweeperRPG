extends AnimatedSprite

var pos_toward : Vector2


func _process(_delta):
	position.x = move_toward(position.x, floor(pos_toward.x / 16) * 16, .1 * abs(position.x - floor(pos_toward.x / 16) * 16)) #abs(position.x - floor(position.x / 16) * 16)
	position.y = move_toward(position.y, floor(pos_toward.y / 16) * 16, .1 * abs(position.y - floor(pos_toward.y / 16) * 16))

func getTile():
	return Vector2(floor(pos_toward.x / 16), floor(pos_toward.y / 16))

func move_toward_pos(pos):
	pos_toward = pos
