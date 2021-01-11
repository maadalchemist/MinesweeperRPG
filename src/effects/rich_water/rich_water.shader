shader_type canvas_item;

uniform float hash_scale = 8.0; 
uniform float hash_tiles = 2.0; 

uniform vec4 dark_color : hint_color;
uniform vec4 light_color : hint_color;
uniform int OCTAVES = 4;
uniform float noise_time_factor = .5;
uniform int noise_factor = 20;

/* HASHES */
uint ihash1D_uint(uint q)
{
    // hash by Hugo Elias, Integer Hash - I, 2017
    q = (q << uint(13)) ^ q;
    return q * (q * q * uint(15731) + uint(789221)) + uint(1376312589);
}

uvec4 ihash1D_uvec4(uvec4 q)
{
    // hash by Hugo Elias, Integer Hash - I, 2017
    q = (q << uint(13)) ^ q;
    return q * (q * q * uint(15731) + uint(789221)) + uint(1376312589);
}

float hash1D(vec2 x)
{
    // hash by Inigo Quilez, Integer Hash - III, 2017
    uvec2 q = uvec2(x * 65536.0);
    q = uint(1103515245) * ((q >> uint(1)) ^ q.yx);
    uint n = uint(1103515245) * (q.x ^ (q.y >> uint(3)));
    return float(n) * (1.0 / float(uint(INF)));
}

vec2 hash2D(vec2 x)
{
    // based on: Inigo Quilez, Integer Hash - III, 2017
    uvec4 q = uvec2(x * 65536.0).xyyx + uvec2(0u, 3115245u).xxyy;
    q = 1103515245u * ((q >> 1u) ^ q.yxwz);
    uvec2 n = 1103515245u * (q.xz ^ (q.yw >> 3u));
    return vec2(n) * (1.0 / float(0xffffffffu));
}

vec3 hash3D(vec2 x) 
{
    // based on: pcg3 by Mark Jarzynski: http://www.jcgt.org/published/0009/03/02/
    uvec3 v = uvec3(x.xyx * 65536.0) * 1664525u + 1013904223u;
    v += v.yzx * v.zxy;
    v ^= v >> 16u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    return vec3(v) * (1.0 / float(0xffffffffu));
}

vec4 hash4D(vec2 x)
{
    // based on: pcg4 by Mark Jarzynski: http://www.jcgt.org/published/0009/03/02/
    uvec4 v = uvec4(x.xyyx * 65536.0) * 1664525u + 1013904223u;

    v += v.yzxy * v.wxyz;
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;
    
    v.x += v.y * v.w;
    v.w += v.y * v.z;
    
    v ^= v >> 16u;

    return vec4(v ^ (v >> 16u)) * (1.0 / float(0xffffffffu));
}

vec4 hash4D(vec4 x)
{
    // based on: pcg4 by Mark Jarzynski: http://www.jcgt.org/published/0009/03/02/
    uvec4 v = uvec4(x * 65536.0) * 1664525u + 1013904223u;

    v += v.yzxy * v.wxyz;
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;
    
    v.x += v.y*v.w;
    v.y += v.z*v.x;
    v.z += v.x*v.y;
    v.w += v.y*v.z;

    v ^= v >> 16u;

    return vec4(v ^ (v >> 16u)) * (1.0 / float(0xffffffffu));
}


vec2 betterHash2D(vec2 x)
{
    uvec2 q = uvec2(x);
    uint h0 = ihash1D(ihash1D(q.x) + q.y);
    uint h1 = h0 * 1933247u + ~h0 ^ 230123u;
    return vec2(h0, h1)  * (1.0 / float(0xffffffffu));
}

// generates a random number for each of the 4 cell corners
vec4 betterHash2D(vec4 cell)    
{
    uvec4 i = uvec4(cell) + 101323u;
    uvec4 hash = ihash1D(ihash1D(i.xzxz) + i.yyww);
    return vec4(hash) * (1.0 / float(0xffffffffu));
}

// generates 2 random numbers for each of the 4 cell corners
void betterHash2D(vec4 cell, out vec4 hashX, out vec4 hashY)
{
    uvec4 i = uvec4(cell) + 101323u;
    uvec4 hash0 = ihash1D(ihash1D(i.xzxz) + i.yyww);
    uvec4 hash1 = ihash1D(hash0 ^ 1933247u);
    hashX = vec4(hash0) * (1.0 / float(0xffffffffu));
    hashY = vec4(hash1) * (1.0 / float(0xffffffffu));
}

// generates 2 random numbers for each of the four 2D coordinates
void betterHash2D(vec4 coords0, vec4 coords1, out vec4 hashX, out vec4 hashY)
{
    uvec4 hash0 = ihash1D(ihash1D(uvec4(coords0.xz, coords1.xz)) + uvec4(coords0.yw, coords1.yw));
    uvec4 hash1 = hash0 * 1933247u + ~hash0 ^ 230123u;
    hashX = vec4(hash0) * (1.0 / float(0xffffffffu));
    hashY = vec4(hash1) * (1.0 / float(0xffffffffu));
} 

// generates a random number for each of the 8 cell corners
void betterHash3D(vec3 cell, vec3 cellPlusOne, out vec4 lowHash, out vec4 highHash)
{
    uvec4 cells = uvec4(cell.xy, cellPlusOne.xy);  
    uvec4 hash = ihash1D(ihash1D(cells.xzxz) + cells.yyww);
    
    lowHash = vec4(ihash1D(hash + uint(cell.z))) * (1.0 / float(0xffffffffu));
    highHash = vec4(ihash1D(hash + uint(cellPlusOne.z))) * (1.0 / float(0xffffffffu));
}

// generate random noise
float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(56, 78)) * 1000.0) * 1000.0);
}

// turn random values into basic noise
float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

// use complex math to generate complex noise
float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

void fragment() {
	// apply noise scale
	vec2 coord = UV * float(noise_factor);

	vec2 motion = vec2( fbm(coord + vec2(TIME * -noise_time_factor, TIME * noise_time_factor)) );

	float final = fbm(coord + motion);

	COLOR = vec4(dark_color + (light_color - dark_color) * final);
}