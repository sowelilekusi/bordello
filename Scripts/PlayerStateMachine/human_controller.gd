class_name HumanController
extends PlayerController


func _ready() -> void:
	if not is_multiplayer_authority():
		return
	$Camera2D.make_current()
	$UI.visible = true


@rpc("call_local")
func ready_player():
	game.ready_player(own_id)


@rpc("any_peer")
func update_ready_label():
	$UI/LobbyReadyLabel.text = str(game.readied_players.size()) + "/" + str(game.players.size())


func _on_lobby_ready_button_pressed() -> void:
	rpc("ready_player")
	$UI/LobbyReadyButton.visible = false
	update_ready_label()
