shader_type canvas_item;

uniform vec2 object_pos;
varying vec2 object_screen_pos;

void vertex() {
    object_screen_pos = (CANVAS_MATRIX * vec4(object_pos, 0.0, 1.0)).xy;
}

void light() {
    LIGHT = vec4(0.0);
    if (LIGHT_IS_DIRECTIONAL || LIGHT_POSITION.y > object_screen_pos.y) {
        float ndotl = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
        LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * ndotl, LIGHT_COLOR.a);
    }
}

//shader_type canvas_item;
//
//uniform vec2 object_pos;
//uniform vec2 light_pos;
//
//
//void light() {
	//float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
//
	//if (light_pos.y > object_pos.y){
		//LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
	//}
	//if (light_pos.y <= object_pos.y){
		//LIGHT = vec4(0.,0.,0.,0.);
	//}
//}