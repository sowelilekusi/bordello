class_name PlayerController
extends Node

signal workers_discarded
signal workers_kept

var player_info
@export var hand_position: Node2D
var hand = []
var draft_picked = []
var draft_pick_amount = 0


func draft(cards, pick):
	draft_pick_amount = pick
	var xxx = (250.0 * cards.size()) / 2.0
	for x in cards.size():
		var card = cards[x]
		var ratio = float(x) / float(cards.size() - 1)
		var xx = lerpf(-1 * xxx, xxx, ratio)
		card.slide_to_position(hand_position.global_position.x + xx - 125.0, hand_position.global_position.y - 175.0, 0.0, 0.2)
		hand.append(card)
		card.card_clicked.connect(select_card)


func select_card(card):
	if not draft_picked.has(card) and draft_picked.size() < draft_pick_amount:
		draft_picked.append(card)
		card.slide_to_position(card.position.x, card.position.y - 50.0, 0.0, 0.1)
	elif draft_picked.has(card):
		draft_picked.remove_at(draft_picked.find(card))
		card.slide_to_position(card.position.x, card.position.y + 50.0, 0.0, 0.1)


@rpc("call_local")
func confirm_draft():
	var discarded_cards = []
	var kept_cards = []
	for card in hand:
		if not draft_picked.has(card):
			discarded_cards.append(card.get_path())
		else:
			kept_cards.append(card.get_path())
	workers_discarded.emit(discarded_cards)
	workers_kept.emit(kept_cards)
