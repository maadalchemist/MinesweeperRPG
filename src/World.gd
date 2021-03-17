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
var noise
var cam_pos
var old_cam_pos
var cam_grid_pos
var cam_chunk_pos
var old_cam_chunk_pos

onready var NumberTileset = $NumberTileset
onready var grid = $Grid
onready var cam2D = $Camera2D
onready var water = $Water


func _ready():
#	randomize()
	noise = OpenSimplexNoise.new()
	noise.octaves = 100
	noise.period = 1.0
	noise.persistence = 0.8
	
	cam_pos = cam2D.get_camera_position()
	cam_grid_pos = Vector2(int(cam_pos.x / 16), int(cam_pos.y / 16))
	cam_chunk_pos = (cam_grid_pos / 16).floor()
	
	
	for i in range(-1,2):
		for j in range(-1,2):
			print("Generating chunk: ", Vector2(i,j))
			var o = 0
			while o < 1000000:
				o += 1
			generate_chunk(Vector2(i,j))
	
#	for i in range(-2,2):
#		for j in range(-2,2):
#			var pos = Vector2(i,j)
#
#			if minefield[pos] == MINE:
#				var count = 0
#				for k in range(-1,2):
#					for l in range(-1,2):
#						var neighbor = Vector2(k,l)
#						neighbor += pos
#						if minefield[neighbor] == MINE:
#							pass
##							count += 1
#						else:
#							minefield[neighbor] -= 1
#						NumberTileset.set_cell(neighbor.x, neighbor.y, 0, false, false, false, Vector2(minefield[neighbor],0))
#				minefield[pos] = count
#				NumberTileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(minefield[pos],0))
	
	old_cam_pos = cam_pos
	old_cam_chunk_pos = cam_chunk_pos

func _process(delta):
	cam_pos = cam2D.get_camera_position()
	if cam_pos != old_cam_pos:
		cam_grid_pos = Vector2(int(cam_pos.x / 16), int(cam_pos.y / 16))
		cam_chunk_pos = (cam_grid_pos / 16).floor()
		if cam_chunk_pos != old_cam_chunk_pos:
			print("chunk: ",cam_chunk_pos)
			for i in range(-2,2):
				for j in range(-2,2):
					var target = Vector2(i,j) + cam_chunk_pos
					generate_chunk(target)
	
	# Water shader
	water.position = cam2D.position;
	water.material.set_shader_param("global_position", water.get_global_position())
	water.material.set_shader_param("scale", water.scale)
	
	# Grid shader
	grid.position = cam2D.position;
	grid.material.set_shader_param("global_position", grid.get_global_position())
	grid.material.set_shader_param("scale", grid.scale)
	
	old_cam_pos = cam_pos
	old_cam_chunk_pos = cam_chunk_pos

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
#						if pos.x == 0 and k == -1:
#							k -= 1
#						if pos.y == 0 and k == -1:
#							l -= 1
						var neighbor = Vector2(k,l) + pos
						if not neighbor in minefield:
							minefield[neighbor] = ZERO
						if minefield[neighbor] == MINE:
							continue
						else:
							minefield[neighbor] += 1
						NumberTileset.set_cell(neighbor.x, neighbor.y, 0, false, false, false, Vector2(minefield[neighbor],0))
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

func reveal_tile(pos):
	pass
