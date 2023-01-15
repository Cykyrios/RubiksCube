extends Node3D

@export var speed := 1.0
@export var sensitivity := 0.1

var dragging := false

@onready var rotation_helper := $RotationHelper as Node3D
@onready var camera := $RotationHelper/Camera3D as Camera3D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = true if button_event.pressed else false
		elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.translate_object_local(Vector3(0, 0, 0.5))
		elif button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.translate_object_local(Vector3(0, 0, -0.5))
	elif event is InputEventMouseMotion:
		if dragging:
			var mouse_event := event as InputEventMouseMotion
			var mouse_rot := Vector2(mouse_event.relative.x, mouse_event.relative.y)
			var rot_max := minf(deg_to_rad(mouse_rot.y * sensitivity) * signf(mouse_rot.y), speed)
			rotation_helper.rotate_x(rot_max * signf(mouse_rot.y) * -1)
			rot_max = minf(deg_to_rad(mouse_rot.x * sensitivity) * signf(mouse_rot.x), speed)
			self.rotate_y(rot_max * signf(mouse_rot.x) * -1)
			var camera_rot := rotation_helper.rotation_degrees
			camera_rot.x = clampf(camera_rot.x, -89.9, 89.9)
			rotation_helper.rotation_degrees = camera_rot
