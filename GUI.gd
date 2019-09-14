extends MarginContainer

onready var main_menu = $MainMenu
onready var settings_menu = $SettingsMenu
onready var size_menu = $SizeMenu

var menu_open = true

signal gui_scramble
signal gui_reset
signal gui_change_size
signal gui_show_textures
signal gui_check_orientation

onready var time_label = $LabelTime


func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func update_time_label(time : float):
	var minutes = floor(time / 60) as int
	var seconds = (time - minutes * 60) as int
	var dec = (time - minutes * 60 - seconds) * 100 as int
	time_label.text = "Time: %02d:%02d.%02d" % [minutes, seconds, dec]


func _on_ButtonMenu_pressed():
	menu_open = !menu_open
	main_menu.visible = menu_open
	settings_menu.visible = false
	size_menu.visible = false


func _on_ButtonScramble_pressed():
	emit_signal("gui_scramble")


func _on_ButtonReset_pressed():
	emit_signal("gui_reset")


func _on_ButtonSettings_pressed():
	main_menu.visible = false
	settings_menu.visible = true


func _on_ButtonTextures_pressed():
	var state = settings_menu.get_node("VBoxContainer/ButtonTextures").pressed
	emit_signal("gui_show_textures", state)
	var orientation_button = settings_menu.get_node("VBoxContainer/ButtonOrientation")
	orientation_button.disabled = !state
	if state == false:
		orientation_button.pressed = false


func _on_ButtonOrientation_pressed():
	emit_signal("gui_check_orientation", settings_menu.get_node("VBoxContainer/ButtonOrientation").pressed)


func _on_ButtonSettingsBack_pressed():
	main_menu.visible = true
	settings_menu.visible = false


func _on_ButtonSize_pressed():
	settings_menu.visible = false
	size_menu.visible = true


func _on_ButtonSize2_pressed():
	emit_signal("gui_change_size", 2)
	settings_menu.visible = true
	size_menu.visible = false


func _on_ButtonSize3_pressed():
	emit_signal("gui_change_size", 3)
	settings_menu.visible = true
	size_menu.visible = false


func _on_ButtonSize4_pressed():
	emit_signal("gui_change_size", 4)
	settings_menu.visible = true
	size_menu.visible = false


func _on_ButtonSizeBack_pressed():
	settings_menu.visible = true
	size_menu.visible = false
