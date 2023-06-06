class_name Board
extends Node2D

signal turn_started
signal round_started

const WORKER_DECK_SAVE_PATH = "user://worker_deck.json"
const CLIENT_DECK_SAVE_PATH = "user://client_deck.json"

var round_num : int = 0
var turn_num : int = 0
var _players : Array[Player] = []
var _readied_players
var _worker_deck : Array[Worker] = []
var _worker_discard_deck : Array[Worker] = []
var _client_deck : Array[Client] = []
var _client_discard_deck : Array[Client] = []
var _worker_scene = preload("res://Scenes/worker_card.tscn")
var _client_scene = preload("res://Scenes/client_card.tscn")


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


func _load_workers():
	if !FileAccess.file_exists(WORKER_DECK_SAVE_PATH):
		return
	var save_game = FileAccess.open(WORKER_DECK_SAVE_PATH, FileAccess.READ)
	var card_dict = JSON.parse_string(save_game.get_line())
	for key in card_dict:
		var value = card_dict[key]
		var card_instance = _worker_scene.instantiate()
		#JSON only returns floats so we have to get ints out of the dict
		var bonuses = []
		for x in value.slice(1, value.size()):
			bonuses.append(int(x))
		card_instance.setup(key, int(value[0]), bonuses)
		card_instance.position = Vector2(9999, 9999)
		#card_instance.scale = Vector2(1, 1)
		#card_instance.visible = false
		#card_instance.set_process(false)
		#card_instance.card_clicked.connect(select_card)
		_worker_deck.append(card_instance)
		add_child(card_instance)
	_worker_deck.shuffle()


func _load_clients():
	if !FileAccess.file_exists(CLIENT_DECK_SAVE_PATH):
		return
	var save_game = FileAccess.open(CLIENT_DECK_SAVE_PATH, FileAccess.READ)
	var card_dict = JSON.parse_string(save_game.get_line())
	for key in card_dict:
		var value = card_dict[key]
		var card_instance = _client_scene.instantiate()
		#JSON only returns floats so we have to get ints out of the dict
		var bool_array = []
		var int_array = []
		for x in value.slice(1, 5):
			bool_array.append(bool(x))
		for x in value.slice(5, value.size()):
			int_array.append(int(x))
		card_instance.setup(key, int(value[0]), bool_array, int_array)
		card_instance.position = Vector2(9999, 9999)
		#card_instance.scale = Vector2(1, 1)
		_client_deck.append(card_instance)
		add_child(card_instance)
	_client_deck.shuffle()


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

#Ideas okay?
#Make the client cards have a little progress track thats like how much they like their service right,
#put the poor/good/great blocks along that track, and instead of the services having that each service 
#contributes a different number of points along that other track, so the money you recieve for making
#the match can be the same across all clients, but it shows how some clients value one more over the other
#without actually requiring you to have any specific one as long as you have enough turns to get them along
#the track, so a short session with all the perks can be a great service but a less special or less
#stress inducing session needs to be longer so the same worker needs to remain occupied longer, and it gives
#you more to do on your turn because you get to decide what all your little workers do rather than them only
#being interacted with when you're placing down a client card
