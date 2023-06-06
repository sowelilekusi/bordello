class_name ManagementState
extends State

func _on_hire_button_pressed():
	if player.money >= player.hire_costs[player.workers.size()]:
		player.money -= player.hire_costs[player.workers.size()]
		$Money.text = "$" + str(player.money)
		player.draft = player.DraftType.HIRE_WORKER
		player.draft_workers(3, 1)
		await player.draft_completed
		$HireWorkerButton.text = "Hire Worker: $" + str(player.hire_costs[player.workers.size()])


func _on_start_round_pressed() -> void:
	player
	fsm.change_state(fsm.FSMState.SHIFT)


func enter():
	self.visible = true
	for worker in player.active_workers:
		if worker != null:
			worker.decrease_stress(worker.stress)
	$RoundCounter.text = "Round: " + str(player.board.round_num)
	$RosterButton/CollisionShape2D.disabled = false
	player.hand_showing = true
	player.selected_worker = null
	player.camera.position.y = 0
	#TODO: Figure out what this loop is for
	for x in player.hand.size():
		player.hand[x].in_hand = true
	player.process_discard_decks()


func exit():
	self.visible = false
	$RosterButton/CollisionShape2D.disabled = true

