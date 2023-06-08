class_name PlayerController
extends Node

var player_info
@export var hand_position: Node2D
var hand = []


func draft(cards, _pick):
	var xxx = (250.0 * cards.size()) / 2.0
	for x in cards.size():
		var card = cards[x]
		var ratio = float(x) / float(cards.size() - 1)
		var xx = lerpf(-1 * xxx, xxx, ratio)
		card.slide_to_position(hand_position.global_position.x + xx, hand_position.global_position.y, 0.0, 0.2)
		hand.append(card)
