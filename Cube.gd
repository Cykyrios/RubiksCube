#tool
extends Spatial
class_name Cube

export (int, 2, 7) var size = 3 setget set_size

var cells = []
var rotating_cells = []
var rotating = false
var rotation_axis = Vector3()
var t = 0.0
var rotation_duration = 0.5
var move_queue = []

var cell_scene = preload("res://Cell.tscn")



func _ready():
	init_cube()


func _process(delta):
	if rotating:
		t += delta / rotation_duration
		for cell in rotating_cells:
			cell.transform = cell.rotated_around_origin(rotation_axis, PI / 2 * t)
		if t >= 1:
			rotating = false
			t = 0
			for cell in rotating_cells:
				cell.transform = cell.rotated_around_origin(rotation_axis, PI / 2)
	elif not move_queue.empty():
		var move = move_queue[0]
		rotate_slice(move[0], move[1])
		move_queue.remove(0)


func _input(event):
	if event.is_action_pressed("ui_home"):
		reset_cube()
	if event.is_action_pressed("ui_up"):
		move_queue.append([Vector3(0, 1, 0), 1])
	if event.is_action_pressed("ui_right"):
		move_queue.append([Vector3(1, 0, 0), 1])


func rotate_slice(axis : Vector3, pos : float):
	rotating_cells = []
	for cell in cells:
		if axis * cell.global_transform.origin == axis * pos:
			rotating_cells.append(cell)
			cell.set_target_rotation(axis, pos)
	rotation_axis = axis
	rotating = true


func set_size(s : int):
	size = s
	delete_cube()
	init_cube()


func delete_cube():
	for cell in cells:
		cell.queue_free()
	cells = []


func init_cube():
	var type = 0
	for j in range(size):
		for i in range(size):
			for k in range(size):
				if j > 0 and j < size - 1:
					if i > 0 and i < size - 1:
						if k > 0 and k < size - 1:
							continue
						else:
							type = Cell.CENTER
					else:
						if k > 0 and k < size - 1:
							type = Cell.CENTER
						else:
							type = Cell.EDGE
				else:
					if i > 0 and i < size - 1:
						if k > 0 and k < size - 1:
							type = Cell.CENTER
						else:
							type = Cell.EDGE
					else:
						if k > 0 and k < size - 1:
							type = Cell.EDGE
						else:
							type = Cell.CORNER
				
				var cell = cell_scene.instance()
				cells.append(cell)
				add_child(cell)
				
				# Normalized cell coordinates
				var a = (i - size / 2.0 + 0.5) * 2 / (size - 1)
				var b = (j - size / 2.0 + 0.5) * 2 / (size - 1)
				var c = (k - size / 2.0 + 0.5) * 2 / (size - 1)
				cell.init_cell(type, a, b, c)
				
				cell.translate(Vector3(i, j, k) - (size - 1) / 2.0 * Vector3.ONE)
				pass


func reset_cube():
	rotating = false
	t = 0
	move_queue.clear()
	delete_cube()
	init_cube()
