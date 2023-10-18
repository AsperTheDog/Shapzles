shader_type canvas_item;
render_mode blend_mix;

uniform vec3 color;


void fragment() {
	COLOR.rgb = color;
	COLOR.a = texture(TEXTURE, UV).a;
}