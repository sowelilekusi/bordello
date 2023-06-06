class_name DraftState
extends State


func confirm_draft():
	if player.selected_for_draft.size() != player.draft_limit:
		return
	match(player.draft):
		player.DraftType.HIRE_WORKER, player.DraftType.STARTING_HAND:
			for card in player.selected_for_draft:
				player.add_to_hand(card)
				player.workers.append(card)
				player.shown_for_draft.remove_at(player.shown_for_draft.find(card))
			for card in player.shown_for_draft:
				card.position = Vector2(9999, 9999)
				player.board.discard_worker(card)
	match(fsm.history[-1]):
		fsm.FSMState.SETUP, fsm.FSMState.MANAGEMENT:
			fsm.change_state(fsm.FSMState.MANAGEMENT)
	player.draft_completed.emit()


func cancel_draft():
	match(player.draft):
		player.DraftType.HIRE_WORKER, player.DraftType.STARTING_HAND:
			for card in player.shown_for_draft:
				card.visible = false
				card.set_process(false)
				player.board.discard_worker(player.board.search_and_draw_worker(card))
	match(fsm.history[-1]):
		fsm.FSMState.SETUP, fsm.FSMState.MANAGEMENT:
			fsm.change_state(fsm.FSMState.MANAGEMENT)
	player.draft_completed.emit()


func enter():
	self.visible = true
	$Label.text = "Choose " + str(player.draft_limit) + " cards"
	match(player.draft):
		player.DraftType.HIRE_WORKER:
			$CancelDraft.visible = true
		player.DraftType.STARTING_HAND:
			$CancelDraft.visible = false


func exit():
	self.visible = false

