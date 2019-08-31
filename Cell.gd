extends Spatial
class_name Cell

enum {CENTER, EDGE, CORNER}

var type = CENTER
var faces = []

var _xform_start : Transform
var _xform_end : Transform

var face_scene = preload("res://Face.tscn")


func _ready():
	_xform_start = transform
	_xform_end = transform


#func _process(delta):
#	pass


func set_target_rotation(axis : Vector3, angle : float):
	_xform_start = transform
	_xform_end = rotated_around_origin(axis, angle)


func rotated_around_origin(axis : Vector3, angle : float) -> Transform:
	var offset = transform.origin
	return _xform_start.translated(-offset).rotated(axis, angle).translated(offset)


func add_face(direction : Vector3):
	var face = face_scene.instance()
	add_child(face)
	face.init_face(direction)
	faces.append(face)


func init_cell(t : int, x : int, y : int, z : int):
	type = t
	
	if x != 0:
		add_face(Vector3(x, 0, 0))
	if y != 0:
		add_face(Vector3(0, y, 0))
	if z != 0:
		add_face(Vector3(0, 0, z))
