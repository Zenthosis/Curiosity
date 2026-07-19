shader_type canvas_item;

uniform int pixel_size: hint_range(0.0, 32.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 texture_size_px = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 grid_dimension = texture_size_px / float(pixel_size);
	vec2 pixel_uv = floor((UV*grid_dimension) + 0.5)/ grid_dimension;
	COLOR = texture(TEXTURE, pixel_uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
