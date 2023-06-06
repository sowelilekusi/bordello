extends Node2D

signal button_pushed(button)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("button_pushed", self)
