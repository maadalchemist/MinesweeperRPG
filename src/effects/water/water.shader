shader_type canvas_item;

uniform vec4 dark_color : hint_color;
uniform float dark_threshold = .3;
uniform vec4 light_color : hint_color;
uniform float light_threshold = .7;

uniform bool draw_grid;
uniform bool draw_dot;
uniform bool cell_shade;
uniform bool pixellate;

uniform vec2 global_position;

uniform vec2 tile_scale = vec2(16.0, 16.0);
uniform vec2 scale = vec2(1.0, 1.0);

float random(vec2 coord) {
	return fract(sin(dot(coord,vec2(56.0, 78.0)) * 1000.0) * 1000.0);
}

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(128.0,256.0)),dot(p,vec2(270.0,180.0))))*50000.0);
}

void fragment() {
	vec2 position = (global_position + UV * scale) / tile_scale;
	vec2 tile = floor(position);
	vec2 tile_position = fract(position);
	if (pixellate) { tile_position = floor(tile_position * 16.0) / 16.0; }
	
	float minimum_distance = 1.0; 
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			// Neighbor place in the grid
			vec2 neighbor = vec2(float(x), float(y));
			
			// Random position from current + neighbor place in the grid
			vec2 point = random2(tile + neighbor);
			
			// Animate the point
			point = 0.5 + 0.5 * sin(TIME + 6.2831 * point);
			
			// Vector bet ween the pixel and the point
			vec2 diff = neighbor + point - tile_position;
			
			// Distance to the point
			float dist = length(diff);
			
			// Keep the closer distance
			minimum_distance = min(minimum_distance, dist);
		}
	}
	
	// Draw the min distance (distance field) shifted twards the lower values
	COLOR = vec4(vec3(pow(minimum_distance, 2.5)), 1.0);
	
	// convert to water colors
	if (!cell_shade) {
		COLOR = mix(dark_color, light_color, COLOR);
	} else {
		if (COLOR.b < dark_threshold) {
			COLOR = dark_color;
		} else if (COLOR.b < light_threshold) {
			COLOR = light_color;
		} else {
			COLOR = vec4(1.0);
		}
	}
	
	
	
	// Draw cell center
	COLOR += (1.-step(.02, minimum_distance)) * float(draw_dot);
	
	// Draw grid
	COLOR.r += (step(.98, tile_position.x) + step(.98, tile_position.y)) * float(draw_grid);
}