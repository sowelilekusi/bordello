extends Control

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/worker_editor.tscn")

func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/client_editor.tscn")

func _on_play_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")

func _on_check_button_toggled(button_pressed):
	if button_pressed:
		$"Worker Deck".visible = true
		$"Task Deck".visible = true
	if not button_pressed:
		$"Worker Deck".visible = false
		$"Task Deck".visible = false
