class_name Move
extends RefCounted


var axis: Vector3
var from_coord: float
var to_coord: float
var turn: int
var time: float


func _init(rotation_axis: Vector3, from: float, to: float, turns: int, duration: float) -> void:
	axis = rotation_axis
	from_coord = from
	to_coord = to
	turn = turns
	time = duration
