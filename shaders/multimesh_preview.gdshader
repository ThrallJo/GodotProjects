shader_type spatial;

const float NORMAL_MIN = 0.5;

// "uniform" values can be set from within the inspector
// "sampler2D" allows us to define a texture
uniform sampler2D stud: source_color;
uniform sampler2D anti_stud: source_color;

// The size of the brick. In the actual "MultiMesh" instance
// this will be passed via "INSTANCE_CUSTOM" instead.
uniform vec3 size = vec3(1.0, 1.0, 1.0);

varying vec3 vertex_normal;

void vertex() {
	vertex_normal = NORMAL;
}

void fragment() {
	// Default to solid color
	ALBEDO = COLOR.rgb;
	
	// Facing up
	if (vertex_normal.y > NORMAL_MIN) {
		ALBEDO *= texture(stud, UV * size.xz).rgb;
	}
	
	// Facing down
	else if (vertex_normal.y < -NORMAL_MIN) {
		ALBEDO *= texture(anti_stud, UV * size.xz).rgb;
	}
}