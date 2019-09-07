#tool
extends Spatial
class_name Cube

export (int, 2, 7) var size = 3 setget set_size
export var colors = [Color(1, 0, 0), Color(1, 0.5, 0), Color(1, 1, 0), Color(1, 1, 1), Color(0, 1, 0), Color(0, 0, 1)]
var textures = [load("res://Assets/Textures/Godot_Red.png"), load("res://Assets/Textures/Godot_Orange.png"),
		load("res://Assets/Textures/Godot_Yellow.png"), load("res://Assets/Textures/Godot_White.png"),
		load("res://Assets/Textures/Godot_Green.png"), load("res://Assets/Textures/Godot_Blue.png")]
export (bool) var show_textures = false

var cells = []
var rotating_cells = []
var rotating = false
var rotation_axis = Vector3()
var t = 0.0
export (float, 0.1, 1.0) var rotation_duration = 0.25
export (float, 0.0, 0.1) var scramble_time = 0.001
var animation_time = 0.0
var move_queue = []

export (bool) var check_orientation = false

var cell_scene = preload("res://Cell.tscn")



func _ready():
	init_cube()


func _process(delta):
	if rotating:
		while animation_time <= 0 and not move_queue.empty():
			rotate_cells()
			play_next_move()
		if animation_time > 0:
			t += delta / animation_time
		else:
			t = 1
		if t < 1:
			rotate_cells(t)
		else:
			rotating = false
			t = 0
			rotate_cells()
			is_solved(check_orientation)
	else:
		play_next_move()


func _input(event):
	if event.is_action_pressed("ui_home"):
		reset_cube()
	if event.is_action_pressed("ui_end"):
		scramble_cube()
	if event.is_action_pressed("ui_up"):
		add_move(Vector3(0, 1, 0), 1)
	if event.is_action_pressed("ui_right"):
		add_move(Vector3(1, 0, 0), 1)


func add_move(axis : Vector3, pos : float, time : float = rotation_duration):
	move_queue.append([axis, pos, time])


func play_next_move():
	if not move_queue.empty():
		var move = move_queue[0]
		rotate_slice(move[0], move[1], move[2])
		move_queue.remove(0)


func rotate_cells(weight : float = 1.0):
	for cell in rotating_cells:
		cell.transform = cell.rotated_around_origin(rotation_axis, PI / 2 * weight)
		if weight == 1.0:
			cell.round_transform()


func rotate_slice(axis : Vector3, pos : float, time : float):
	rotating_cells = []
	for cell in cells:
		if axis * cell.global_transform.origin == axis * pos:
			rotating_cells.append(cell)
			cell.set_target_rotation(axis, pos)
	rotation_axis = axis
	rotating = true
	animation_time = time


func scramble_cube():
	randomize()
	var num = 20 + randi() % 20
	for i in range(num):
		var axis = randi() % 6
		match axis:
			0:
				axis = Vector3.RIGHT
			1:
				axis = Vector3.LEFT
			2:
				axis = Vector3.UP
			3:
				axis = Vector3.DOWN
			4:
				axis = Vector3.FORWARD
			5:
				axis = Vector3.BACK
		var pos = 0.5 - size / 2.0 + randi() % size
		add_move(axis, pos, scramble_time)


func is_solved(check_face_orientation = false):
	var solved = false
	for i in range(6):
		var normal = Vector3.ZERO
		var tangent = Vector3.ZERO
		for cell in cells:
			for face in cell.faces:
				if face.side != i:
					continue
				else:
					if normal == Vector3.ZERO:
						normal = (cell.transform * face.transform).basis.z
					else:
						if (cell.transform * face.transform).basis.z != normal:
							return false
					if check_face_orientation:
						if tangent == Vector3.ZERO:
							tangent = (cell.transform * face.transform).basis.x
						else:
							if (cell.transform * face.transform).basis.x != tangent:
								return false
	print("Solved!")
	return true


func move_from_raycast(face : Face, axis : Vector3, vec : Vector3):
	var pos = face.get_parent().transform.origin
	match axis:
		Vector3(1, 0, 0), Vector3(-1, 0, 0):
			if abs(vec.dot(Vector3(0, 1, 0))) >= abs(vec.dot(Vector3(0, 0, 1))):
				vec = Vector3(0, 1, 0) * sign(vec.y)
			else:
				vec = Vector3(0, 0, 1) * sign(vec.z)
		Vector3(0, 1, 0), Vector3(0, -1, 0):
			if abs(vec.dot(Vector3(1, 0, 0))) >= abs(vec.dot(Vector3(0, 0, 1))):
				vec = Vector3(1, 0, 0) * sign(vec.x)
			else:
				vec = Vector3(0, 0, 1) * sign(vec.z)
		Vector3(0, 0, 1), Vector3(0, 0, -1):
			if abs(vec.dot(Vector3(1, 0, 0))) >= abs(vec.dot(Vector3(0, 1, 0))):
				vec = Vector3(1, 0, 0) * sign(vec.x)
			else:
				vec = Vector3(0, 1, 0) * sign(vec.y)
	var rot_axis = axis.cross(vec)
	var test = (pos * rot_axis * rot_axis).length()
	add_move(rot_axis, (pos * rot_axis).dot(rot_axis))


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
				
				cell.translate(Vector3(i, j, k) - (size - 1) / 2.0 * Vector3.ONE)
				
				# Normalized cell coordinates
				var a = (i - size / 2.0 + 0.5) * 2 / (size - 1)
				var b = (j - size / 2.0 + 0.5) * 2 / (size - 1)
				var c = (k - size / 2.0 + 0.5) * 2 / (size - 1)
				cell.init_cell(type, a, b, c)


func reset_cube():
	rotating = false
	t = 0
	move_queue.clear()
	for cell in cells:
		cell.reset()
