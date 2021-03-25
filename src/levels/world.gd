extends Node2D


export var mine_threshold = -0.20
export var debug_print_minefield = false
export var stable_seed = false

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
var flags = {}
var noise
var cam_pos
var old_cam_pos
var cam_grid_pos
var cam_chunk_pos
var old_cam_chunk_pos
var exploding = false
var score

var flag_scene = preload("res://effects/Flag.tscn")
var explosions = {
	0: preload("res://effects/explosions/BigExplosion.tscn"),
	1: preload("res://effects/explosions/MediumExplosion.tscn"),
	2: preload("res://effects/explosions/MediumSmoke.tscn"),
}
const BIG_EXPLOSION = preload("res://effects/explosions/BigExplosion.tscn")
const MED_EXPLOSION = preload("res://effects/explosions/MediumExplosion.tscn")
const MED_SMOKE = preload("res://effects/explosions/MediumSmoke.tscn")

onready var number_tileset = $NumberTileset
onready var fog_of_war = $FogOfWar
onready var grid = $Grid
onready var cam2D = $Camera2D
onready var water = $Water
onready var target = $Target
onready var sfx_splash1 = $audio/splash1
onready var sfx_splash2 = $audio/splash2
onready var exploding_timer = $ExplodingTimer


func _ready():
	# This generates the world seed and simplex noice pattersn that mine placement will be off of
	if not stable_seed:
		randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 100
	noise.period = 1.0
	noise.persistence = 0.8
	
	score = 0
	
	# Initialize camera location variables
	cam_pos = cam2D.get_camera_position()
	cam_grid_pos = Vector2(int(cam_pos.x / 16), int(cam_pos.y / 16))
	cam_chunk_pos = (cam_grid_pos / 16).floor()
	
	# Generate initial chunks
	for i in range(-3,3):
		for j in range(-3,3):
			generate_chunk(Vector2(i,j))
	
	# Clear tiles around spawn
	for i in range(-4,4):
		for j in range(-4,4):
			var pos = Vector2(i,j)
			minefield[pos] = SAFE
			number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(tile_at(pos),0))
	
	reveal_tile(Vector2.ZERO)
	
	# Post-step camera position refresh
	old_cam_pos = cam_pos
	old_cam_chunk_pos = cam_chunk_pos


func _process(_delta):
	# Check to see if tiles need to be generated. If so, generate them
	cam_pos = cam2D.get_camera_position()
	if cam_pos != old_cam_pos:
		cam_grid_pos = Vector2(int(cam_pos.x / 16), int(cam_pos.y / 16))
		cam_chunk_pos = (cam_grid_pos / 16).floor()
		if cam_chunk_pos != old_cam_chunk_pos:
			for i in range(-2,2):
				for j in range(-2,2):
					var target_chunk = Vector2(i,j) + cam_chunk_pos
					generate_chunk(target_chunk)
	
	# Water shader
	water.position = cam2D.position;
	water.material.set_shader_param("global_position", water.get_global_position())
	water.material.set_shader_param("scale", water.scale)
	
	# Grid shader
	grid.position = cam2D.position;
	grid.material.set_shader_param("global_position", grid.get_global_position())
	grid.material.set_shader_param("scale", grid.scale)
	
	# Deal with input for relealing and flagging tiles
	if Input.is_action_just_pressed("reveal"):
		#if not target.getTile() in visible_field:
		reveal_tile(target.getTile())
		if tile_at(target.getTile()) != MINE:
			if randi() % 2 < 1:
				sfx_splash1.play()
			else:
				sfx_splash2.play()
	
	if Input.is_action_just_pressed("flag"):
		flag(target.getTile())
	
	# This is the end game logic to transisiton tot he game over screen
	if exploding:
		$WhiteTransition.position = cam2D.position
		if $WhiteTransition.modulate.a < 2:
			$WhiteTransition.modulate.a += .005
		elif $WhiteTransition.modulate.a < 3:
			exploding_timer.stop()
			$WhiteTransition.modulate.a += .005
		else:
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://levels/GameOver.tscn")
		print($WhiteTransition.modulate.a)
	
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
			var neighbor_chunk = Vector2(i,j) + chunk
			if not neighbor_chunk in minefield_chunks or minefield_chunks[neighbor_chunk] == RED:
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

# Reveales a world space tile, exploding if that tile is a mine
func reveal_tile(pos):
	# Check to see if revealing is possible and/or required
	if not pos in visible_field:
		visible_field[pos] = HIDDEN
	if visible_field[pos] == REVEALED or visible_field[pos] == FLAGGED:
		return
	
	# Checks for mine
	if tile_at(pos) == MINE:
		number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(MINE,0))
		fog_of_war.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(0,0))
		explode()
		return
	
	# Determine tile value
	var count = 0
	for i in range(-1,2):
		for j in range(-1,2):
			var neighbor = Vector2(i,j) + pos
			if tile_at(neighbor) == MINE:
				count += 1
	
	# Reveal neighbors if there are no nearby mines
	if count == 0:
		for i in range(-1,2):
			for j in range(-1,2):
				var neighbor = Vector2(i,j)
				if neighbor != Vector2.ZERO:
					neighbor += pos
					if not neighbor in visible_field:
						reveal_tile(neighbor)
	 
	# Update tilemaps
	number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(count,0))
	fog_of_war.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(0,0))
	
	# Update tile states
	visible_field[pos] = REVEALED
	score += 100
	return count

# Flags a worldspace tile
func flag(pos):
	# Check to see if flagging is possible and/or required
	if not pos in visible_field:
		visible_field[pos] = HIDDEN
	if visible_field[pos] == REVEALED:
		return
	
	# Togles flagged state, adding or removing flagsa in the proccess
	if visible_field[pos] == FLAGGED:
		flags[pos].queue_free()
		visible_field[pos] = HIDDEN
	elif visible_field[pos] == HIDDEN:
		var flag = flag_scene.instance()
		add_child(flag)
		flag.position = pos * 16
		flags[pos] = flag
		visible_field[pos] = FLAGGED

# Begin the explosion proccess
func explode():
	exploding = true
	exploding_timer.start()
	var mine_pos = (target.getTile() * 16) + Vector2(8,8)
	var explosion = explosions[randi() % 3].instance()
	add_child(explosion)
	explosion.position = mine_pos + Vector2(8,8)

# Safety function to make sure and tile query is handled properly
func tile_at(pos):
	if not pos in minefield:
		generate_chunk(pos/16)
	return minefield[pos]

# Debug function to reveal all mine positions
func debug_reveal_all():
	cam2D.zoom = Vector2(4,4)
	for pos in minefield:
		if minefield[pos] == MINE:
			number_tileset.set_cell(pos.x, pos.y, 0, false, false, false, Vector2(tile_at(pos),0))

# Explosion effects
func _ExplodingTimer():
	var mine_pos = (target.getTile() * 16) + Vector2(8,8)
	var explosion = explosions[randi() % 3].instance()
	add_child(explosion)
	var rand_x = pow(.1 * (randi() % 64 - 32),3)
	var rand_y = pow(.1 * (randi() % 64 - 32),3)
	explosion.position = mine_pos + Vector2(rand_x, rand_y)
