extends StaticBody
class_name Face

var mat = preload("res://FaceMaterial.tres")
var color = Color(0, 0, 0, 1)
var texture : ImageTexture


func _ready():
	mat = mat.duplicate(true)
#	$MeshInstance.mesh.surface_set_material(0, mat)
	$MeshInstance.material_override = mat
	mat.albedo_color = color
	mat.albedo_texture = texture


#func _process(delta):
#	pass


func init_face(direction : Vector3):
	match direction:
		Vector3(1, 0, 0):
			rotate(Vector3(0, 1, 0), PI / 2)
			set_color(Color(0, 0, 1))
		Vector3(-1, 0, 0):
			rotate(Vector3(0, 1, 0), -PI / 2)
			set_color(Color(0, 1, 0))
		Vector3(0, -1, 0):
			rotate(Vector3(1, 0, 0), PI / 2)
			set_color(Color(1, 0.5, 0))
		Vector3(0, 1, 0):
			rotate(Vector3(1, 0, 0), -PI / 2)
			set_color(Color(1, 0, 0))
		Vector3(0, 0, -1):
			rotate(Vector3(0, 1, 0), PI)
			set_color(Color(1, 1, 1))
		Vector3(0, 0, 1):
			set_color(Color(1, 1, 0))
	round_transform()


func round_transform():
	var o = transform.origin
	var b = transform.basis
	var x = Vector3(stepify(b.x.x, 1), stepify(b.x.y, 1), stepify(b.x.z, 1))
	var y = Vector3(stepify(b.y.x, 1), stepify(b.y.y, 1), stepify(b.y.z, 1))
	var z = Vector3(stepify(b.z.x, 1), stepify(b.z.y, 1), stepify(b.z.z, 1))
	o = Vector3(stepify(o.x, 0.5), stepify(o.y, 0.5), stepify(o.z, 0.5))
	transform = Transform(x, y, z, o).orthonormalized()


func set_color(c : Color):
	color = c
	mat.albedo_color = color


func set_texture(t : Texture):
	texture = t
	mat.albedo_texture = texture
