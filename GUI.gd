extends MarginContainer

onready var main_menu = $MainMenu
onready var size_menu = $SizeMenu

var menu_open = true

signal gui_scramble
signal gui_reset
signal gui_change_size


func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func _on_ButtonMenu_pressed():
	menu_open = !menu_open
	main_menu.visible = menu_open
	size_menu.visible = false


func _on_ButtonScramble_pressed():
	emit_signal("gui_scramble")


func _on_ButtonReset_pressed():
	emit_signal("gui_reset")


func _on_ButtonSize_pressed():
	main_menu.visible = false
	size_menu.visible = true


func _on_ButtonSize2_pressed():
	emit_signal("gui_change_size", 2)
	main_menu.visible = true
	size_menu.visible = false


func _on_ButtonSize3_pressed():
	emit_signal("gui_change_size", 3)
	main_menu.visible = true
	size_menu.visible = false


func _on_ButtonSize4_pressed():
	emit_signal("gui_change_size", 4)
	main_menu.visible = true
	size_menu.visible = false