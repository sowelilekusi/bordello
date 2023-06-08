class_name Game
extends Node2D

signal game_paused
signal game_resumed
signal turn_started
signal round_started

enum PlayerType {HUMAN, BOT}

const WORKER_DECK_SAVE_PATH = "user://worker_deck.json"
const CLIENT_DECK_SAVE_PATH = "user://client_deck.json"

@export var worker_deck: Deck
@export var client_deck: Deck
@export var worker_discard: Deck
@export var client_discard: Deck
@export var seat1: Node2D
@export var seat2: Node2D
@export var seat3: Node2D
@export var seat4: Node2D

var networked_controllers: Array[HumanController] = []
var current_player := 0
var players: Array[PlayerController] = []
var readied_players: Array[int] = []

var _worker_scene = preload("res://Scenes/worker_card.tscn")
var _client_scene = preload("res://Scenes/client_card.tscn")
var _player_scene = preload("res://Scenes/player_board.tscn")
var _human_scene = preload("res://Scenes/human_player.tscn")
var _bot_scene = preload("res://Scenes/bot_player.tscn")

func _ready() -> void:
	_load_workers()
	_load_clients()


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
		add_child(card_instance)
		worker_deck.place(card_instance)
	worker_deck.shuffle()


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
		add_child(card_instance)
		client_deck.place(card_instance)
	client_deck.shuffle()


@rpc #Called by the network lobby code
func add_player(id: int, username: String, type: PlayerType) -> void:
	if players.size() > 4:
		return
	if type == null:
		type = PlayerType.HUMAN
	var board = _player_scene.instantiate()
	match players.size():
		0:
			board.global_position = seat1.position
		1:
			board.global_position = seat2.position
		2:
			board.global_position = seat3.position
		3:
			board.global_position = seat4.position
	$Players.add_child(board)
	var controller
	match type:
		PlayerType.HUMAN:
			controller = _human_scene.instantiate()
			networked_controllers.append(controller)
			controller.ready_button_pressed.connect(ready_player)
			controller.chat_message_submitted.connect(message)
			var player_info = {}
			player_info["id"] = id
			player_info["username"] = username
			controller.player_info = player_info
		PlayerType.BOT:
			controller = _bot_scene.instantiate()
	controller.name = str(id)
	controller.set_multiplayer_authority(id)
	board.add_child(controller)
	players.append(controller)
	for player in networked_controllers:
		player.rpc("update_ready_label", readied_players.size(), players.size())


@rpc("call_local", "any_peer") #called from message() by player signals
func relay_chat_message(msg):
	for player in networked_controllers:
		player.add_chat_line(msg)


func message(msg):
	rpc("relay_chat_message", msg)


func ready_player(id):
	if not readied_players.has(id):
		readied_players.append(id)
	if readied_players.size() == players.size():
		start_game()
	for player in networked_controllers:
		player.rpc("update_ready_label", readied_players.size(), players.size())


func start_game():
	#Only the host should shuffle the decks
	if is_multiplayer_authority():
		randomize()
		var deck_order = []
		for card in worker_deck.cards:
			deck_order.append(card.get_path())
		rpc("send_worker_order", deck_order)
		deck_order = []
		for card in client_deck.cards:
			deck_order.append(card.get_path())
		rpc("send_client_order", deck_order)
		for player in players:
			rpc("draft_workers", player.player_info["username"], 4, 2)


@rpc
func send_worker_order(node_paths):
	worker_deck.order(node_paths)


@rpc
func send_client_order(node_paths):
	client_deck.order(node_paths)


@rpc("call_local")
func draft_workers(player, draw_amount, pick_amount):
	var cards = []
	for x in draw_amount:
		cards.append(worker_deck.draw_card())
	for x in players:
		if x.player_info["username"] == player:
			x.draft(cards, pick_amount)
