extends Node2D

var card_scene = preload("res://Scenes/client_card.tscn")
var icon_order = [0, 1, 3, 5, 7, 8, 6, 4, 2]
var symbol_buttons : Array[TextureButton] = []
var symbol_count_labels : Array[LineEdit] = []

var card_array = []
var selected_card = 0
var card_count = 1

var CLIENT_DECK_SAVE_PATH = "user://client_deck.json"

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
	$Control/Card.turn_front()
	
	load_deck()

func new_deck():
	for x in card_array:
		x.queue_free()
	card_array = []
	selected_card = 0
	card_count = 1
	$Control/LineEdit.text = "client " + str(card_count)
	count_traits()
	$card_count.text = str(selected_card) + "/" + str(card_array.size())

func save_deck():
	var card_dict = {}
	for card in card_array:
		var array = []
		array.append(card.initial_stress)
		array.append_array(card.time_slots)
		array.append_array(card.services)
		card_dict[card.title] = array
	var save_game = FileAccess.open(CLIENT_DECK_SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(card_dict)
	save_game.store_line(json_string)

func load_deck():
	if !FileAccess.file_exists(CLIENT_DECK_SAVE_PATH):
		return
	new_deck()
	var save_game = FileAccess.open(CLIENT_DECK_SAVE_PATH, FileAccess.READ)
	var card_dict = JSON.parse_string(save_game.get_line())
	for key in card_dict:
		var value = card_dict[key]
		var card_instance = card_scene.instantiate()
		#JSON only returns floats so we have to get ints out of the dict
		var bool_array = []
		var int_array = []
		for x in value.slice(1, 5):
			bool_array.append(bool(x))
		for x in value.slice(5, value.size()):
			int_array.append(int(x))
		card_instance.position = Vector2(-927, -176)
		card_instance.scale = Vector2(1.288, 1.288)
		card_instance.turn_front()
		card_array.append(card_instance)
		card_count += 1
		if card_array.size() > 1:
			card_array[selected_card].visible = false
		selected_card = card_array.size() - 1
		add_child(card_instance)
		card_instance.setup(key, int(value[0]), bool_array, int_array)
	$Control/LineEdit.text = "task " + str(card_count)
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
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())

func select_next():
	if card_array.size() == 0:
		return
	card_array[selected_card].visible = false
	selected_card += 1
	if selected_card >= card_array.size():
		selected_card = 0
	card_array[selected_card].visible = true
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())

func count_traits():
	var difficulty_counts = [0, 0, 0]
	var symbol_counts = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	for card in card_array:
		for x in 10:
			if x == 0:
				continue
			if x in card.services:
				symbol_counts[x - 1] += 1
	for x in symbol_count_labels.size():
		symbol_count_labels[x].text = str(symbol_counts[x])
	$easycount.text = str(difficulty_counts[0])
	$mediumcount.text = str(difficulty_counts[1])
	$hardcount.text = str(difficulty_counts[2])

func determine_card():
	var card = []
	card.append(int($Control/LineEdit2.text))
	card.append(bool($Control/TextureButton.button_pressed))
	card.append(bool($Control/TextureButton2.button_pressed))
	card.append(bool($Control/TextureButton3.button_pressed))
	card.append(bool($Control/TextureButton4.button_pressed))
	var services = [Data.services.CIRCLE]
	if $Control/ItemList.selected > 0:
		services.append($Control/ItemList.selected)
	if $Control/ItemList2.selected > 0:
		services.append($Control/ItemList2.selected)
	if $Control/ItemList3.selected > 0:
		services.append($Control/ItemList3.selected)
	if $Control/ItemList4.selected > 0:
		services.append($Control/ItemList4.selected)
	card.append_array(services)
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
	card_array[selected_card].setup($Control/LineEdit.text, card[0], card.slice(1, 5), card.slice(5, card.size()))
	count_traits()

func generate_card_from_buttons():
	var card = determine_card()
	if card == null:
		return
	var card_instance = card_scene.instantiate()
	card_instance.position = Vector2(-926, -176)
	card_instance.scale = Vector2(1.288, 1.288)
	card_instance.turn_front()
	card_array.append(card_instance)
	card_count += 1
	if card_array.size() > 1:
		card_array[selected_card].visible = false
	selected_card = card_array.size() - 1
	add_child(card_instance)
	card_instance.setup(str($Control/LineEdit.text), card[0], card.slice(1, 5), card.slice(5, card.size()))
	$Control/LineEdit.text = "task " + str(card_count)
	count_traits()
	$card_count.text = str(selected_card + 1) + "/" + str(card_array.size())


func _on_new_2_button_up():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
