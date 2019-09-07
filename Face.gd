extends StaticBody
class_name Face

var mat = preload("res://FaceMaterial.tres")
var color = Color(0, 0, 0, 1)
var texture : ImageTexture

enum {TOP, BOTTOM, FRONT, BACK, LEFT, RIGHT}
var side : int


func _ready():
	mat = mat.duplicate(true)
	$MeshInstance.material_override = mat
	mat.albedo_color = color
	mat.albedo_texture = texture
	mat.emission = color
	mat.emission_energy = 1.0
	mat.emission_enabled = false


#func _process(delta):
#	pass


func init_face(direction : Vector3):
	match direction:
		Vector3(1, 0, 0):
			rotate(Vector3(0, 1, 0), PI / 2)
			side = RIGHT
		Vector3(-1, 0, 0):
			rotate(Vector3(0, 1, 0), -PI / 2)
			side = LEFT
		Vector3(0, -1, 0):
			rotate(Vector3(1, 0, 0), PI / 2)
			side = BOTTOM
		Vector3(0, 1, 0):
			rotate(Vector3(1, 0, 0), -PI / 2)
			side = TOP
		Vector3(0, 0, -1):
			rotate(Vector3(0, 1, 0), PI)
			side = BACK
		Vector3(0, 0, 1):
			side = FRONT
	round_transform()
	
	if get_parent().get_parent().show_textures:
		set_texture(get_parent().get_parent().textures[side])
		set_color(Color(1, 1, 1), false)
	else:
		set_texture(null)
		set_color(get_parent().get_parent().colors[side])


func round_transform():
	var o = transform.origin
	var b = transform.basis
	var x = Vector3(stepify(b.x.x, 1), stepify(b.x.y, 1), stepify(b.x.z, 1))
	var y = Vector3(stepify(b.y.x, 1), stepify(b.y.y, 1), stepify(b.y.z, 1))
	var z = Vector3(stepify(b.z.x, 1), stepify(b.z.y, 1), stepify(b.z.z, 1))
	o = Vector3(stepify(o.x, 0.5), stepify(o.y, 0.5), stepify(o.z, 0.5))
	transform = Transform(x, y, z, o).orthonormalized()


func set_color(c : Color, emission : bool = true):
	color = c
	mat.albedo_color = color
	if emission:
		mat.emission = color
	else:
		mat.emission = Color(0, 0, 0)


func set_texture(t : Texture):
	texture = t
	mat.albedo_texture = texture
	mat.emission_texture = texture
