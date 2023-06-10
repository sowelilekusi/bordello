class_name PlayerBoard
extends Node2D

var player_info = {}
var workers = []
var roster = []
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
