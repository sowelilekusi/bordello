class_name Client
extends Card

signal time_slots_selected

enum difficulties {EASY, MEDIUM, HARD}

var icon_prefab = preload("res://Scenes/bonus_icon.tscn")
var title = "New Task"
var difficulty = difficulties.EASY
var initial_stress = 0
var turns_left = 4
var time_slots = [true, true, false, true]
var icon_list = []


func _process(delta):
	if sliding:
		slide(delta)


func setup(_title, _initial_stress, _time_slots, _services):
	if _title != "":
		title = _title
	initial_stress = _initial_stress
	time_slots = _time_slots
	if time_slots[0] == true:
		$"Control/1turn".visible = true
	if time_slots[1] == true:
		$"Control/2turn".visible = true
	if time_slots[2] == true:
		$"Control/3turn".visible = true
	if time_slots[3] == true:
		$"Control/4turn".visible = true
	services = []
	if _services != null and _services != []:
		services.append_array(_services)
	match services.size():
		2, 3:
			difficulty = difficulties.EASY
		4, 5:
			difficulty = difficulties.MEDIUM
		6, 7:
			difficulty = difficulties.HARD
	$front/Slice1.visible = false
	$front/Slice2.visible = false
	$front/Slice3.visible = false
	$front/Slice4.visible = false
	if time_slots[0] == true:
		$front/Slice1.visible = true
	if time_slots[1] == true:
		$front/Slice2.visible = true
	if time_slots[2] == true:
		$front/Slice3.visible = true
	if time_slots[3] == true:
		$front/Slice4.visible = true
	$front/Title.text = str(title)
	$"front/Initial Stress".text = str(initial_stress)
	for x in icon_list:
		x.queue_free()
	icon_list = []
	match difficulty:
		difficulties.EASY:
			$easy.visible = true
			var array_of_bullshit = []
			array_of_bullshit.append($easy/Standard)
			array_of_bullshit.append($easy/Great1)
			array_of_bullshit.append($easy/Great2)
			for x in array_of_bullshit:
				var instance = icon_prefab.instantiate()
				icon_list.append(instance)
				x.add_child(instance)
		difficulties.MEDIUM:
			$medium.visible = true
			var array_of_bullshit = []
			array_of_bullshit.append($medium/Standard)
			array_of_bullshit.append($medium/Good1)
			array_of_bullshit.append($medium/Good2)
			array_of_bullshit.append($medium/Great1)
			array_of_bullshit.append($medium/Great2)
			for x in array_of_bullshit:
				var instance = icon_prefab.instantiate()
				icon_list.append(instance)
				x.add_child(instance)
		difficulties.HARD:
			$hard.visible = true
			var array_of_bullshit = []
			array_of_bullshit.append($hard/Standard)
			array_of_bullshit.append($hard/Poor1)
			array_of_bullshit.append($hard/Poor2)
			array_of_bullshit.append($hard/Good1)
			array_of_bullshit.append($hard/Good2)
			array_of_bullshit.append($hard/Great1)
			array_of_bullshit.append($hard/Great2)
			for x in array_of_bullshit:
				var instance = icon_prefab.instantiate()
				icon_list.append(instance)
				x.add_child(instance)
	for x in icon_list.size():
		if x < services.size():
			icon_list[x].set_service(services[x])
		else:
			icon_list[x].visible = false


func show_time_selector():
	$Control.visible = true


func update_counter():
	$"Background/Turns Left Counter".text = str(turns_left)


func _on_turn_pressed(num):
	turns_left = num
	update_counter()
	$Control.visible = false
	time_slots_selected.emit()


func turn_front():
	$back.visible = false
	$front.visible = true


func turn_back():
	$back.visible = true
	$front.visible = false
