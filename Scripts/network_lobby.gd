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

func _ready() -> void:
	game = game_scene.instantiate() as Game
	


func host_server() -> void:
	if $UI/Username.text == "":
		return
	$UI.visible = false
	enet_peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = enet_peer
	add_child(game)
	
	player_info[1] = $UI/Username.text
	add_player(1, player_info[1])
	game.get_node("LobbyCamera/LineEdit").text_submitted.connect(text_message)
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			rpc_id(new_peer_id, "add_previous_players", connected_players)
			#rpc("add_new_player", new_peer_id)
	)


func connect_to_server() -> void:
	if $UI/Username.text == "":
		return
	$UI.visible = false
	var ip = $UI/IPField.text if $UI/IPField.text != "" else $UI/IPField.placeholder_text
	var port = $UI/PortField.text if $UI/PortField.text != "" else $UI/PortField.placeholder_text
	enet_peer.create_client(ip, int(port))
	multiplayer.multiplayer_peer = enet_peer
	add_child(game)
	player_info[multiplayer.get_unique_id()] = $UI/Username.text

func add_player(peer_id, username):
	connected_players[peer_id] = username
	game.add_player(peer_id, username, game.PlayerType.HUMAN)


@rpc("any_peer")
func add_new_player(peer_id, username):
	add_player(peer_id, username)


func text_message(new_text):
	game.get_node("LobbyCamera/RichTextLabel").rpc("add_line", player_info[multiplayer.get_unique_id()], new_text)
	game.get_node("LobbyCamera/LineEdit").text = ""


@rpc
func add_previous_players(players):
	for key in players:
		add_player(key, players[key])
		rpc_id(key, "add_new_player", multiplayer.get_unique_id(), player_info[multiplayer.get_unique_id()])
	add_player(multiplayer.get_unique_id(), player_info[multiplayer.get_unique_id()])
	game.get_node("LobbyCamera/LineEdit").text_submitted.connect(text_message)
