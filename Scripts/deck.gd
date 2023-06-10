class_name Deck
extends Node2D

signal clicked
signal mouse_entered
signal mouse_exited

enum Type {WORKER, CLIENT}

@export var type: Type
var cards: Array[Card] = []

@onready var _w_pos = $Worker.global_position
@onready var _c_pos = $Client.global_position

func _ready() -> void:
	match type:
		Type.WORKER:
			$Area2D/WorkerShape.disabled = false
			$Area2D/ClientSprite.visible = false
		Type.CLIENT:
			$Area2D/ClientShape.disabled = false
			$Area2D/WorkerSprite.visible = false


func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked.emit()


func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit()


func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit()


func draw_card() -> Card:
	if cards.size() == 0:
		return null
	return cards.pop_back()


func place(card: Card) -> void:
	cards.append(card)
	match type:
		Type.WORKER:
			card.slide_to_position(_w_pos.x, _w_pos.y, 0.0, 0.2)
		Type.CLIENT:
			card.slide_to_position(_c_pos.x, _c_pos.y, 0.0, 0.2)


func shuffle() -> void:
	cards.shuffle()


func order(node_paths) -> void:
	cards = []
	for path in node_paths:
		cards.append(get_node(path))
