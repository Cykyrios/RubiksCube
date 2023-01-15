class_name Cube
extends Node3D


signal solved

@export_range(2, 7) var size := 3 : set = set_size
@export var colors := [Color(1, 1, 1), Color(1, 1, 0), Color(0.15, 0.9, 0.15),
		Color(0.15, 0.15, 0.9), Color(1, 0.5, 0), Color(0.9, 0.15, 0.15)]
@export_range(0.1, 1.0) var rotation_duration := 0.25
@export_range(0.0, 0.1) var scramble_time := 0.001
@export var check_orientation := false

var textures := [load("res://Assets/Textures/Godot_White.png"), load("res://Assets/Textures/Godot_Yellow.png"),
		load("res://Assets/Textures/Godot_Green.png"), load("res://Assets/Textures/Godot_Blue.png"),
		load("res://Assets/Textures/Godot_Orange.png"), load("res://Assets/Textures/Godot_Red.png")]
var show_textures := false

var cells: Array[Cell] = []
var rotating_cells: Array[Cell] = []
var animation_time := 0.0
var move_queue: Array[Move] = []

var moves: Array[String] = []
var move_idx := 0

var cell_scene := preload("res://Cell.tscn")

var tween: Tween = null



func _ready() -> void:
	init_cube()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var move := ""
		match (event as InputEventKey).keycode:
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
			KEY_PAGEUP:
				undo_move()
				return
			KEY_PAGEDOWN:
				redo_move()
				return
			_:
				return
		if Input.is_key_pressed(KEY_ALT):
			move = move.to_lower()
		var modifier := ""
		if Input.is_key_pressed(KEY_SHIFT):
			modifier = "'"
		elif Input.is_key_pressed(KEY_CTRL):
			modifier = "2"
		move = move + modifier
		add_move_from_notation(move)


func play_move(axis: Vector3, pos1: float, pos2: float, angle: int = 1, time: float = rotation_duration) -> void:
	var move := Move.new(axis, pos1, pos2, angle, time)
	move_queue.append(move)


func add_move(axis: Vector3, pos1: float, pos2: float, angle: int = 1, time: float = rotation_duration) -> void:
	play_move(axis, pos1, pos2, angle, time)
	write_move(axis, pos1, pos2, angle)


func play_move_from_notation(move: String) -> void:
	var move_full := move
	var axis := Vector3.ZERO
	var pos1 := 0.5 - size / 2.0
	var pos2 := pos1
	var angle := 1
	var reverse := 1
	var time := rotation_duration
	if move.ends_with("2"):
		angle *= 2
		time *= 2
		move = move.left(move.length() - 1)
	if move.ends_with("'"):
		reverse = -1
		move = move.left(move.length() - 1)

	match move:
		"F", "f":
			axis = Vector3(0, 0, 1)
			pos1 = 0.5 - size / 2.0 + size - 1
			pos2 = pos1 if move == "F" else pos1 - 1
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
			pos2 = pos1 if move == "R" else pos1 - 1
			angle *= -1
		"U", "u":
			axis = Vector3(0, 1, 0)
			pos1 = 0.5 - size / 2.0 + size - 1
			pos2 = pos1 if move == "U" else pos1 - 1
			angle *= -1
		"D", "d":
			axis = Vector3(0, 1, 0)
			if move == "d":
				pos2 = pos1 + 1
		"M":
			if size != 3:
				print("Invalid move for size %s: \"%s\"" % [str(size), move_full])
				return
			axis = Vector3(1, 0, 0)
			pos1 += 1
			pos2 = pos1
		"E":
			if size != 3:
				print("Invalid move for size %s: \"%s\"" % [str(size), move_full])
				return
			axis = Vector3(0, 1, 0)
			pos1 += 1
			pos2 = pos1
			angle *= -1
		"S":
			if size != 3:
				print("Invalid move for size %s: \"%s\"" % [str(size), move_full])
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
		print("Invalid move: %s" % [move_full])
		return

	angle *= reverse
	play_move(axis, pos1, pos2, angle, time)


func add_move_from_notation(move: String) -> void:
	play_move_from_notation(move)
	write_move_from_notation(move)


func write_move(axis: Vector3, pos1: float, pos2: float, angle: int) -> void:
	var move := ""
	match axis:
		Vector3(1, 0, 0):
			if pos1 == 0.5 - size / 2.0:
				if pos2 == pos1:
					move = "L"
				elif pos2 == pos1 + 1:
					move = "l"
				elif pos2 == pos1 + size - 1:
					move = "X"
			elif pos1 == 0.5 - size / 2.0 + size - 1:
				if pos2 == pos1:
					move = "R'"
				elif pos2 == pos1 - 1:
					move = "r'"
				elif pos2 == 0.5 - size / 2.0:
					move = "X'"
			elif pos1 == 0.5 - size / 2.0 + 1:
				if pos2 == pos1:
					move = "M"
		Vector3(0, 1, 0):
			if pos1 == 0.5 - size / 2.0:
				if pos2 == pos1:
					move = "D"
				elif pos2 == pos1 + 1:
					move = "d"
				elif pos2 == pos1 + size - 1:
					move = "Y"
			elif pos1 == 0.5 - size / 2.0 + size - 1:
				if pos2 == pos1:
					move = "U'"
				elif pos2 == pos1 - 1:
					move = "u'"
				elif pos2 == 0.5 - size / 2.0:
					move = "Y'"
			elif pos1 == 0.5 - size / 2.0 + 1:
				if pos2 == pos1:
					move = "E'"
		Vector3(0, 0, 1):
			if pos1 == 0.5 - size / 2.0:
				if pos2 == pos1:
					move = "B"
				elif pos2 == pos1 + 1:
					move = "b"
				elif pos2 == pos1 + size - 1:
					move = "Z"
			elif pos1 == 0.5 - size / 2.0 + size - 1:
				if pos2 == pos1:
					move = "F'"
				elif pos2 == pos1 - 1:
					move = "f'"
				elif pos2 == 0.5 - size / 2.0:
					move = "Z'"
			elif pos1 == 0.5 - size / 2.0 + 1:
				if pos2 == pos1:
					move = "S'"
	if move == "":
		print("Error: could not write move")
		return
	if angle % 2 == 0:
		move += "2"
	if angle < 0:
		if "'" in move:
			move = move.replace("'", "")
		else:
			move += "'"
	write_move_from_notation(move)


func write_move_from_notation(move: String) -> void:
	if move_idx < moves.size():
		moves.resize(move_idx)
	moves.append(move)
	move_idx += 1
	print(move)
	if tween == null or not tween.is_running():
		play_next_move()


func undo_move() -> void:
	if moves.is_empty() or move_idx <= 0:
		return
	move_idx -= 1
	var move := moves[move_idx]
	if "'" in move:
		move = move.replace("'", "")
	else:
		if move.ends_with("2"):
			move = move.replace("2", "'2")
		else:
			move += "'"

	play_move_from_notation(move)


func redo_move() -> void:
	if moves.is_empty() or move_idx >= moves.size():
		return
	play_move_from_notation(moves[move_idx])
	move_idx += 1


func play_next_move() -> void:
	if not move_queue.is_empty():
		var move := move_queue[0]
		rotate_slice(move)
		move_queue.remove_at(0)


func rotate_slice(move: Move) -> void:
	rotating_cells = []
	var num := absf(move.to_coord - move.from_coord)
	var start := minf(move.from_coord, move.to_coord)
	var targets := []
	for i in range(num + 1):
		targets.append((start + i) * move.axis)
	var rotator := Rotator.new(move.axis, move.turn)
	for cell in cells:
		if move.axis * cell.transform.origin in targets:
			rotating_cells.append(cell)
			cell.set_target_rotation(rotator)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	for cell in rotating_cells:
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_method(cell.rotated_around_origin, 0.0, 1.0, move.time)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished():
	check_solved()
	if not move_queue.is_empty():
		play_next_move()


func check_solved():
	if is_solved(check_orientation):
		solved.emit()


func scramble_cube() -> void:
	randomize()
	var num := 20 + randi() % 20
	for i in range(num):
		var axis = randi() % 3
		match axis:
			0:
				axis = Vector3(1, 0, 0)
			1:
				axis = Vector3(0, 1, 0)
			2:
				axis = Vector3(0, 0, 1)
		var angle_sign := 1 - 2 * (randi() % 2)
		var pos := 0.5 - size / 2.0 + randi() % size
		var angle := (1 + randi() % 2) * angle_sign
		add_move(axis, pos, pos, angle, scramble_time)


func is_solved(check_face_orientation: bool = false) -> bool:
	for i in range(6):
		var normal := Vector3.ZERO
		var tangent := Vector3.ZERO
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
	return true


func move_from_raycast(face: Face, axis: Vector3, vec: Vector3, angle: int = 1) -> void:
	var pos := face.get_parent().transform.origin as Vector3
	match axis:
		Vector3(1, 0, 0), Vector3(-1, 0, 0):
			if absf(vec.dot(Vector3(0, 1, 0))) >= absf(vec.dot(Vector3(0, 0, 1))):
				vec = Vector3(0, 1, 0) * signf(vec.y)
			else:
				vec = Vector3(0, 0, 1) * signf(vec.z)
		Vector3(0, 1, 0), Vector3(0, -1, 0):
			if absf(vec.dot(Vector3(1, 0, 0))) >= absf(vec.dot(Vector3(0, 0, 1))):
				vec = Vector3(1, 0, 0) * signf(vec.x)
			else:
				vec = Vector3(0, 0, 1) * signf(vec.z)
		Vector3(0, 0, 1), Vector3(0, 0, -1):
			if absf(vec.dot(Vector3(1, 0, 0))) >= absf(vec.dot(Vector3(0, 1, 0))):
				vec = Vector3(1, 0, 0) * signf(vec.x)
			else:
				vec = Vector3(0, 1, 0) * signf(vec.y)
	var rot_axis := axis.cross(vec)
	var pos_dot := (pos * rot_axis).dot(rot_axis)
	match rot_axis:
		Vector3(-1, 0, 0), Vector3(0, -1, 0), Vector3(0, 0, -1):
			rot_axis = -rot_axis
			angle = -angle
	add_move(rot_axis, pos_dot, pos_dot, angle)


func set_size(s: int) -> void:
	size = s
	delete_cube()
	init_cube()


func delete_cube() -> void:
	for cell in cells:
		cell.queue_free()
	cells = []


func init_cube() -> void:
	var type := 0
	for j in range(size):
		for i in range(size):
			for k in range(size):
				if j > 0 and j < size - 1:
					if i > 0 and i < size - 1:
						if k > 0 and k < size - 1:
							continue
						else:
							type = Cell.Type.CENTER
					else:
						if k > 0 and k < size - 1:
							type = Cell.Type.CENTER
						else:
							type = Cell.Type.EDGE
				else:
					if i > 0 and i < size - 1:
						if k > 0 and k < size - 1:
							type = Cell.Type.CENTER
						else:
							type = Cell.Type.EDGE
					else:
						if k > 0 and k < size - 1:
							type = Cell.Type.EDGE
						else:
							type = Cell.Type.CORNER

				var cell := cell_scene.instantiate()
				cells.append(cell)
				add_child(cell)

				cell.translate(Vector3(i, j, k) - (size - 1) / 2.0 * Vector3.ONE)

				# Normalized cell coordinates
				var a := (i - size / 2.0 + 0.5) * 2 / (size - 1)
				var b := (j - size / 2.0 + 0.5) * 2 / (size - 1)
				var c := (k - size / 2.0 + 0.5) * 2 / (size - 1)
				cell.init_cell(type, a, b, c)
	update_faces_uv()
	update_colors()


func reset_cube() -> void:
	move_queue.clear()
	moves.clear()
	move_idx = 0
	for cell in cells:
		cell.reset()


func update_faces_uv(tile: bool = false) -> void:
	if tile:
		for cell in cells:
			for face in cell.faces:
				face.set_face_uv(Vector3.ONE, Vector3(0, 0, 0))
	else:
		var uv_size := Vector3.ONE / size
		for cell in cells:
			# Transform cell pos into offset-normalized cell coordinates
			var pos := cell.transform.origin as Vector3
			pos = Vector3((pos.x - size / 2.0 - 0.5) / size + 1,
					(pos.y - size / 2.0 - 0.5) / size + 1,
					(pos.z - size / 2.0 - 0.5) / size + 1)

			for face in cell.faces:
				var uv_offset := Vector3.ZERO
				var face_normal := (cell.transform * face.transform).basis.z as Vector3
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


func update_colors() -> void:
	for cell in cells:
		for face in cell.faces:
			if show_textures:
				face.set_texture(textures[face.side])
				face.set_color(Color.WHITE, false)
			else:
				face.set_texture(null)
				face.set_color(colors[face.side], true)
