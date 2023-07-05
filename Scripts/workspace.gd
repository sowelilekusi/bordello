class_name Workspace
extends Node2D

signal clicked(Workspace)

var worker: Worker
var client: Client

@onready var _w_pos = $Worker.global_position
@onready var _c_pos = $Client.global_position

func add_worker(card: Worker) -> bool:
	if worker != null:
		return false
	worker = card
	worker.slide_to_position(_w_pos.x, _w_pos.y, 0, 0.2)
	return true


func add_client(card: Client) -> bool:
	if client != null:
		return false
	client = card
	client.slide_to_position(_c_pos.x, _c_pos.y, 0, 0.2)
	return true


func remove_client():
	var c = client
	client = null
	return c


func evaluate_match():
	if worker == null or client == null:
		return
	var points = -1
	for service in client.services:
		if worker.services.has(service):
			points += 1
	points += client.turns_left
	client.set_satisfaction(points)


func time_step(skip_ahead: bool):
	if worker == null or client == null:
		return null
	client.turns_left -= 1
	if skip_ahead:
		client.turns_left = 0
	client.update_counter()
	if client.turns_left > 0:
		return null
	else:
		return remove_client()


func _on_area2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and worker != null:
		emit_signal("clicked", self)
