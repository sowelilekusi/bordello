extends Node2D

var card_scene = preload("res://Scenes/card.tscn")
var icon_order = [0, 1, 3, 5, 7, 8, 6, 4, 2]
var symbol_buttons : Array[TextureButton] = []
var symbol_count_labels : Array[LineEdit] = []

var card_array = []
var selected_card = 0
var card_count = 1

var WORKER_DECK_SAVE_PATH = "user://worker_deck.json"

#example card dict entries
#"worker 1": [10, 0]
#"worker 2": [10, 1, 3, 4, 8]

func _ready():
	#workaround for node array export bug present in Godot 4.0.3.Stable
	symbol_buttons.append($"crossbutton")
	symbol_buttons.append($"squarebutton")
	symbol_buttons.append($"trianglebutton")
	symbol_buttons.append($"crescentbutton")
	symbol_buttons.append($"puppybutton")
	symbol_buttons.append($"riverbutton")
	symbol_buttons.append($"starbutton")
	symbol_buttons.append($"chainbutton")
	symbol_buttons.append($"gustbutton")
	symbol_count_labels.append($"crosscount")
	symbol_count_labels.append($"squarecount")
	symbol_count_labels.append($"trianglecount")
	symbol_count_labels.append($"crescentcount")
	symbol_count_labels.append($"puppycount")
	symbol_count_labels.append($"rivercount")
	symbol_count_labels.append($"starcount")
	symbol_count_labels.append($"chaincount")
	symbol_count_labels.append($"gustcount")
	
	load_deck()

func new_deck():
	for x in card_array:
		x.queue_free()
	card_array = []
	selected_card = 0
	card_count = 1
	$name_box.text = "worker " + str(card_count)
	count_traits()
	$card_count.text = str(selected_card) + "/" + str(card_array.size())

func save_deck():
	var card_dict = {}
	for card in card_array:
		var int_array = []
		int_array.append(card.capacity)
		int_array.append_array(card.services)
		card_dict[card.title] = int_array
	var save_game = FileAccess.open(WORKER_DECK_SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(card_dict)
	save_game.store_line(json_string)

func load_deck():
	if !FileAccess.file_exists(WORKER_DECK_SAVE_PATH):
		return
	new_deck()
	var save_game = FileAccess.open(WORKER_DECK_SAVE_PATH, FileAccess.READ)
	var card_dict = JSON.parse_string(save_game.get_line())
	for key in card_dict:
		var value = card_dict[key]
		var card_instance = card_scene.instantiate()
		#JSON only returns floats so we have to get ints out of the dict
		var bonuses = []
		for x in value.slice(1, value.size()):
			bonuses.append(int(x))
		card_instance.setup(key, int(value[0]), bonuses)
		card_instance.position = Vector2(-713, -17)
		card_instance.scale = Vector2(1.45, 1.45)
		card_array.append(card_instance)
		card_count += 1
		if card_array.size() > 1:
			card_array[selected_card].visible = false
		selected_card = card_array.size() - 1
		add_child(card_instance)
	$name_box.text = "worker " + str(card_count)
	count_traits()
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())

func select_prev():
	if card_array.size() == 0:
		return
	card_array[selected_card].visible = false
	selected_card -= 1
	if selected_card < 0:
		selected_card = card_array.size() - 1
	card_array[selected_card].visible = true
	for x in 10:
		if x == 0:
			continue
		if !card_array[selected_card].services.has(x):
			symbol_buttons[x - 1].set_state(0)
		if card_array[selected_card].services.has(x):
			symbol_buttons[x - 1].set_state(1)
		if card_array[selected_card].services.has((x) + 9):
			symbol_buttons[x - 1].set_state(2)
	$name_box.text = card_array[selected_card].title
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())

func select_next():
	if card_array.size() == 0:
		return
	card_array[selected_card].visible = false
	selected_card += 1
	if selected_card >= card_array.size():
		selected_card = 0
	card_array[selected_card].visible = true
	for x in 10:
		if x == 0:
			continue
		if !card_array[selected_card].services.has(x):
			symbol_buttons[x - 1].set_state(0)
		if card_array[selected_card].services.has(x):
			symbol_buttons[x - 1].set_state(1)
		if card_array[selected_card].services.has((x) + 9):
			symbol_buttons[x - 1].set_state(2)
	$name_box.text = card_array[selected_card].title
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())

func count_traits():
	var capacity_counts = [0, 0, 0, 0]
	var slot_counts = [0, 0, 0, 0]
	var symbol_counts = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	for card in card_array:
		match (card.capacity):
			8:
				capacity_counts[0] += 1
			10:
				capacity_counts[1] += 1
			12:
				capacity_counts[2] += 1
			14:
				capacity_counts[3] += 1
		match (card.services.size()):
			2:
				slot_counts[0] += 1
			3:
				slot_counts[1] += 1
			4:
				slot_counts[2] += 1
			5:
				slot_counts[3] += 1
		for x in 10:
			if x == 0:
				continue
			if x in card.services:
				symbol_counts[x-1] += 1
	for x in symbol_count_labels.size():
		symbol_count_labels[x].text = str(symbol_counts[x])
	$eightcount.text = str(capacity_counts[0])
	$tencount.text = str(capacity_counts[1])
	$twelvecount.text = str(capacity_counts[2])
	$fourteencount.text = str(capacity_counts[3])
	$onecount.text = str(slot_counts[0])
	$twocount.text = str(slot_counts[1])
	$threecount.text = str(slot_counts[2])
	$fourcount.text = str(slot_counts[3])

func determine_card():
	var array = []
	array.append(Data.services.CIRCLE)
	for i in 9:
		if symbol_buttons[i].state == 1:
			array.append(i + 1)
		if symbol_buttons[i].state == 2:
			array.append((i + 1) + 9)
	if array.size() <= 1 or array.size() > 5:
		return
	var card = []
	#BUTTONS CONTROLLING STRESS CAPACITY
#	if $eightbutton.state == 0 and $tenbutton.state == 0 and $twelvebutton.state == 0 and $fourteenbutton.state == 0:
#		return
#	if $eightbutton.state != 0:
#		card.append(8)
#	if $tenbutton.state != 0:
#		card.append(10)
#	if $twelvebutton.state != 0:
#		card.append(12)
#	if $fourteenbutton.state != 0:
#		card.append(14)
	if array.size() == 2:
		card.append(14)
	if array.size() == 3:
		card.append(12)
	if array.size() == 4:
		card.append(10)
	if array.size() == 5:
		card.append(8)
	for i in 5:
		if array.size() > i:
			card.append(array[i])
	return card

func delete_card():
	if card_array.size() == 0:
		return
	card_array[selected_card].queue_free()
	card_array.remove_at(selected_card)
	if selected_card > 0:
		selected_card -= 1
	if card_array.size() > 0:
		card_array[selected_card].visible = true
	count_traits()
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())

func edit_card():
	var card = determine_card()
	if card == null:
		return
	card_array[selected_card].setup($name_box.text, card[0], card.slice(1, card.size()))
	count_traits()

func generate_card_from_buttons():
	var card = determine_card()
	if card == null:
		return
	var card_instance = card_scene.instantiate()
	card_instance.setup(str($name_box.text), card[0], card.slice(1, card.size()))
	card_instance.position = Vector2(-713, -17)
	card_instance.scale = Vector2(1.45, 1.45)
	card_array.append(card_instance)
	card_count += 1
	if card_array.size() > 1:
		card_array[selected_card].visible = false
	selected_card = card_array.size() - 1
	add_child(card_instance)
	$name_box.text = "worker " + str(card_count)
	count_traits()
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())


func _on_new_2_button_up():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
