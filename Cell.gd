extends StaticBody3D
class_name Cell

enum Type {CENTER, EDGE, CORNER}

var type := Type.CENTER
var faces: Array[Face] = []

var _xform_init := Transform3D.IDENTITY
var _xform_start := Transform3D.IDENTITY
var _rotator: Rotator = null

var face_scene := preload("res://Face.tscn")


func set_target_rotation(rotator: Rotator) -> void:
	_rotator = rotator
	_xform_start = transform


func rotated_around_origin(weight: float) -> void:
	var offset = transform.origin - _rotator.origin
	transform = _xform_start.translated_local(-offset).rotated(
			_rotator.axis, _rotator.turn_amount * PI / 2.0 * weight).translated_local(offset)
	if weight == 1.0:
		round_transform()


func add_face(direction: Vector3) -> void:
	var face = face_scene.instantiate()
	add_child(face)
	face.init_face(direction)
	faces.append(face)


func init_cell(t: Type, x: int, y: int, z: int) -> void:
	round_transform()
	_xform_init = transform
	_xform_start = _xform_init

	type = t

	if x != 0:
		add_face(Vector3(x, 0, 0))
	if y != 0:
		add_face(Vector3(0, y, 0))
	if z != 0:
		add_face(Vector3(0, 0, z))


func round_transform() -> void:
	var o = transform.origin
	var b = transform.basis
	var x = Vector3(snapped(b.x.x, 1), snapped(b.x.y, 1), snapped(b.x.z, 1))
	var y = Vector3(snapped(b.y.x, 1), snapped(b.y.y, 1), snapped(b.y.z, 1))
	var z = Vector3(snapped(b.z.x, 1), snapped(b.z.y, 1), snapped(b.z.z, 1))
	o = Vector3(snapped(o.x, 0.5), snapped(o.y, 0.5), snapped(o.z, 0.5))
	transform = Transform3D(x, y, z, o).orthonormalized()


func reset() -> void:
	transform = _xform_init
