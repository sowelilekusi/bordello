class_name PlayerController
extends Node

signal workers_discarded
signal workers_kept
signal turn_finished
signal round_finished(int)
signal hire_pressed(String)

var player_info
@export var hand_position: Node2D
@export var client_position: Vector2
@export var player_cam: Camera2D
var hand = []
var draft_picked = []
var draft_pick_amount = 0
var reputation_points = 0
var money = 40
var money_delta = 0
var board: PlayerBoard
var current_client: Client
var current_workspace: Workspace


func draft(cards, pick):
	draft_pick_amount = pick
	var xxx = (250.0 * cards.size()) / 2.0
	for x in cards.size():
		var card = cards[x]
		var ratio = float(x) / float(cards.size() - 1)
		var xx = lerpf(-1 * xxx, xxx, ratio)
		var h = hand_position.global_position
		card.slide_to_position(h.x + xx - 125.0, h.y - 175.0, 0.0, 0.2)
		hand.append(card)
		card.card_clicked.connect(select_card)


func select_card(card):
	if not is_multiplayer_authority():
		return
	if not draft_picked.has(card) and draft_picked.size() < draft_pick_amount:
		draft_picked.append(card)
		rpc("networked_select_card", true, card.get_path())
		card.slide_to_position(card.position.x, card.position.y - 50.0, 0.0, 0.1)
	elif draft_picked.has(card):
		draft_picked.remove_at(draft_picked.find(card))
		rpc("networked_select_card", false, card.get_path())
		card.slide_to_position(card.position.x, card.position.y + 50.0, 0.0, 0.1)


@rpc("reliable")
func networked_select_card(add, card_path):
	if add:
		draft_picked.append(get_node(card_path))
	else:
		draft_picked.remove_at(draft_picked.find(get_node(card_path)))


func select_workspace(workspace):
	if not is_multiplayer_authority():
		return false
	if current_client == null or workspace.worker == null or workspace.worker.stress >= workspace.worker.capacity:
		return false
	if workspace == current_workspace or workspace.client != null:
		return false
	if current_workspace != null:
		current_workspace.remove_client()
	current_workspace = workspace
	rpc("networked_select_workspace", workspace.get_path(), current_client.get_path())
	current_client.show_time_selector()
	return true


func on_poor_discard_deck_clicked():
	if not is_multiplayer_authority() or current_client == null:
		return
	rpc("turn_away_client")


@rpc("call_local", "reliable")
func turn_away_client():
	board.poor_deck.place(current_client)
	current_client.set_satisfaction(0)
	if current_workspace != null:
		current_workspace.remove_client()
	current_workspace = null
	#current_client = null


@rpc("call_local", "reliable")
func networked_select_workspace(workspace_path, current_client_path):
	if board.poor_deck.cards.has(get_node(current_client_path)):
		board.poor_deck.cards.remove_at(board.poor_deck.cards.find(get_node(current_client_path)))
	get_node(workspace_path).add_client(get_node(current_client_path))
	get_node(workspace_path).evaluate_match()


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
	var pos: Vector2
	pos.x = board.client_view_position.global_position.x
	pos.y = board.client_view_position.global_position.y
	current_client.slide_to_position(pos.x, pos.y, 0.0, 0.3)
	current_client.turn_front()


func end_of_round():
	board.time_step(true)
	reputation_points += board.process_decks()
	if reputation_points < 0:
		reputation_points = 0
	round_finished.emit(player_info["id"])


@rpc("call_local", "reliable")
func end_turn():
	if current_workspace != null:
		rpc("networked_select_workspace", current_workspace.get_path(), current_client.get_path())
	board.time_step(false)
	current_client = null
	current_workspace = null
	money += money_delta
	money_delta = 0
	if board.shift_deck.cards.size() == 0:
		end_of_round()
	turn_finished.emit()


@rpc("call_local", "reliable")
func attempt_hire():
	if board.empty_slots() < 1 or money < 50:
		return
	print("attempt hire didnt fail")
	money -= 50
	hire_pressed.emit(player_info["username"])
