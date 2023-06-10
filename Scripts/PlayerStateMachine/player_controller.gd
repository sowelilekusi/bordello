class_name PlayerController
extends Node

signal workers_discarded
signal workers_kept
signal turn_finished
signal round_finished

var player_info
@export var hand_position: Node2D
@export var client_position: Vector2
var hand = []
var draft_picked = []
var draft_pick_amount = 0
var reputation_points = 0
var board: PlayerBoard
var current_client: Client


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


func select_workspace(workspace):
	if current_client == null:
		return
	workspace.add_client(current_client)
	current_client = null
	rpc("end_turn")


@rpc("call_local", "reliable")
func confirm_draft():
	var discarded_cards = []
	var kept_cards = []
	for card in hand:
		if not draft_picked.has(card):
			discarded_cards.append(card.get_path())
		else:
			kept_cards.append(card.get_path())
		card.card_clicked.disconnect(select_card)
	workers_discarded.emit(discarded_cards)
	workers_kept.emit(kept_cards)
	draft_picked = []
	hand = []
	draft_pick_amount = 0


func start_turn():
	current_client = board.shift_deck.draw_card()
	if current_client == null:
		round_finished.emit()
		return
	current_client.slide_to_position(board.global_position.x, board.global_position.y, 0.0, 0.3)
	current_client.turn_front()


@rpc("call_local", "reliable")
func end_turn():
	turn_finished.emit()
