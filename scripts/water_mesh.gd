@tool
extends MeshInstance3D

@export var grid_size = 16.0:
	set(value):
		if grid_size != value:
			grid_size = value
			if Engine.is_editor_hint():
				call_deferred("_update_mesh")

@export var subdivision = 8:
	set(value):
		if subdivision != value:
			subdivision = value
			if Engine.is_editor_hint():
				call_deferred("_update_mesh")

@export var wave_0 : Vector4 = Vector4(0.3, 2.0, 1.0, 0.0)
@export var wave_1 : Vector4 = Vector4(0.2, 1.5, 0.8, 2.5)
@export var wave_2 : Vector4 = Vector4(0.15, 1.0, 1.2, 5.0)
@export var wave_3 : Vector4 = Vector4(0.1, 0.8, 0.6, 8.0)

@export var noise_scale : float = 1.0
@export var noise_strength : float = 0.3

@export var albedo : Color = Color(0.76, 0.94, 0.93, 0.8)
@export var metallic : float = 0.1
@export var roughness : float = 0.3
@export var water_level : float = 0.5
@export var scale_value : float = 1.0

@export_group("Edge Foam")
@export var edge_threshold : float = 0.1
@export var edge_softness : float = 0.5
@export var foam_color : Color = Color(1.0, 1.0, 1.0, 1.0)

var material : ShaderMaterial

func _enter_tree():
	if Engine.is_editor_hint():
		create_lowpoly_water()
		setup_material()

func _exit_tree():
	if Engine.is_editor_hint():
		mesh = null

func _ready():
	create_lowpoly_water()
	setup_material()

func _update_mesh():
	create_lowpoly_water()
	setup_material()

func create_lowpoly_water():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var offset = grid_size / 2.0
	var step = grid_size / float(subdivision)

	for z in range(subdivision):
		for x in range(subdivision):
			var x0 = x * step - offset
			var z0 = z * step - offset
			var x1 = (x + 1) * step - offset
			var z1 = (z + 1) * step - offset

			var v0 = Vector3(x0, 0.0, z0)
			var v1 = Vector3(x1, 0.0, z0)
			var v2 = Vector3(x0, 0.0, z1)
			var v3 = Vector3(x1, 0.0, z1)

			var normal = Vector3.UP
			var uv0 = Vector2(float(x) / subdivision, float(z) / subdivision)
			var uv1 = Vector2(float(x + 1) / subdivision, float(z) / subdivision)
			var uv2 = Vector2(float(x) / subdivision, float(z + 1) / subdivision)
			var uv3 = Vector2(float(x + 1) / subdivision, float(z + 1) / subdivision)

			st.set_normal(normal)
			st.set_uv(uv0)
			st.add_vertex(v0)
			st.set_uv(uv2)
			st.add_vertex(v2)
			st.set_uv(uv1)
			st.add_vertex(v1)

			st.set_normal(normal)
			st.set_uv(uv2)
			st.add_vertex(v2)
			st.set_uv(uv3)
			st.add_vertex(v3)
			st.set_uv(uv1)
			st.add_vertex(v1)

	st.generate_normals()
	mesh = st.commit()

func setup_material():
	material = ShaderMaterial.new()
	var shader = load("res://shaders/lowpoly-water-meny223.gdshader")
	material.shader = shader
	material.render_priority = 1
	update_shader_params()
	mesh.surface_set_material(0, material)

func update_shader_params():
	if not material:
		return

	material.set_shader_parameter("wave_0", wave_0)
	material.set_shader_parameter("wave_1", wave_1)
	material.set_shader_parameter("wave_2", wave_2)
	material.set_shader_parameter("wave_3", wave_3)
	material.set_shader_parameter("noise_scale", noise_scale)
	material.set_shader_parameter("noise_strength", noise_strength)
	material.set_shader_parameter("albedo", albedo)
	material.set_shader_parameter("metallic", metallic)
	material.set_shader_parameter("roughness", roughness)
	material.set_shader_parameter("water_level", water_level)
	material.set_shader_parameter("scale", scale_value)
	material.set_shader_parameter("edge_threshold", edge_threshold)
	material.set_shader_parameter("edge_softness", edge_softness)
	material.set_shader_parameter("foam_color", foam_color)

func _process(_delta):
	if material:
		update_shader_params()
