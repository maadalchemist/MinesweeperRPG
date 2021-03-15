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

onready var NumberTileset = $NumberTileset
onready var grid = $Grid
onready var Camera2D = $Camera2D
onready var water = $Water


func _ready():
	randomize()
	
	for i in range(-5, 5):
		for j in range(-5, 5):
			minefield[Vector2(i, j)] = MINE
	
	var camera_position = Camera2D.get_camera_position()
	var camera_grid_position = Vector2(int(camera_position.x / 16), int(camera_position.y / 16))
	for i in range(-12, 12):
		for j in range(-8, 8):
			generate_mine_at(Vector2(i + camera_grid_position.x, j + camera_grid_position.y))
	
	reveal_cell(Vector2(0,0))

func _physics_process(delta):
	var camera_position = Camera2D.get_camera_position()
	var camera_grid_position = Vector2(int(camera_position.x / 16), int(camera_position.y / 16))
	for i in range(-12, 12):
		for j in range(-8, 8):
			generate_mine_at(Vector2(i + camera_grid_position.x, j + camera_grid_position.y))

func _process(delta):
	# Water shader
	water.position = Camera2D.position;
	water.material.set_shader_param("global_position", water.get_global_position())
	water.material.set_shader_param("scale", water.scale)
	# Grid shader
	grid.position = Camera2D.position;
	grid.material.set_shader_param("global_position", grid.get_global_position())
	grid.material.set_shader_param("scale", water.scale)

# Generates mine at vector grid position
func generate_mine_at(pos):
	if pos in minefield: # if already generated
		return 
	var mine_seed = randi() % 100
	if mine_seed <= mine_chance:
		new_mine(pos)
	else:
		minefield[pos] = SAFE
		if not pos in verbose_minefield:
			for i in range(-1, 1):
				for j in range(-1, 1):
					generate_mine_at(Vector2(pos.x + i, pos.y + j))

# Places a mine and updates surrounding tiles
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
			#update_number_tile(check)
	verbose_minefield[pos] = MINE
	#update_number_tile(pos)

func update_number_tile(pos):
	NumberTileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(verbose_minefield[pos],0))

func reveal_cell(pos):
	if not pos in verbose_minefield:
		for i in range(-1, 1):
			for j in range(-1, 1):
				reveal_cell(Vector2(pos.x + i, pos.y + j))
		print("that tile hasn't been generated yet!")
		return
	NumberTileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(verbose_minefield[pos],0))
