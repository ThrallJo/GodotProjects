/****************************
stencil.gdshader
****************************/

shader_type canvas_item;

uniform sampler2D stencil_tex;
uniform vec4 target_color : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform float tolerance : hint_range(0.0, 1.0);
uniform bool invert_mask = false;

void fragment() {
	vec4 tex_color = texture(stencil_tex, UV);
	float diff = distance(tex_color.rgb, target_color.rgb);

	if (diff <= tolerance) {
		COLOR.a = invert_mask ? 0.0 : 1.0;
	} else {
		COLOR.a = invert_mask ? 1.0 : 0.0;
	}
}