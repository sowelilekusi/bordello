extends Node2D

const SERVER_PORT := 58008
const MAX_PLAYERS := 4

var game_scene = preload("res://Scenes/Table.tscn")

var connected_players = {}
var player_info = {}

@export var seats : Array[Node2D] = [null, null, null, null]
var enet_peer = ENetMultiplayerPeer.new()
var game : Game
var players_connected = 0

@export var username_field: LineEdit
@export var IP_field: LineEdit
@export var Port_field: LineEdit

func _ready() -> void:
	game = game_scene.instantiate() as Game


func host_server() -> void:
	if username_field.text == "":
		return
	$CanvasLayer/Control/UI.visible = false
	enet_peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = enet_peer
	add_child(game)
	
	player_info[1] = username_field.text
	add_player(1, player_info[1])
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			rpc_id(new_peer_id, "add_previous_players", connected_players)
	)


func connect_to_server() -> void:
	if username_field.text == "":
		return
	$CanvasLayer/Control/UI.visible = false
	var ip = IP_field.text if IP_field.text != "" else IP_field.placeholder_text
	var port = Port_field.text if Port_field.text != "" else Port_field.placeholder_text
	enet_peer.create_client(ip, int(port))
	multiplayer.multiplayer_peer = enet_peer
	add_child(game)
	player_info[multiplayer.get_unique_id()] = username_field.text


func add_player(peer_id, username):
	connected_players[peer_id] = username
	game.add_player(peer_id, username, game.PlayerType.HUMAN)


@rpc("any_peer", "reliable")
func add_new_player(peer_id, username):
	add_player(peer_id, username)


@rpc("reliable")
func add_previous_players(players):
	for key in players:
		if players[key] == player_info[multiplayer.get_unique_id()]:
			player_info[multiplayer.get_unique_id()] += "_"
		add_player(key, players[key])
		rpc_id(key, "add_new_player", multiplayer.get_unique_id(), player_info[multiplayer.get_unique_id()])
	add_player(multiplayer.get_unique_id(), player_info[multiplayer.get_unique_id()])
