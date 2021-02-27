shader_type canvas_item;

uniform vec4 color : hint_color;
uniform vec2 global_position;
uniform vec2 scale = vec2(1.0, 1.0);

void fragment() {
	//vec2 position = (global_position + UV) / vec2(1.0);
	vec2 position = (global_position + UV* scale) / vec2(16.0) + vec2(.09375, .40625);
	vec2 tile = floor(position);
	vec2 tile_position = fract(position);
	tile_position = floor(tile_position * 32.0);
	bool edge = false;
	if (tile_position.x <= 1.0 || tile_position.y <= 1.0 || tile_position.x >= 32.0 || tile_position.y >= 32.0) {
		edge = true;
	}
	
	COLOR = color * float(edge);
	
	// Draw grid
	// COLOR.r += (step(.98, tile_position.x) + step(.98, tile_position.y));
}