#tool
extends Spatial
class_name Cube

export (int, 2, 7) var size = 3 setget set_size
export var colors = [Color(1, 1, 1), Color(1, 1, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 0.5, 0), Color(1, 0, 0)]
var textures = [load("res://Assets/Textures/Godot_White.png"), load("res://Assets/Textures/Godot_Yellow.png"),
		load("res://Assets/Textures/Godot_Green.png"), load("res://Assets/Textures/Godot_Blue.png"),
		load("res://Assets/Textures/Godot_Orange.png"), load("res://Assets/Textures/Godot_Red.png")]
export (bool) var show_textures = false

var cells = []
var rotating_cells = []
var rotating = false
var rotation_axis = Vector3()
var rotation_angle = 0.0
var t = 0.0
export (float, 0.1, 1.0) var rotation_duration = 0.25
export (float, 0.0, 0.1) var scramble_time = 0.001
var animation_time = 0.0
var move_queue = []

export (bool) var check_orientation = false

var cell_scene = preload("res://Cell.tscn")

signal solved



func _ready():
	init_cube()


func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.echo:
		var move = ""
		match event.scancode:
			KEY_F:
				move = "F"
			KEY_B:
				move = "B"
			KEY_L:
				move = "L"
			KEY_R:
				move = "R"
			KEY_U:
				move = "U"
			KEY_D:
				move = "D"
			KEY_M:
				move = "M"
			KEY_E:
				move = "E"
			KEY_S:
				move = "S"
			KEY_X:
				move = "X"
			KEY_Y:
				move = "Y"
			KEY_Z:
				move = "Z"
			_:
				return
		
		if Input.is_key_pressed(KEY_ALT):
			move = move.to_lower()
		var modifier = ""
		if Input.is_key_pressed(KEY_SHIFT):
			modifier = "'"
		elif Input.is_key_pressed(KEY_CONTROL):
			modifier = "2"
		
		move = move + modifier
		add_move_from_notation(move)


func _process(delta):
	if rotating:
		while animation_time <= 0 and not move_queue.empty():
			rotate_cells(rotation_angle)
			play_next_move()
		if animation_time > 0:
			t += delta / animation_time
		else:
			t = 1
		if t < 1:
			rotate_cells(rotation_angle, t)
		else:
			rotating = false
			t = 0
			rotate_cells(rotation_angle)
			is_solved(check_orientation)
	else:
		play_next_move()


func add_move(axis : Vector3, pos1 : float, pos2 : float, angle : int = 1, time : float = rotation_duration):
	move_queue.append([axis, pos1, pos2, angle, time])


func add_move_from_notation(move : String):
	var move_full = move
	var axis = Vector3.ZERO
	var pos1 = 0.5 - size / 2.0
	var pos2 = pos1
	var angle = 1
	var invert = 1
	var time = rotation_duration
	if move.ends_with("2"):
		angle *= 2
		time *= 2
		move = move.left(move.length() - 1)
	if move.ends_with("'"):
		invert = -1
		move = move.left(move.length() - 1)
	
	match move:
		"F", "f":
			axis = Vector3(0, 0, 1)
			pos1 = 0.5 - size / 2.0 + size - 1
			if move == "F":
				pos2 = pos1
			else:
				pos2 = pos1 - 1
			angle *= -1
		"B", "b":
			axis = Vector3(0, 0, 1)
			if move == "b":
				pos2 = pos1 + 1
		"L", "l":
			axis = Vector3(1, 0, 0)
			if move == "l":
				pos2 = pos1 + 1
		"R", "r":
			axis = Vector3(1, 0, 0)
			pos1 = 0.5 - size / 2.0 + size - 1
			if move == "R":
				pos2 = pos1
			else:
				pos2 = pos1 - 1
			angle *= -1
		"U", "u":
			axis = Vector3(0, 1, 0)
			pos1 = 0.5 - size / 2.0 + size - 1
			if move == "U":
				pos2 = pos1
			else:
				pos2 = pos1 - 1
			angle *= -1
		"D", "d":
			axis = Vector3(0, 1, 0)
			if move == "d":
				pos2 = pos1 + 1
		"M":
			if size != 3:
				OS.alert("Invalid move for size %s: \"%s\"" % [str(size), move_full])
				return
			axis = Vector3(1, 0, 0)
			pos1 += 1
			pos2 = pos1
		"E":
			if size != 3:
				OS.alert("Invalid move for size %s: \"%s\"" % [str(size), move_full])
				return
			axis = Vector3(0, 1, 0)
			pos1 += 1
			pos2 = pos1
			angle *= -1
		"S":
			if size != 3:
				OS.alert("Invalid move for size %s: \"%s\"" % [str(size), move_full])
				return
			axis = Vector3(0, 0, 1)
			pos1 += 1
			pos2 = pos1
			angle *= -1
		"X", "x":
			axis = Vector3(1, 0, 0)
			pos1 = 0.5 - size / 2.0 + size - 1
			angle *= -1
		"Y", "y":
			axis = Vector3(0, 1, 0)
			pos1 = 0.5 - size / 2.0 + size - 1
			angle *= -1
		"Z", "z":
			axis = Vector3(0, 0, 1)
			pos1 = 0.5 - size / 2.0 + size - 1
			angle *= -1
	
	if axis == Vector3.ZERO:
		OS.alert("Invalid move: %s" % [move_full])
		return
	
	angle *= invert
	add_move(axis, pos1, pos2, angle, time)


func play_next_move():
	if not move_queue.empty():
		var move = move_queue[0]
		rotate_slice(move[0], move[1], move[2], move[3], move[4])
		move_queue.remove(0)


func rotate_cells(angle : int = 1, weight : float = 1.0):
	for cell in rotating_cells:
		cell.transform = cell.rotated_around_origin(rotation_axis, angle * weight)
		if weight == 1.0:
			cell.round_transform()


func rotate_slice(axis : Vector3, pos1 : float, pos2 : float, angle : int = 1, time : float = rotation_duration):
	rotating_cells = []
	var num = abs(pos2 - pos1)
	var start = min(pos1, pos2)
	var targets = []
	for i in range(num + 1):
		targets.append((start + i) * axis)
	for cell in cells:
		if axis * cell.transform.origin in targets:
			rotating_cells.append(cell)
			cell.set_target_rotation(axis, angle)
	rotation_axis = axis
	rotation_angle = angle
	rotating = true
	animation_time = time


func scramble_cube():
	randomize()
	var num = 20 + randi() % 20
	for i in range(num):
		var axis = randi() % 3
		match axis:
			0:
				axis = Vector3(1, 0, 0)
			1:
				axis = Vector3(0, 1, 0)
			2:
				axis = Vector3(0, 0, 1)
		var angle_sign = 1 - 2 * (randi() % 2)
		var pos = 0.5 - size / 2.0 + randi() % size
		var angle = (1 + randi() % 2) * angle_sign
		add_move(axis, pos, pos, angle, scramble_time)


func is_solved(check_face_orientation = false):
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
	emit_signal("solved")
	return true


func move_from_raycast(face : Face, axis : Vector3, vec : Vector3, angle : int = 1):
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
	pos = (pos * rot_axis).dot(rot_axis)
	add_move(rot_axis, pos, pos, angle)


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
	update_faces_uv()


func reset_cube():
	rotating = false
	t = 0
	move_queue.clear()
	for cell in cells:
		cell.reset()


func update_faces_uv(tile = false):
	if tile:
		for cell in cells:
			for face in cell.faces:
				face.set_face_uv(Vector3.ONE, Vector3(0, 0, 0))
	else:
		var uv_size = Vector3.ONE / size
		for cell in cells:
			# Transform cell pos into offset-normalized cell coordinates
			var pos = cell.transform.origin
			pos = Vector3((pos.x - size / 2.0 - 0.5) / size + 1,
					(pos.y - size / 2.0 - 0.5) / size + 1,
					(pos.z - size / 2.0 - 0.5) / size + 1)
			
			for face in cell.faces:
				var uv_offset = Vector3.ZERO
				var face_normal = (cell.transform * face.transform).basis.z
				match face_normal:
					Vector3(1, 0, 0):
						uv_offset = Vector3(1 - 1.0 / size - pos.z, 1 - 1.0 / size - pos.y, 0)
					Vector3(-1, 0, 0):
						uv_offset = Vector3(pos.z, 1 - 1.0 / size - pos.y, 0)
					Vector3(0, 1, 0):
						uv_offset = Vector3(pos.x, pos.z, 0)
					Vector3(0, -1, 0):
						uv_offset = Vector3(pos.x, 1 - 1.0 / size - pos.z, 0)
					Vector3(0, 0, 1):
						uv_offset = Vector3(pos.x, 1 - 1.0 / size - pos.y, 0)
					Vector3(0, 0, -1):
						uv_offset = Vector3(1 - 1.0 / size - pos.x, 1 - 1.0 / size - pos.y, 0)
				face.set_face_uv(uv_size, uv_offset)
