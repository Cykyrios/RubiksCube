extends Spatial

onready var gui = $GUI
onready var cube = $Cube
onready var camera = $Camera

var raycast_data = [Vector3(), Vector3()]
var raycast_plane = [Vector3(), Vector3()]
var raycast_event = false
var select_event = false
var selected_face : Face = null

var moving_camera = false

var screen_touches = [Vector2(), Vector2()]

export (float, 0.2, 5) var move_threshold = 0.5
export (float, 0.2, 5) var mouse_sensitivity = 1.0
export (float, 0.2, 5) var touch_sensitivity = 1.0


func _ready():
	gui.connect("gui_scramble", self, "_on_gui_scramble")
	gui.connect("gui_reset", self, "_on_gui_reset")
	gui.connect("gui_change_size", self, "_on_gui_change_size")
	
	var cam_offset = camera.global_transform.origin
	camera.transform = camera.transform.translated(-cam_offset).rotated(Vector3.RIGHT, -PI / 6
			).rotated(Vector3.UP, PI / 6).translated(cam_offset)


#func _process(delta):
#	pass


func _physics_process(delta):
	if raycast_event:
		raycast_event = false
		if select_event:
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(raycast_data[0], raycast_data[1])
			if result and result.collider is Face:
				selected_face = result.collider as Face
				highlight_selection(true)
				raycast_plane[0] = selected_face.global_transform.basis.z
				raycast_plane[1] = result.position
			else:
				selected_face = null
		else:
			if selected_face:
				# intersect raycast with plane from first raycast
				var direction = (raycast_data[1] - raycast_data[0]).normalized()
				var n = raycast_plane[0]
				var p = raycast_plane[1]
				var l = raycast_data[0]
				var d = (p - l).dot(n) / direction.dot(n)
				var intersection = l + d * direction
				var move = intersection - p
				if d < 0:
					move = -move
				highlight_selection(false)
				
				var view = camera.get_viewport().size
				var unproj = camera.unproject_position(intersection) - camera.unproject_position(p)
				if unproj.length() >= 0.1 * move_threshold * min(view.x, view.y):
					process_move(move)
				selected_face = null


func _input(event):
	if not gui.menu_open:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.is_pressed():
					select_event = true
				else:
					select_event = false
			
				cast_ray(event.position)
			
			elif event.button_index == BUTTON_RIGHT:
				if event.is_pressed():
					moving_camera = true
					cancel_selection()
				else:
					moving_camera = false
		
			elif event.button_index == BUTTON_WHEEL_DOWN:
					if camera.global_transform.origin.length() < cube.size * 3:
						camera.translate_object_local(Vector3(0, 0, 0.5))
			elif event.button_index == BUTTON_WHEEL_UP:
					if camera.global_transform.origin.length() > cube.size * 1.5:
						camera.translate_object_local(Vector3(0, 0, -0.5))
		
		elif event is InputEventMouseMotion and moving_camera:
			var delta = event.relative / 300 * mouse_sensitivity
			var pos = camera.transform.origin
			camera.transform = camera.transform.translated(-pos).rotated(camera.global_transform.basis.x,
					-delta.y).rotated(camera.global_transform.basis.y, -delta.x).translated(pos)
		
		elif event is InputEventScreenTouch:
			if event.index == 0:
				if event.is_pressed():
					screen_touches[0] = event.position
					select_event = true
				else:
					select_event = false
					if moving_camera:
						moving_camera = false
				cast_ray(event.position)
			elif event.index == 1:
				if event.is_pressed():
					screen_touches[1] = event.position
					moving_camera = true
					cancel_selection()
		
		elif event is InputEventScreenDrag:
			if moving_camera and event.index <= 1:
				var idx = event.index
				var pos = camera.transform.origin
				var basis = camera.global_transform.basis
				var rot_z = (screen_touches[idx] - screen_touches[idx - 1]).angle_to(event.position - screen_touches[idx - 1])
				var rot_x = -(event.position.x - screen_touches[idx].x) / 1000 * touch_sensitivity
				var rot_y = -(event.position.y - screen_touches[idx].y) / 1000 * touch_sensitivity
				var zoom = -((event.position - screen_touches[idx - 1]).length()
						- (screen_touches[idx] - screen_touches[idx - 1]).length()) / 200
				if camera.global_transform.origin.length() < cube.size * 1.5 and zoom < 0:
					zoom = 0
				if camera.global_transform.origin.length() > cube.size * 3 and zoom > 0:
					zoom = 0
				camera.transform = camera.transform.translated(-pos).rotated(basis.z, rot_z
						).rotated(basis.x, rot_y).rotated(basis.y, rot_x).translated(pos).translated(Vector3(0, 0, zoom))
				screen_touches[idx] = event.position


func cast_ray(screen_pos : Vector2):
	raycast_event = true
	var distance = camera.global_transform.origin.length() * 2
	raycast_data[0] = camera.project_ray_origin(screen_pos)
	raycast_data[1] = raycast_data[0] + camera.project_ray_normal(screen_pos) * distance


func cancel_selection():
	if select_event:
		select_event = false
		if selected_face:
			highlight_selection(false)
			selected_face = null


func highlight_selection(enabled : bool):
	selected_face.mat.emission_enabled = enabled


func process_move(vec : Vector3):
	var face_basis = selected_face.global_transform.basis
	var cube_basis = cube.global_transform.basis
	var dot = face_basis.z.dot(cube_basis.x)
	if abs(dot) > 0.9:
		cube.move_from_raycast(selected_face, Vector3(1, 0, 0) * sign(dot), vec)
	else:
		dot = face_basis.z.dot(cube_basis.y)
		if abs(dot) > 0.9:
			cube.move_from_raycast(selected_face, Vector3(0, 1, 0) * sign(dot), vec)
		else:
			dot = face_basis.z.dot(cube_basis.z)
			cube.move_from_raycast(selected_face, Vector3(0, 0, 1) * sign(dot), vec)


func _on_gui_scramble():
	cube.scramble_cube()


func _on_gui_reset():
	cube.reset_cube()


func _on_gui_change_size(size : int):
	cube.set_size(size)
	print("yay")
