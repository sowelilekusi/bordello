class_name HoldingClientState
extends State

func _ready():
	player = get_parent().get_parent().get_parent() as Player
	fsm = get_parent().get_parent() as StateMachine


func assign_task_to_worker():
	player.client_assignment = player.active_workers.find(player.selected_worker)
	if player.active_clients[player.client_assignment] != null:
		return
	player.current_client.slide_to_position(player.selected_worker.position.x - 100, player.selected_worker.position.y - 100, 0.0, 0.3)
	player.current_client.show_time_selector()
	await player.current_client.time_slots_selected
	player.payout = 0
	player.payout += player.current_client.turns_left * 2
	for service in player.current_client.services:
		if player.selected_worker.services.has(service):
			player.payout += Data.service_prices[service]
	$Payout.text = "$" + str(player.payout)
	$EndTurn.visible = true


func move_to_poor_discard(_button):
	player.current_client.slide_to_position(player.pile_poor.position.x, player.pile_poor.position.y, 0.0, 0.2)
	player.client_assignment = -1
	$EndTurn.visible = true
	player.payout = 0
	$Payout.text = ""


func enter():
	self.visible = true
	$Payout.text = ""
	player.current_client = player.shift_deck.pop_back()
	player.current_client.position = Vector2(494, -414)
	player.current_client.visible = true
	player.current_client.z_index = 1
	player.current_client.slide_to_position($PreviewTask.position.x, $PreviewTask.position.y, 0.0, 0.3)
	player.task_drawn = true
	player.pile_draw.disabled = true
	player.pile_poor.disabled = false
	player.clients_left = str(player.shift_deck.size())


func exit():
	self.visible = false

