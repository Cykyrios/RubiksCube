extends Spatial
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


func set_color(c : Color):
	color = c
	mat.albedo_color = color


func set_texture(t : Texture):
	texture = t
	mat.albedo_texture = texture
