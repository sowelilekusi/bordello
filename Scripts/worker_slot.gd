extends Node2D

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
