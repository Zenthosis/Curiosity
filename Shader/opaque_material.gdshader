shader_type canvas_item;

uniform vec2 object_pos;
uniform vec2 light_pos;

void vertex() {
}

void fragment() {
}

void light() {
	float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));

	if (light_pos.y > object_pos.y){
		LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
	}
	if (light_pos.y <= object_pos.y){
		LIGHT = vec4(0.,0.,0.,0.);
	}
}