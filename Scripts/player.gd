class_name Player
extends Node2D

signal draft_completed
signal board_attached

enum FSMState {DRAFT, SETUP, MANAGEMENT, WORKER, H_WORKER, SHIFT, H_CLIENT}
enum DraftType {HIRE_WORKER}

@export var roster_positions : Array[Node2D] = []
@export var slot_buttons : Array[Node2D] = []
@export var seconds_to_hide_hand := 2.0
@export var seconds_to_show_hand := 2.0
var money := 0
var payout := 0
var cost := 0
var hire_costs := [40, 50, 60, 70, 80]
var shift_deck : Array[Client] = []
var workers : Array[Worker] = []
var hand : Array[Worker] = []
var active_workers : Array[Worker] = [null, null, null, null, null]
var active_clients : Array[Client] = [null, null, null, null, null]
var poor_discard : Array[Client] = []
var good_discard : Array[Client] = []
var great_discard : Array[Client] = []
var last_fsm_state := FSMState.SETUP
var current_fsm_state := FSMState.SETUP
var draft := DraftType.HIRE_WORKER
var hand_hiding := false
var hand_hidden := false
var hand_hiding_progress := 0.0
var hand_showing := false
var hand_showing_progress := 0.0
var shown_for_draft : Array[Worker] = []
var selected_for_draft : Array[Worker] = []
var draft_limit := 0
var current_client : Client
var selected_worker : Worker
var task_drawn := false
var client_assignment : int = -1
var board : Board = null
var turn_completed = false
var round_completed = false


func _ready() -> void:
	#Bug in Godot 4.0.3.stable makes it nessesary to add these manually
	roster_positions.append($RosterSection/Position1)
	roster_positions.append($RosterSection/Position2)
	roster_positions.append($RosterSection/Position3)
	roster_positions.append($RosterSection/Position4)
	roster_positions.append($RosterSection/Position5)
	roster_positions.append($RosterSection/Position6)
	roster_positions.append($RosterSection/Position7)
	roster_positions.append($RosterSection/Position8)
	roster_positions.append($RosterSection/Position9)
	roster_positions.append($RosterSection/Position10)
	roster_positions.append($RosterSection/Position11)
	roster_positions.append($RosterSection/Position12)
	roster_positions.append($RosterSection/Position13)
	roster_positions.append($RosterSection/Position14)
	roster_positions.append($RosterSection/Position15)
	slot_buttons.append($WorkerPlaySlots/Slot1)
	slot_buttons.append($WorkerPlaySlots/Slot2)
	slot_buttons.append($WorkerPlaySlots/Slot3)
	slot_buttons.append($WorkerPlaySlots/Slot4)
	slot_buttons.append($WorkerPlaySlots/Slot5)
	for button in slot_buttons:
		button.button_pushed.connect(select_slot)
	$PoorDiscardPile/Label.text = "No / Poor service"
	$GoodDiscardPile/Label.text = "Good service"
	$GreatDiscardPile/Label.text = "Great service"
	$TaskDrawDeck/Label.text = "Click to draw task card"
	$Camera2D.make_current()
	await board_attached
	enter_setup_state()


func _process(delta) -> void:
	if (hand_hiding):
		if hand_hiding_progress < seconds_to_hide_hand:
			hand_hiding_progress += delta
			var percent = clampf(hand_hiding_progress / seconds_to_hide_hand, 0.0, 1.0)
			for card in hand:
				card.hand_position.y = lerpf($Hand.position.y, $Hand.position.y + 300.0, percent)
		else:
			hand_hiding = false
			hand_hidden = true
			hand_hiding_progress = 0.0
	if (hand_showing):
		if hand_showing_progress < seconds_to_show_hand:
			hand_showing_progress += delta
			var percent = clampf(hand_showing_progress / seconds_to_show_hand, 0.0, 1.0)
			for card in hand:
				card.hand_position.y = lerpf($Hand.position.y + 300.0, $Hand.position.y, percent)
		else:
			hand_showing = false
			hand_showing_progress = 0.0


func start_turn():
	pass


func start_round():
	pass


@rpc("call_local")
func attach_board(board_path : NodePath):
	board = get_node(board_path) as Board
	board_attached.emit()


func add_to_hand(card):
	hand.append(card)
	for x in hand.size():
		var hand_ratio = 0.5
		
		if hand.size() > 1:
			hand_ratio = float(x) / float(hand.size() - 1)
		hand[x].position = $Hand.position
		hand[x].hand_ratio = hand_ratio
		hand[x].in_hand = true
		hand[x].hand_position = $Hand.position
		hand[x].visible = true
		hand[x].set_process(true)


func lift_hand():
	for card in hand:
		card.hovered = true


func drop_hand():
	for card in hand:
		card.hovered = false


func _on_hire_button_pressed():
	if money >= hire_costs[workers.size()]:
		money -= hire_costs[workers.size()]
		$Camera2D/Money.text = "$" + str(money)
		draft_workers(3, 1, true)
		await draft_completed
		$Button.text = "Hire Worker: $" + str(hire_costs[workers.size()])


func assign_task_to_worker():
	client_assignment = active_workers.find(selected_worker)
	if active_clients[client_assignment] != null:
		return
	current_client.slide_to_position(selected_worker.position.x - 100, selected_worker.position.y - 100, 0.0, 0.3)
	current_client.show_time_selector()
	await current_client.time_slots_selected
	payout = 0
	payout += current_client.turns_left * 2
	for service in current_client.services:
		if selected_worker.services.has(service):
			payout += Data.service_prices[service]
	$Camera2D/Payout.text = "$" + str(payout)
	$"Camera2D/EndTurn".visible = true


func move_to_poor_discard(_button):
	current_client.slide_to_position($PoorDiscardPile.position.x, $PoorDiscardPile.position.y, 0.0, 0.2)
	client_assignment = -1
	$Camera2D/EndTurn.visible = true
	payout = 0
	$Camera2D/Payout.text = ""


func select_card(card):
	if current_fsm_state == FSMState.DRAFT:
		if selected_for_draft.size() <= draft_limit:
			if selected_for_draft.has(card):
				selected_for_draft.remove_at(selected_for_draft.find(card))
				card.slide_to_position(card.position.x, card.position.y + 40, 0.0, 0.1)
			else:
				if selected_for_draft.size() < draft_limit:
					selected_for_draft.append(card)
					card.slide_to_position(card.position.x, card.position.y - 40, 0.0, 0.1)
		return
	selected_worker = card
	if current_client != null:
		assign_task_to_worker()


func select_slot(slot):
	if selected_worker == null:
		return
	if active_workers.has(selected_worker):
		active_workers[active_workers.find(selected_worker)] = null
	if hand.has(selected_worker):
		hand.remove_at(hand.find(selected_worker))
	active_workers[slot_buttons.find(slot)] = selected_worker
	selected_worker.slide_to_position(slot.position.x, slot.position.y, 0.0, 0.3)
	selected_worker = null

#Shift Phase
	#1. Swap 1 time token on each worker over to the stress side
	#2. Pick up the next client card in the deck, and either assign it to 
	#   a worker or place it in the no service pile
	#3. If a worker both has no client, and at least one stress token, remove
	#   a stress token

#Management Phase
	#Market Research
		#Look at the 10 clients, and place them back in the same order
	#Targeted Advertising
		#Search through the client discard deck, and add all clients
		#with one extra type to your shift deck
	#Roster Worker
		#Add 1 worker from your hand into the next open slot on your board


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		enter_workers_view_state()


func _on_area_2d_2_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		enter_management_overview_state()


func _on_task_draw_deck_button_pushed(_button):
	enter_holding_task_state()


func evaluate_task_success(num):
	var successfulness = 0
	var worker = active_workers[num]
	var client = active_clients[num]
	match client.services.size():
		2, 3:
			successfulness = 2
		4:
			successfulness = 1
			if worker.services.has(client.services[3]):
				successfulness = 2
		5:
			successfulness = 1
			if worker.services.has(client.services[4]):
				successfulness = 2
		6:
			successfulness = 0
			if worker.services.has(client.services[3]) or worker.services.has(client.services[4]):
				successfulness = 1
			if worker.services.has(client.services[5]):
				successfulness = 2
		7:
			successfulness = 0
			if worker.services.has(client.services[3]) or worker.services.has(client.services[4]):
				successfulness = 1
			if worker.services.has(client.services[5]) or worker.services.has(client.services[6]):
				successfulness = 2
	var slide_destination : Vector2
	match successfulness:
		0:
			poor_discard.append(client)
			slide_destination = $PoorDiscardPile.position
		1:
			good_discard.append(client)
			slide_destination = $GoodDiscardPile.position
		2:
			great_discard.append(client)
			slide_destination = $GreatDiscardPile.position
	client.slide_to_position(slide_destination.x, slide_destination.y, 0.0, 0.2)
	client.z_index = 0
	active_clients[num] = null


func worker_exceeded_capacity(num):
	active_workers[num].stress = 0
	active_workers[num].set_process(false)
	active_workers[num].visible = false
	workers.remove_at(workers.find(active_workers[num]))
	active_workers[num] = null


func draft_workers(_draw, pick, cancelable):
	draft = DraftType.HIRE_WORKER
	draft_limit = pick
	shown_for_draft = []
	selected_for_draft = []
	var y = 0
	var x = (250.0 * _draw) / 2.0
	shown_for_draft.append_array(board.draw_worker(_draw))
	for i in shown_for_draft.size():
		var card = shown_for_draft[i]
		card.visible = true
		card.set_process(true)
		card.card_clicked.connect(select_card)
		var ratio = float(i) / float(_draw - 1)
		var xx = lerpf(-1 * x, x, ratio)
		card.slide_to_position(xx, y, 0.0, 0.3)
	enter_draft_state(cancelable)


func pad_shift_deck():
	var padding = (2 + (2 * board.round_num)) - shift_deck.size()
	shift_deck.append_array(board.draw_client(padding))


func process_discard_decks():
	poor_discard.shuffle()
	good_discard.shuffle()
	great_discard.shuffle()
	for x in range(poor_discard.size() - 1, -1, -1):
		if x == 0:
			shift_deck.append(poor_discard[x])
		else:
			board.discard_client(poor_discard[x])
		poor_discard[x].position = Vector2(9999, 9999)
		poor_discard[x].visible = false
		poor_discard.remove_at(x)
	for x in range(good_discard.size() - 1, -1, -1):
		if x <= int(good_discard.size() / 2.0):
			shift_deck.append(good_discard[x])
		else:
			board.discard_client(good_discard[x])
		good_discard[x].position = Vector2(9999, 9999)
		good_discard[x].visible = false
		good_discard.remove_at(x)
	for x in range(great_discard.size() - 1, -1, -1):
		if x < great_discard.size() - 1:
			shift_deck.append(great_discard[x])
		else:
			board.discard_client(great_discard[x])
		great_discard[x].position = Vector2(9999, 9999)
		great_discard[x].visible = false
		great_discard.remove_at(x)


func confirm_draft():
	if selected_for_draft.size() != draft_limit:
		return
	$Camera2D/EndDraft.visible = false
	$Camera2D/CancelDraft.visible = false
	match(draft):
		DraftType.HIRE_WORKER:
			for card in selected_for_draft:
				add_to_hand(card)
				workers.append(card)
				shown_for_draft.remove_at(shown_for_draft.find(card))
			for card in shown_for_draft:
				card.position = Vector2(9999, 9999)
				board.discard_worker(card)
	match(last_fsm_state):
		FSMState.SETUP, FSMState.MANAGEMENT:
			enter_management_overview_state()
	draft_completed.emit()


func cancel_draft():
	$Camera2D/EndDraft.visible = false
	$Camera2D/CancelDraft.visible = false
	match(draft):
		DraftType.HIRE_WORKER:
			for card in shown_for_draft:
				card.visible = false
				card.set_process(false)
				board.discard_worker(board.search_and_draw_worker(card))
	match(last_fsm_state):
		FSMState.SETUP, FSMState.MANAGEMENT:
			enter_management_overview_state()
	draft_completed.emit()


func enter_draft_state(cancelable):
	last_fsm_state = current_fsm_state
	current_fsm_state = FSMState.DRAFT
	$Camera2D/PhaseLabel.text = "Choose " + str(draft_limit) + " cards"
	$Camera2D/EndManagement.visible = false
	$RosterButton/CollisionShape2D.disabled = true
	$ReturnButton.visible = false
	$ReturnButton/CollisionShape2D.disabled = true
	$Camera2D/EndDraft.visible = true
	if cancelable:
		$Camera2D/CancelDraft.visible = true


func enter_setup_state():
	last_fsm_state = current_fsm_state
	current_fsm_state = FSMState.SETUP
	#money = 100
	$Camera2D/Money.text = "$" + str(money)
	draft_workers(4, 2, false)


func enter_management_overview_state():
	last_fsm_state = current_fsm_state
	current_fsm_state = FSMState.MANAGEMENT
	for worker in active_workers:
		if worker != null:
			worker.decrease_stress(worker.stress)
	$Camera2D/RoundCounter.text = "Round: " + str(board.round_num)
	$Camera2D/PhaseLabel.text = "Management Phase"
	$Camera2D/EndManagement.visible = true
	$Camera2D/Cost.visible = true
	$Camera2D/EndShift.visible = false
	$Camera2D/EndTurn.visible = false
	$RosterButton/CollisionShape2D.disabled = false
	$WorkerPlaySlots/Slot1.visible = true
	$WorkerPlaySlots/Slot2.visible = true
	$WorkerPlaySlots/Slot3.visible = true
	$WorkerPlaySlots/Slot4.visible = true
	$WorkerPlaySlots/Slot5.visible = true
	$HireWorkerButton.visible = true
	$Camera2D/TurnCounter.visible = false
	hand_showing = true
	selected_worker = null
	$RosterButton/CollisionShape2D.disabled = false
	$ReturnButton.visible = false
	$ReturnButton/CollisionShape2D.disabled = true
	$Camera2D.position.y = 0
	for x in hand.size():
		hand[x].in_hand = true
	$TaskDrawDeck/Area2D/CollisionShape2D.disabled = true
	$PoorDiscardPile/Area2D/CollisionShape2D.disabled = true
	process_discard_decks()
	pad_shift_deck()
	$TaskDrawDeck/Count.text = str(shift_deck.size())


func enter_workers_view_state():
	last_fsm_state = current_fsm_state
	current_fsm_state = FSMState.WORKER
	selected_worker = null
	$RosterButton/CollisionShape2D.disabled = true
	$ReturnButton.visible = true
	$ReturnButton/CollisionShape2D.disabled = false
	$Camera2D.position.y = 640
	for x in hand.size():
		hand[x].in_hand = false
		hand[x].slide_to_position(roster_positions[x].position.x, roster_positions[x].position.y, 0.0, 0.2)


func enter_holding_worker_state():
	last_fsm_state = current_fsm_state
	current_fsm_state = FSMState.H_WORKER


func enter_shift_overview_state():
	last_fsm_state = current_fsm_state
	current_fsm_state = FSMState.SHIFT
	$Camera2D/TurnCounter.visible = true
	$Camera2D/TurnCounter.text = "Turn: " + str(board.turn_num)
	$Camera2D/PhaseLabel.text = "Shift Phase"
	$Camera2D/EndManagement.visible = false
	$RosterButton/CollisionShape2D.disabled = true
	$WorkerPlaySlots/Slot1.visible = false
	$WorkerPlaySlots/Slot2.visible = false
	$WorkerPlaySlots/Slot3.visible = false
	$WorkerPlaySlots/Slot4.visible = false
	$WorkerPlaySlots/Slot5.visible = false
	$ReturnButton.visible = false
	$ReturnButton/CollisionShape2D.disabled = true
	$Camera2D.position.y = 0
	$Camera2D/Cost.visible = false
	$HireWorkerButton.visible = false
	for x in hand.size():
		hand[x].in_hand = true
	if hand_hidden == false:
		hand_hiding = true
	$TaskDrawDeck/Area2D/CollisionShape2D.disabled = false
	task_drawn = false
	money += payout
	payout = 0
	if client_assignment != null and current_client != null:
		active_clients[client_assignment] = current_client
		if active_workers[client_assignment].increase_stress(current_client.initial_stress):
			worker_exceeded_capacity(client_assignment)
		client_assignment = -1
		current_client = null
	elif client_assignment == -1 and current_client != null:
		poor_discard.append(current_client)
		current_client = null
	$Camera2D/Payout.text = ""
	$Camera2D/Money.text = "$" + str(money)
	$Camera2D/EndTurn.visible = false
	$PoorDiscardPile/Area2D/CollisionShape2D.disabled = true
	#Pretty sure these are done in the right order even though it looks the wrong way around
	for x in active_workers.size():
		if active_workers[x] != null and active_clients[x] == null:
			active_workers[x].decrease_stress(1)
		if active_workers[x] != null and active_clients[x] != null:
			if active_workers[x].increase_stress(1):
				worker_exceeded_capacity(x)
			active_clients[x].turns_left -= 1
			active_clients[x].update_counter()
			if active_clients[x].turns_left == 0:
				evaluate_task_success(x)
	var tasks_done = true
	for client in active_clients:
		if client != null:
			tasks_done = false
	if shift_deck.size() == 0:
		if tasks_done:
			round_completed = true
			#enter_management_overview_state()
		else:
			$Camera2D/EndTurn.visible = true
			$TaskDrawDeck/Area2D/CollisionShape2D.disabled = true


func enter_holding_task_state():
	last_fsm_state = current_fsm_state
	current_fsm_state = FSMState.H_CLIENT
	current_client = shift_deck.pop_back()
	current_client.position = Vector2(494, -414)
	current_client.visible = true
	current_client.z_index = 1
	current_client.slide_to_position($PreviewTask.position.x, $PreviewTask.position.y, 0.0, 0.3)
	task_drawn = true
	$TaskDrawDeck/Area2D/CollisionShape2D.disabled = true
	$PoorDiscardPile/Area2D/CollisionShape2D.disabled = false
	$TaskDrawDeck/Count.text = str(shift_deck.size())

