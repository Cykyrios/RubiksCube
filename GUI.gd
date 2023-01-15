extends MarginContainer

signal gui_scramble
signal gui_reset
signal gui_change_size
signal gui_show_textures
signal gui_check_orientation

@onready var main_menu := %MainMenu as VBoxContainer
@onready var button_settings := %ButtonSettings as Button
@onready var button_scramble := %ButtonScramble as Button
@onready var button_reset := %ButtonReset as Button

@onready var settings_menu := %SettingsMenu as VBoxContainer
@onready var button_size := %ButtonSize as Button
@onready var button_textures := %ButtonTextures as CheckButton
@onready var button_orientation := %ButtonOrientation as CheckButton
@onready var button_settings_back := %ButtonSettingsBack as Button

@onready var size_menu := %SizeMenu as VBoxContainer
@onready var button_size_2 := %ButtonSize2 as Button
@onready var button_size_3 := %ButtonSize3 as Button
@onready var button_size_4 := %ButtonSize4 as Button
@onready var button_size_back := %ButtonSizeBack as Button

@onready var time_label := %LabelTime as Label
@onready var button_menu := %ButtonMenu as TextureButton

var menu_open := true


func _ready() -> void:
	button_settings.pressed.connect(_on_button_settings_pressed)
	button_scramble.pressed.connect(_on_button_scramble_pressed)
	button_reset.pressed.connect(_on_button_reset_pressed)

	button_size.pressed.connect(_on_button_size_pressed)
	button_textures.pressed.connect(_on_button_textures_pressed)
	button_orientation.pressed.connect(_on_button_orientation_pressed)
	button_settings_back.pressed.connect(_on_button_settings_back_pressed)

	button_size_2.pressed.connect(_on_button_size_2_pressed)
	button_size_3.pressed.connect(_on_button_size_3_pressed)
	button_size_4.pressed.connect(_on_button_size_4_pressed)
	button_size_back.pressed.connect(_on_button_size_back_pressed)

	button_menu.pressed.connect(_on_button_menu_pressed)


func change_cube_size(cube_size: int) -> void:
	gui_change_size.emit(cube_size)
	settings_menu.visible = true
	size_menu.visible = false


func update_time_label(time: float) -> void:
	var minutes := floori(time / 60)
	var seconds := floori(time - minutes * 60)
	var dec := floori((time - minutes * 60 - seconds) * 100 as float)
	time_label.text = "Time: %02d:%02d.%02d" % [minutes, seconds, dec]


func _on_button_menu_pressed() -> void:
	menu_open = !menu_open
	main_menu.visible = menu_open
	settings_menu.visible = false
	size_menu.visible = false


func _on_button_scramble_pressed() -> void:
	gui_scramble.emit()


func _on_button_reset_pressed() -> void:
	gui_reset.emit()


func _on_button_settings_pressed() -> void:
	main_menu.visible = false
	settings_menu.visible = true


func _on_button_textures_pressed() -> void:
	var state := button_textures.button_pressed
	gui_show_textures.emit(state)
	button_orientation.disabled = !state
	if state == false:
		button_orientation.button_pressed = false


func _on_button_orientation_pressed() -> void:
	gui_check_orientation.emit(button_orientation.button_pressed)


func _on_button_settings_back_pressed() -> void:
	main_menu.visible = true
	settings_menu.visible = false


func _on_button_size_pressed() -> void:
	settings_menu.visible = false
	size_menu.visible = true


func _on_button_size_2_pressed() -> void:
	change_cube_size(2)


func _on_button_size_3_pressed() -> void:
	change_cube_size(3)


func _on_button_size_4_pressed() -> void:
	change_cube_size(4)


func _on_button_size_back_pressed() -> void:
	settings_menu.visible = true
	size_menu.visible = false
