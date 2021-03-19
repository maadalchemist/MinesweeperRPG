extends Node2D


export var mine_threshold = -0.20
export var debug_print_minefield = false

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
	DEFUSED,
}

enum {
	RED,
	YELLOW,
	GREEN,
}

enum {
	HIDDEN,
	REVEALED,
	FLAGGED,
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

onready var number_tileset = $NumberTileset
onready var fog_of_war = $FogOfWar
onready var grid = $Grid
onready var cam2D = $Camera2D
onready var water = $Water
onready var target = $target


func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
#	noise.seed = randi()
	noise.octaves = 100
	noise.period = 1.0
	noise.persistence = 0.8
	
	cam_pos = cam2D.get_camera_position()
	cam_grid_pos = Vector2(int(cam_pos.x / 16), int(cam_pos.y / 16))
	cam_chunk_pos = (cam_grid_pos / 16).floor()
	
	
	for i in range(-3,3):
		for j in range(-3,3):
			generate_chunk(Vector2(i,j))
	
	for i in range(-4,4):
		for j in range(-4,4):
			var pos = Vector2(i,j)
			minefield[pos] = SAFE
			number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(tile_at(pos),0))
	
	reveal_tile(Vector2.ZERO)
	
	old_cam_pos = cam_pos
	old_cam_chunk_pos = cam_chunk_pos

func _process(delta):
	cam_pos = cam2D.get_camera_position()
	if cam_pos != old_cam_pos:
		cam_grid_pos = Vector2(int(cam_pos.x / 16), int(cam_pos.y / 16))
		cam_chunk_pos = (cam_grid_pos / 16).floor()
		if cam_chunk_pos != old_cam_chunk_pos:
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
	old_cam_chunk_pos = cam_chunk_pos\
	
	if Input.is_action_just_pressed("reveal"):
		reveal_tile(target.getTile())
	
	# debug commands
	if Input.get_action_strength("debug_reveal_all"):
		debug_reveal_all()
	
	# end step logic
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
				minefield[pos] = SAFE
			if noise_val <= mine_threshold:
				minefield[pos] = MINE
			fog_of_war.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(1,0))
	
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
				number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(tile_at(pos),0))
	
	minefield_chunks[chunk] = GREEN

func reveal_tile(pos):
	if not pos in visible_field:
		visible_field[pos] = HIDDEN
	if visible_field[pos] == REVEALED:
		return
	
	if tile_at(pos) == MINE:
		number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(MINE,0))
		fog_of_war.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(0,0))
		explode()
		return
	
	var count = 0
	for i in range(-1,2):
		for j in range(-1,2):
			var neighbor = Vector2(i,j) + pos
			if tile_at(neighbor) == MINE:
				count += 1
	
	if count == 0:
		for i in range(-1,2):
			for j in range(-1,2):
				var neighbor = Vector2(i,j)
				if neighbor != Vector2.ZERO:
					neighbor += pos
					if not neighbor in visible_field:
						reveal_tile(neighbor)
	 
	number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(count,0))
	fog_of_war.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(0,0))
	
	visible_field[pos] == REVEALED

func explode():
	pass

func tile_at(pos):
	if not pos in minefield:
		generate_chunk(pos/16)
	return minefield[pos]

func debug_reveal_all():
	cam2D.zoom = Vector2(4,4)
	for pos in minefield:
		if minefield[pos] == MINE:
			number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(tile_at(pos),0))
