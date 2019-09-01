extends Spatial
class_name Cell

enum {CENTER, EDGE, CORNER}

var type = CENTER
var faces = []

var _xform_init : Transform
var _xform_start : Transform
var _xform_end : Transform

var face_scene = preload("res://Face.tscn")


func _ready():
	pass


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
	round_transform()
	_xform_init = transform
	_xform_start = _xform_init
	_xform_end = _xform_init
	
	type = t
	
	if x != 0:
		add_face(Vector3(x, 0, 0))
	if y != 0:
		add_face(Vector3(0, y, 0))
	if z != 0:
		add_face(Vector3(0, 0, z))


func round_transform():
	var o = transform.origin
	var b = transform.basis
	var x = Vector3(stepify(b.x.x, 1), stepify(b.x.y, 1), stepify(b.x.z, 1))
	var y = Vector3(stepify(b.y.x, 1), stepify(b.y.y, 1), stepify(b.y.z, 1))
	var z = Vector3(stepify(b.z.x, 1), stepify(b.z.y, 1), stepify(b.z.z, 1))
	o = Vector3(stepify(o.x, 0.5), stepify(o.y, 0.5), stepify(o.z, 0.5))
	transform = Transform(x, y, z, o).orthonormalized()


func reset():
	transform = _xform_init
