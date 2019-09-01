extends Spatial

onready var cube = $Cube
onready var camera = $OrbitCamera/RotationHelper/Camera

var raycast_data = [Vector3(), Vector3()]
var raycast_plane = [Vector3(), Vector3()]
var raycast_event = false
var select_event = false
var selected_face = null



func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func _physics_process(delta):
	if raycast_event:
		raycast_event = false
		if select_event:
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(raycast_data[0], raycast_data[1])
			if result and result.collider is Face:
				selected_face = result.collider
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
				selected_face = null


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				select_event = true
			else:
				select_event = false
			
			raycast_event = true
			var distance = camera.global_transform.origin.length() * 2
			raycast_data[0] = camera.project_ray_origin(event.position)
			raycast_data[1] = raycast_data[0] + camera.project_ray_normal(event.position) * distance
