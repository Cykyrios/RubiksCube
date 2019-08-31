extends Spatial

export var speed = 1.0
export var sensitivity = 0.1

var rotation_helper
var camera

var dragging

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_helper = $RotationHelper
	camera = $RotationHelper/Camera

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			if event.is_pressed():
				dragging = true
			else:
				dragging = false
		elif event.button_index == BUTTON_WHEEL_DOWN:
			camera.translate_object_local(Vector3(0, 0, 0.5))
		elif event.button_index == BUTTON_WHEEL_UP:
			camera.translate_object_local(Vector3(0, 0, -0.5))
	elif event is InputEventMouseMotion:
		if dragging:
			var mouse_rot = Vector2(event.relative.x, event.relative.y)
			var rot_max = min(deg2rad(mouse_rot.y * sensitivity) * sign(mouse_rot.y), speed)
			rotation_helper.rotate_x(rot_max * sign(mouse_rot.y) * -1)
			rot_max = min(deg2rad(mouse_rot.x * sensitivity) * sign(mouse_rot.x), speed)
			self.rotate_y(rot_max * sign(mouse_rot.x) * -1)
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -89.9, 89.9)
			rotation_helper.rotation_degrees = camera_rot
