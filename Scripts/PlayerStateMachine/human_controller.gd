class_name HumanController
extends PlayerController

signal ready_button_pressed(int)
signal chat_message_submitted(String)

@onready var ready_button = $CanvasLayer/UI/HBoxContainer/LobbyReadyButton
@onready var ready_label = $CanvasLayer/UI/HBoxContainer/LobbyReadyLabel
@onready var canvas = $CanvasLayer
@onready var chat_box = $CanvasLayer/UI/VBoxContainer/RichTextLabel
@onready var cam_top = $CanvasLayer/UI/top_line
@onready var cam_bottom = $CanvasLayer/UI/bottom_line
@onready var cam_left = $CanvasLayer/UI/left_line
@onready var cam_right = $CanvasLayer/UI/right_line
@onready var cam_name = $CanvasLayer/UI/top_line/Label
#So this is fucked but basically starting the first round requires hitting
#the ready_self function exactly twice.
var game_started = 0


func _ready() -> void:
	if not is_multiplayer_authority():
		canvas.visible = false
		return
	$Camera2D.make_current()


func spectate_player(player_path):
	var player = get_node(player_path) as PlayerController
	if player.player_info["username"] == player_info["username"]:
		cam_top.visible = false
		cam_left.visible = false
		cam_right.visible = false
		cam_bottom.visible = false
	else:
		cam_top.visible = true
		cam_left.visible = true
		cam_right.visible = true
		cam_bottom.visible = true
		cam_name.text = player.player_info["username"]
	player.player_cam.make_current()


@rpc("call_local", "reliable")
func ready_self():
	ready_button_pressed.emit(player_info["id"])


@rpc("any_peer", "call_local", "reliable")
func update_ready_label(readied_players, total_players):
	if readied_players == total_players:
		ready_label.visible = false
	ready_label.text = str(readied_players) + "/" + str(total_players)


func _on_lobby_ready_button_pressed() -> void:
	ready_button.visible = false
	if game_started < 2:
		rpc("ready_self")
		game_started += 1
	else:
		rpc("end_turn")


func on_poor_discard_deck_clicked():
	super()
	ready_button.visible = true


func add_chat_line(line: String) -> void:
	chat_box.text += line


func _on_line_edit_text_submitted(new_text: String) -> void:
	var msg = "[" + player_info["username"] + "] " + new_text + "\n"
	$CanvasLayer/UI/VBoxContainer/LineEdit.text = ""
	chat_message_submitted.emit(msg)


func select_card(card):
	super(card)
	if draft_picked.size() == draft_pick_amount:
		$CanvasLayer/UI/Confirm.visible = true
	else:
		$CanvasLayer/UI/Confirm.visible = false


func _on_confirm_pressed() -> void:
	$CanvasLayer/UI/Confirm.visible = false
	rpc("confirm_draft")


func start_turn():
	super()


func end_of_round():
	super()
	$CanvasLayer/UI/Reputation.text = str(reputation_points) + " / 100 Reputation"


func select_workspace(workspace):
	if not super(workspace):
		return
	await current_client.time_slots_selected
	ready_button.visible = true
	current_workspace.evaluate_match()


@rpc("call_local", "reliable")
func confirm_draft():
	super()
	ready_button.visible = true
