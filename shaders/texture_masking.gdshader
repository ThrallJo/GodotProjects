shader_type canvas_item;

uniform sampler2D hidden_texture;
uniform vec2 position = vec2(0, 0);
uniform float zoom = 1.0;
uniform float size = 10.0;

void fragment() {
	vec4 main_color = texture(TEXTURE, UV);
	float UV_target_x = 
		(position.x + 
		((UV.x - 0.5) * zoom * float(textureSize(TEXTURE, 0).x)))
		/ (float(textureSize(hidden_texture, 0).x) * size)
		+ 0.5;
		 
	float UV_target_y = 
		(position.y + 
		((UV.y - 0.5) * zoom * float(textureSize(TEXTURE, 0).y)))
		/ (float(textureSize(hidden_texture, 0).y) * size)
		+ 0.5;
		
	if (main_color.a != 0.0) {
		COLOR.rgba = texture(hidden_texture, vec2(UV_target_x, UV_target_y)).rgba;
	} 
}