class_name PlayerBoard
extends Node2D

var workers = []
var roster = []
var shift_deck = []
var slots = []


func _ready():
	#Workaround for bug in 4.0.3.stable
	slots.append($Slot1)
	slots.append($Slot2)
	slots.append($Slot3)
	slots.append($Slot4)


func add_to_roster(node_paths):
	var cards = []
	for path in node_paths:
		cards.append(get_node(path))
	roster.append_array(cards)
	for x in 4:
		if x < roster.size():
			slots[x].add_worker(roster[x])
