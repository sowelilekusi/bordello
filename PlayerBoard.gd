class_name PlayerBoard
extends Node2D

var player_info = {}
var workers = []
var roster = []
signal clients_discarded(cards: Array[NodePath])
@export var poor_deck: Deck
@export var good_deck: Deck
@export var great_deck: Deck
@export var shift_deck: Deck
@export var slots: Array[Workspace] = []
#Workaround for bug in 4.0.3.stable
@export var slot1: Workspace
@export var slot2: Workspace
@export var slot3: Workspace
@export var slot4: Workspace


func _ready():
	#Workaround for bug in 4.0.3.stable
	slots.append(slot1)
	slots.append(slot2)
	slots.append(slot3)
	slots.append(slot4)


func add_to_roster(node_paths):
	var cards = []
	for path in node_paths:
		cards.append(get_node(path))
	roster.append_array(cards)
	for x in 4:
		if x < roster.size():
			slots[x].add_worker(roster[x])


func draw_client():
	var card = shift_deck.draw_card()
	card.slide_to_position(position.x, position.y, 0.0, 0.3)
	card.turn_front()


func process_decks() -> int:
	var discards = []
	var points = 0
	for card in poor_deck.cards:
		card.turn_back()
		points -= 1
	for card in good_deck.cards:
		card.turn_back()
		points += 2
	for card in great_deck.cards:
		card.turn_back()
		points += 5
	poor_deck.shuffle()
	good_deck.shuffle()
	great_deck.shuffle()
	#print("Cards in poor deck: " + str(poor_deck.cards.size()))
	#print("Cards discarded from poor deck: " + str(poor_deck.cards.size() - 1))
	#print("Cards in good deck: " + str(good_deck.cards.size()))
	#print("Cards discarded from good deck: " + str(ceil(good_deck.cards.size() / 2.0)))
	#print("Cards in great deck: " + str(great_deck.cards.size()))
	#print("Cards discarded from great deck: " + str(min(great_deck.cards.size(), 1)))
	for card in poor_deck.draw_cards(poor_deck.cards.size() - 1):
		discards.append(card.get_path())
	for card in good_deck.draw_cards(ceil(good_deck.cards.size() / 2.0)):
		discards.append(card.get_path())
	for card in great_deck.draw_cards(min(great_deck.cards.size(), 1)):
		discards.append(card.get_path())
	for card in poor_deck.draw_cards(poor_deck.cards.size()):
		shift_deck.place(card)
	for card in good_deck.draw_cards(good_deck.cards.size()):
		shift_deck.place(card)
	for card in great_deck.draw_cards(great_deck.cards.size()):
		shift_deck.place(card)
	clients_discarded.emit(discards)
	return points


func time_step(skip_ahead: bool):
	for x in 4:
		var result : Client = slots[x].time_step(skip_ahead)
		if result != null:
			if result.satisfaction < result.medium_threshold:
				poor_deck.place(result)
			elif result.satisfaction < result.good_threshold:
				good_deck.place(result)
			elif result.satisfaction >= result.good_threshold:
				great_deck.place(result)
