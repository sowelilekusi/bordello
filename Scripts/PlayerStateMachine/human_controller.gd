class_name HumanController
extends PlayerController

signal ready_button_pressed(int)
signal chat_message_submitted(String)

@onready var ready_button = $CanvasLayer/UI/HBoxContainer/LobbyReadyButton
@onready var ready_label = $CanvasLayer/UI/HBoxContainer/LobbyReadyLabel
@onready var canvas = $CanvasLayer
@onready var chat_box = $CanvasLayer/UI/VBoxContainer/RichTextLabel
var game_started = false


func _ready() -> void:
	if not is_multiplayer_authority():
		canvas.visible = false
		return
	$Camera2D.make_current()


@rpc("call_local", "reliable")
func ready_self():
	ready_button_pressed.emit(player_info["id"])


@rpc("any_peer", "call_local", "reliable")
func update_ready_label(readied_players, total_players):
	if readied_players == total_players:
		ready_label.visible = false
	ready_label.text = str(readied_players) + "/" + str(total_players)


func _on_lobby_ready_button_pressed() -> void:
	rpc("ready_self")
	ready_button.visible = false
	rpc("end_turn")


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


func select_workspace(workspace):
	super(workspace)
	ready_button.visible = true


@rpc("call_local", "reliable")
func confirm_draft():
	super()
	ready_button.visible = true
