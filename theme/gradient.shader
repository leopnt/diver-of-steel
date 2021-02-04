shader_type canvas_item;

uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	
	float ratio = SCREEN_UV.y;
	float iratio = 1.0 - SCREEN_UV.y;
	
	float new_r = color2.r * ratio + color1.r * iratio;
	float new_g = color2.g * ratio + color1.g * iratio;
	float new_b = color2.b * ratio + color1.b * iratio;
	
	COLOR = vec4(new_r, new_g, new_b, current_color.a);
}