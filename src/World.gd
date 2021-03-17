extends Node2D


export var mine_threshold = -.25
export var debug_print_minefield = false

enum {
	ZERO,
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

enum {
	RED,
	YELLOW,
	GREEN,
}

var minefield = {}
var visible_field = {}
var minefield_chunks = {}
var noise = OpenSimplexNoise.new()

onready var NumberTileset = $NumberTileset
onready var grid = $Grid
onready var Camera2D = $Camera2D
onready var water = $Water


func _ready():
#	randomize()
	noise.octaves = 100
	noise.period = 1.0
	noise.persistence = 0.8
	
	var camera_position = Camera2D.get_camera_position()
	var camera_grid_pos = Vector2(int(camera_position.x / 16), int(camera_position.y / 16))
	var camera_chunk_pos = camera_grid_pos / 16
	
	for i in range(-2,1):
		for j in range(-2,1):
			generate_chunk(Vector2(i,j))

func _process(delta):
	var camera_position = Camera2D.get_camera_position()
	var camera_grid_pos = Vector2(int(camera_position.x / 16), int(camera_position.y / 16))
	var camera_chunk_pos = camera_grid_pos / 16
	# Water shader
	water.position = Camera2D.position;
	water.material.set_shader_param("global_position", water.get_global_position())
	water.material.set_shader_param("scale", water.scale)
	# Grid shader
	grid.position = Camera2D.position;
	grid.material.set_shader_param("global_position", grid.get_global_position())
	grid.material.set_shader_param("scale", water.scale)

# Generates a chunk all the way to green state
func generate_chunk(chunk):
	if not chunk in minefield_chunks:
		generate_chunk_red(chunk)
	elif minefield_chunks[chunk] == GREEN:
		return
	elif minefield_chunks[chunk] == RED:
		generate_chunk_red(chunk)
	if minefield_chunks[chunk] == YELLOW:
		generate_chunk_yellow(chunk)

# first chunk generation step - does not check for proper edge tile states
func generate_chunk_red(chunk):
	if not chunk in minefield_chunks:
		minefield_chunks[chunk] = RED
	for i in range(0,16):
		for j in range(0,16):
			var pos = chunk * 16
			pos.x += i
			pos.y += j
			var noise_val = noise.get_noise_2dv(pos)
			
			if not pos in minefield:
				minefield[pos] = ZERO
			if noise_val <= mine_threshold:
				minefield[pos] = MINE
				for k in range (-1,2):
					for l in range(-1,2):
						var neighbor = Vector2(k,l) + pos
						if not neighbor in minefield:
							minefield[neighbor] = 0
						if minefield[neighbor] == MINE:
							continue
						else:
							minefield[neighbor] += 1
	minefield_chunks[chunk] = YELLOW

#second chunk generation step - generates edge chunks
func generate_chunk_yellow(chunk):
	if not chunk in minefield_chunks or minefield_chunks[chunk] == RED:
		generate_chunk_red(chunk)
	for i in range (-1,1):
		for j in range(-1,1):
			if not chunk in minefield_chunks or minefield_chunks[chunk] == RED:
				generate_chunk_red(chunk)
	# Debug
	if debug_print_minefield:
		for i in range(0,16):
			for j in range(0,16):
				var pos = chunk * 16
				pos.x += i
				pos.y += j
				NumberTileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(minefield[pos],0))
	
	minefield_chunks[chunk] = GREEN
