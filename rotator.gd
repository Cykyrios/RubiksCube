class_name Rotator
extends RefCounted


var axis: Vector3
var turn_amount: int
var origin: Vector3


func _init(rotation_axis: Vector3, rotation_amount: int, axis_origin := Vector3.ZERO) -> void:
	axis = rotation_axis
	turn_amount = rotation_amount
	origin = axis_origin
