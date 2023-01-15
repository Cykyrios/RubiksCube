extends Node3D

signal first_move_made

@export_range(0.2, 5) var move_threshold := 0.5
@export_range(0.2, 5) var mouse_sensitivity := 1.0
@export_range(0.2, 5) var touch_sensitivity := 1.0

var raycast_data := [Vector3(), Vector3()]
var raycast_plane := [Vector3(), Vector3()]
var raycast_event := false
var select_event := false
var selected_face: Face = null

var moving_camera := false

var screen_touches := [Vector2(), Vector2()]

var ready_to_solve := false
var solving := false
var timer_running := false
var time := 0.0

@onready var gui := %GUI
@onready var cube := %Cube
@onready var camera := %Camera3D as Camera3D


func _ready() -> void:
	first_move_made.connect(_on_first_move)

	cube.solved.connect(_on_cube_solved)

	gui.gui_scramble.connect(_on_gui_scramble)
	gui.gui_reset.connect(_on_gui_reset)
	gui.gui_change_size.connect(_on_gui_change_size)
	gui.gui_show_textures.connect(_on_gui_show_textures)
	gui.gui_check_orientation.connect(_on_gui_check_orientation)

	var cam_offset := camera.global_transform.origin
	camera.transform = camera.transform.translated_local(-cam_offset).rotated(Vector3.RIGHT, -PI / 6.0
			).rotated(Vector3.UP, PI / 6.0 * 4 / 3.0).translated_local(cam_offset)

	if OS.has_feature("mobile"):
		$QualityLights.queue_free()
	else:
		$Camera3D/PerformanceLights.queue_free()


func _process(delta: float) -> void:
	if timer_running:
		time += delta
		gui.update_time_label(time)


func _physics_process(_delta: float) -> void:
	if raycast_event:
		raycast_event = false
		if select_event:
			var space_state := get_world_3d().direct_space_state
			var raycast_query := PhysicsRayQueryParameters3D.create(raycast_data[0], raycast_data[1])
			var result := space_state.intersect_ray(raycast_query)
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
				var direction := (raycast_data[1] - raycast_data[0]).normalized()
				var n := raycast_plane[0]
				var p := raycast_plane[1]
				var l := raycast_data[0]
				var d := (p - l).dot(n) / direction.dot(n)
				var intersection := l + d * direction
				var move := intersection - p
				if d < 0:
					move = -move
				highlight_selection(false)

				var view := camera.get_window().size
				var unproj := camera.unproject_position(intersection) - camera.unproject_position(p)
				if unproj.length() >= 0.1 * move_threshold * min(view.x, view.y):
					process_move(move)
					if ready_to_solve:
						first_move_made.emit()
				selected_face = null


func _input(event: InputEvent) -> void:
	if not gui.menu_open:
		if event is InputEventMouseButton:
			var button_event := event as InputEventMouseButton
			if button_event.button_index == MOUSE_BUTTON_LEFT:
				if button_event.pressed:
					select_event = true
				else:
					select_event = false
				cast_ray(button_event.position)
			elif button_event.button_index == MOUSE_BUTTON_RIGHT:
				if button_event.pressed:
					moving_camera = true
					cancel_selection()
				else:
					moving_camera = false
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					if camera.global_transform.origin.length() < cube.size * 4:
						camera.translate_object_local(Vector3(0, 0, 0.5))
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
					if camera.global_transform.origin.length() > cube.size * 2:
						camera.translate_object_local(Vector3(0, 0, -0.5))

		elif event is InputEventMouseMotion and moving_camera:
			var delta := (event as InputEventMouseMotion).relative / 300 * mouse_sensitivity
			var pos := camera.transform.origin
			camera.transform = camera.transform.translated_local(-pos).rotated(camera.global_transform.basis.x,
					-delta.y).rotated(camera.global_transform.basis.y, -delta.x).translated_local(pos)

		elif event is InputEventScreenTouch:
			var touch_event := event as InputEventScreenTouch
			if touch_event.index == 0:
				if touch_event.pressed:
					screen_touches[0] = touch_event.position
					select_event = true
				else:
					select_event = false
					if moving_camera:
						moving_camera = false
				cast_ray(touch_event.position)
			elif touch_event.index == 1:
				if touch_event.pressed:
					screen_touches[1] = touch_event.position
					moving_camera = true
					cancel_selection()

		elif event is InputEventScreenDrag:
			var drag_event := event as InputEventScreenDrag
			if moving_camera and drag_event.index <= 1:
				var idx := drag_event.index
				var pos := camera.transform.origin
				var camera_basis := camera.global_transform.basis
				var rot_z := (screen_touches[idx] - screen_touches[idx - 1]).angle_to(
						drag_event.position - screen_touches[idx - 1])
				var rot_x := -(drag_event.position.x - screen_touches[idx].x) / 1000 * touch_sensitivity
				var rot_y := -(drag_event.position.y - screen_touches[idx].y) / 1000 * touch_sensitivity
				var zoom := -((drag_event.position - screen_touches[idx - 1]).length()
						- (screen_touches[idx] - screen_touches[idx - 1]).length()) / 200
				if camera.global_transform.origin.length() < cube.size * 1.5 and zoom < 0:
					zoom = 0
				if camera.global_transform.origin.length() > cube.size * 3 and zoom > 0:
					zoom = 0
				camera.transform = camera.transform.translated_local(-pos).rotated(camera_basis.z, rot_z
						).rotated(camera_basis.x, rot_y).rotated(camera_basis.y, rot_x).translated_local(pos
						).translated_local(Vector3(0, 0, zoom))
				screen_touches[idx] = drag_event.position


func cast_ray(screen_pos: Vector2) -> void:
	raycast_event = true
	var distance := camera.global_transform.origin.length() * 2
	raycast_data[0] = camera.project_ray_origin(screen_pos)
	raycast_data[1] = raycast_data[0] + camera.project_ray_normal(screen_pos) * distance


func cancel_selection() -> void:
	if select_event:
		select_event = false
		if selected_face:
			highlight_selection(false)
			selected_face = null


func highlight_selection(enabled: bool) -> void:
	selected_face.mat.emission_enabled = enabled


func process_move(vec: Vector3) -> void:
	var face_basis := selected_face.global_transform.basis
	var cube_basis := cube.global_transform.basis as Basis
	var dot := face_basis.z.dot(cube_basis.x)
	if absf(dot) > 0.9:
		cube.move_from_raycast(selected_face, Vector3(1, 0, 0) * signf(dot), vec)
	else:
		dot = face_basis.z.dot(cube_basis.y)
		if absf(dot) > 0.9:
			cube.move_from_raycast(selected_face, Vector3(0, 1, 0) * signf(dot), vec)
		else:
			dot = face_basis.z.dot(cube_basis.z)
			cube.move_from_raycast(selected_face, Vector3(0, 0, 1) * signf(dot), vec)


func _on_gui_scramble() -> void:
	cube.scramble_cube()
	solving = false
	ready_to_solve = true
	time = 0.0
	timer_running = false
	gui.update_time_label(time)


func _on_gui_reset() -> void:
	cube.reset_cube()
	solving = false
	ready_to_solve = false
	time = 0.0
	timer_running = false
	gui.update_time_label(time)


func _on_gui_change_size(size: int) -> void:
	cube.set_size(size)
	solving = false
	time = 0.0
	timer_running = false
	gui.update_time_label(time)


func _on_gui_show_textures(show_textures: bool) -> void:
	cube.show_textures = show_textures
	cube.update_colors()


func _on_gui_check_orientation(check_orientation: bool) -> void:
	cube.check_orientation = check_orientation


func _on_first_move() -> void:
	ready_to_solve = false
	solving = true
	reset_timer()
	start_timer()


func _on_cube_solved() -> void:
	if solving:
		stop_timer()
		gui.update_time_label(time)
		solving = false
		print("Solved!")
		var popup := PanelContainer.new()
		var vbox := VBoxContainer.new()
		var label := Label.new()
		label.text = "Well done!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var button := Button.new()
		button.text = "Close"
		vbox.add_child(label)
		vbox.add_child(button)
		popup.add_child(vbox)
		gui.add_child(popup)
		popup.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		popup.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		button.pressed.connect(func(): popup.queue_free())


func start_timer() -> void:
	timer_running = true


func stop_timer() -> void:
	timer_running = false


func reset_timer() -> void:
	time = 0.0
	gui.update_time_label(time)
