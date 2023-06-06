class_name Board
extends Node2D

var round_num : int = 0
var turn_num : int = 0
var _players : Array[Player] = []
var _readied_players


func add_player(player : Player) -> void:
	if not _players.has(player):
		_players.append(player)
		turn_started.connect(player.start_turn)
		round_started.connect(player.start_round)


func end_turn():
	var ready = true
	for x in _players:
		if x.turn_completed == false:
			ready = false
	if ready:
		turn_num += 1
		turn_started.emit()

#========== TODO ==============
#All this shit should be refactored into awaits and signals so each player goes one at a time
#The players camera should be set to the currently acting player when its not their own turn

func end_round():
	turn_num = 0
	pass


func _ready() -> void:
	_load_workers()
	_load_clients()


func draw_worker(amount : int):
	return _draw_card(amount, _worker_deck, _worker_discard_deck)


func search_and_draw_worker(card : Worker) -> Worker:
	var worker = _worker_deck[_worker_deck.find(card)]
	_worker_deck.remove_at(_worker_deck.find(card))
	return worker


func draw_client(amount):
	return _draw_card(amount, _client_deck, _client_discard_deck)


func search_and_draw_client(card : Client) -> Client:
	var client = _client_deck[_client_deck.find(card)]
	_client_deck.remove_at(_client_deck.find(card))
	return client


func discard_worker(card : Worker) -> void:
	_worker_discard_deck.append(card)


func discard_client(card : Client) -> void:
	_client_discard_deck.append(card)


func _draw_card(amount : int, deck, discard):
	var array = []
	for x in amount:
		if deck.size() == 0:
			if discard.size() > 0:
				deck.append_array(discard)
				discard = []
				deck.shuffle()
			else:
				break
		array.append(deck.pop_back())
	return array


