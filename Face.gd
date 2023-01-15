extends StaticBody3D
class_name Face

var mat := preload("res://FaceMaterial.tres")
var color := Color(0, 0, 0, 1)
var texture: CompressedTexture2D = null

enum Side {TOP, BOTTOM, FRONT, BACK, LEFT, RIGHT}
var side: Side


func _ready() -> void:
	mat = mat.duplicate(true)
	$MeshInstance3D.material_override = mat
	mat.albedo_color = color
	mat.albedo_texture = texture
	mat.emission = color
	mat.emission_energy = 1.0
	mat.emission_enabled = false


func init_face(direction: Vector3) -> void:
	match direction:
		Vector3(1, 0, 0):
			rotate(Vector3(0, 1, 0), PI / 2)
			side = Side.RIGHT
		Vector3(-1, 0, 0):
			rotate(Vector3(0, 1, 0), -PI / 2)
			side = Side.LEFT
		Vector3(0, -1, 0):
			rotate(Vector3(1, 0, 0), PI / 2)
			side = Side.BOTTOM
		Vector3(0, 1, 0):
			rotate(Vector3(1, 0, 0), -PI / 2)
			side = Side.TOP
		Vector3(0, 0, -1):
			rotate(Vector3(0, 1, 0), PI)
			side = Side.BACK
		Vector3(0, 0, 1):
			side = Side.FRONT
	round_transform()

	color_face()


func round_transform() -> void:
	var o = transform.origin
	var b = transform.basis
	var x = Vector3(snapped(b.x.x, 1), snapped(b.x.y, 1), snapped(b.x.z, 1))
	var y = Vector3(snapped(b.y.x, 1), snapped(b.y.y, 1), snapped(b.y.z, 1))
	var z = Vector3(snapped(b.z.x, 1), snapped(b.z.y, 1), snapped(b.z.z, 1))
	o = Vector3(snapped(o.x, 0.5), snapped(o.y, 0.5), snapped(o.z, 0.5))
	transform = Transform3D(x, y, z, o).orthonormalized()


func color_face() -> void:
	if get_parent().get_parent().show_textures:
		set_texture(get_parent().get_parent().textures[side])
		set_color(Color(1, 1, 1), false)
	else:
		set_texture(null)
		set_color(get_parent().get_parent().colors[side])


func set_color(c: Color, emission: bool = true) -> void:
	color = c
	mat.albedo_color = color
	if emission:
		mat.emission = color
	else:
		mat.emission = Color(0, 0, 0)


func set_texture(t: Texture2D) -> void:
	texture = t
	mat.albedo_texture = texture
	mat.emission_texture = texture


func set_face_uv(uv_scale: Vector3, offset: Vector3) -> void:
	mat.uv1_scale = uv_scale
	mat.uv1_offset = offset
