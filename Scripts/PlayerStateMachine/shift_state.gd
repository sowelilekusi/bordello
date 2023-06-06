class_name ShiftState
extends State


func enter():
	player.pad_shift_deck()
	self.visible = true
	$TurnCounter.text = "Turn: " + str(player.board.turn_num)
	player.camera.position.y = 0
	for x in player.hand.size():
		player.hand[x].in_hand = true
	if player.hand_hidden == false:
		player.hand_hiding = true
	player.pile_draw.disabled = false
	player.task_drawn = false
	player.clients_left.text = str(player.shift_deck.size())
	player.money += player.payout
	player.payout = 0
	if player.client_assignment != null and player.current_client != null:
		player.active_clients[player.client_assignment] = player.current_client
		if player.active_workers[player.client_assignment].increase_stress(player.current_client.initial_stress):
			player.worker_exceeded_capacity(player.client_assignment)
		player.client_assignment = -1
		player.current_client = null
	elif player.client_assignment == -1 and player.current_client != null:
		player.poor_discard.append(player.current_client)
		player.current_client = null
	$Money.text = "$" + str(player.money)
	player.pile_poor.disabled = true
	#Pretty sure these are done in the right order even though it looks the wrong way around
	for x in player.active_workers.size():
		if player.active_workers[x] != null and player.active_clients[x] == null:
			player.active_workers[x].decrease_stress(1)
		if player.active_workers[x] != null and player.active_clients[x] != null:
			if player.active_workers[x].increase_stress(1):
				player.worker_exceeded_capacity(x)
			player.active_clients[x].turns_left -= 1
			player.active_clients[x].update_counter()
			if player.active_clients[x].turns_left == 0:
				player.evaluate_task_success(x)
	var tasks_done = true
	for client in player.active_clients:
		if client != null:
			tasks_done = false
	if player.shift_deck.size() == 0:
		if tasks_done:
			player.round_completed = true
			#enter_management_overview_state()
		else:
			$HoldingClient/EndTurn.visible = true
			player.pile_draw.disabled = true


func exit():
	self.visible = false

