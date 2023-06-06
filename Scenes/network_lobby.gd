extends Node2D

const SERVER_PORT := 58008
const MAX_PLAYERS := 4

var player_scene = preload("res://Scenes/player.tscn")
var board_scene = preload("res://Scenes/board.tscn")

@export var seats : Array[Node2D] = [null, null, null, null]
var enet_peer = ENetMultiplayerPeer.new()
var board : Board
var players_connected = 0


func _ready() -> void:
	seats[0] = $TablePosition1
	seats[1] = $TablePosition2
	seats[2] = $TablePosition3
	seats[3] = $TablePosition4


func host_server() -> void:
	$UI.visible = false
	
	enet_peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(create_player)
	create_player(multiplayer.get_unique_id())


func connect_to_server() -> void:
	$UI.visible = false
	
	var ip = $UI/IPField.text if $UI/IPField.text != "" else $UI/IPField.placeholder_text
	var port = $UI/PortField.text if $UI/PortField.text != "" else $UI/PortField.placeholder_text
	enet_peer.create_client(ip, int(port))
	multiplayer.multiplayer_peer = enet_peer


func create_player(id):
	if board == null:
		board = board_scene.instantiate() as Board
		$Network.add_child(board)
	var player = player_scene.instantiate() as Player
	player.set_name(str(id))
	player.set_multiplayer_authority(id)
	player.position = seats[players_connected].position
	player.rotation = seats[players_connected].rotation
	$Network.add_child(player)
	player.rpc("attach_board", board.get_path())
	players_connected += 1


func _on_single_player_pressed() -> void:
	$UI.visible = false
	board = board_scene.instantiate() as Board
	add_child(board)
	var player = player_scene.instantiate() as Player
	add_child(player)
	player.attach_board(board.get_path())
	
