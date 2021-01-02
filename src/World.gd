extends Node2D


export var mine_chance = 10

enum {
	SAFE,
	ONE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	MINE,
}

var minefield = {}
var verbose_minefield = {}

onready var GrassTileset = $GrassTileset
onready var NumberTileset = $NumberTileset


func _ready():
	randomize()
	
	for i in range(-10, 10):
		for j in range(-10, 10):
			generate_mine_at(Vector2(i, j))

func _process(delta):
	pass

func generate_mine_at(pos):
	if pos in minefield:
		return
	var mine_seed = randi() % 100
	if mine_seed <= mine_chance:
		new_mine(pos)
	return

func new_mine(pos):
	minefield[pos] = MINE
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			var check = Vector2(i, j)
			if check in verbose_minefield:
				if verbose_minefield[check] != MINE:
					verbose_minefield[check] += 1
			else:
				verbose_minefield[check] = 1
			update_number_tile(check)
	verbose_minefield[pos] = MINE
	update_number_tile(pos)

#func perimeter_mine_count(pos):
#	var count = 0
#	if pos in minefield:
#		if minefield[pos] == MINE:
#			return count
#	for i in range(pos.x - 1, pos.x + 2):
#		for j in range(pos.y - 1, pos.y + 2):
#			if Vector2(i, j) in minefield:
#				count += (minefield[Vector2(i, j)] == MINE)
#	return count

func update_number_tile(pos):
	NumberTileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(verbose_minefield[pos],0))
