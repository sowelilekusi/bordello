class_name Client
extends Card

signal time_slots_selected

var icon_prefab = preload("res://Scenes/bonus_icon.tscn")
var bad_pip_sprite = preload("res://Assets/bad_pip.png")
var medium_pip_sprite = preload("res://Assets/medium_pip.png")
var good_pip_sprite = preload("res://Assets/good_pip.png")
var title = "New Task"
var initial_stress = 0
var turns_left = 4
var time_slots = [true, true, false, true]
var icon_list = []
var medium_threshold := 5
var good_threshold := 8
var satisfaction := 1
var watch_on := false
@export var pip_sprites: Array[TextureRect] = []
@export var time_button_sprites: Array[TextureRect] = []
@export var time_hovered_sprites: Array[TextureRect] = []


func _ready():
	pip_sprites.append($front/pip2)
	pip_sprites.append($front/pip3)
	pip_sprites.append($front/pip4)
	pip_sprites.append($front/pip5)
	pip_sprites.append($front/pip6)
	pip_sprites.append($front/pip7)
	pip_sprites.append($front/pip8)
	pip_sprites.append($front/pip9)
	icon_list.append($front/Bonus1)
	icon_list.append($front/Bonus2)
	icon_list.append($front/Bonus3)
	icon_list.append($front/Bonus4)
	time_button_sprites.append($watch/time1)
	time_button_sprites.append($watch/time2)
	time_button_sprites.append($watch/time3)
	time_button_sprites.append($watch/time4)
	time_hovered_sprites.append($watch/time_hovered1)
	time_hovered_sprites.append($watch/time_hovered2)
	time_hovered_sprites.append($watch/time_hovered3)
	time_hovered_sprites.append($watch/time_hovered4)


func _process(delta):
	if sliding:
		slide(delta)


func setup(_title, _initial_stress, _time_slots, _services):
	if _title != "":
		title = _title
	initial_stress = _initial_stress
	time_slots = _time_slots
	services = []
	if _services != null and _services != []:
		services.append_array(_services)
	for x in time_button_sprites.size():
		if time_slots[x] == true:
			time_button_sprites[x].visible = true
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
	for x in services.size():
		if x == 0:
			continue
		icon_list[x - 1].set_service(services[x])
		icon_list[x - 1].visible = true
	good_threshold = 10 - (5 - services.size())
	medium_threshold = 4
	if time_slots[3] == false:
		good_threshold -= 1
		if time_slots[2] == false:
			good_threshold -= 1
			if time_slots[1] == false:
				good_threshold -= 1
	if time_slots[0] == false:
		medium_threshold += 1
		if time_slots[1] == false:
			medium_threshold += 1
			if time_slots[2] == false:
				medium_threshold += 1
	for x in pip_sprites.size() + 2:
		if x < 2:
			continue
		if x >= good_threshold:
			pip_sprites[x - 2].texture = good_pip_sprite
		if x < good_threshold:
			pip_sprites[x - 2].texture = medium_pip_sprite
		if x < medium_threshold:
			pip_sprites[x - 2].texture = bad_pip_sprite


func show_time_selector():
	watch_on = true
	$watch.visible = true


func update_counter():
	$"front/Turns Left Counter".text = str(turns_left)


func _on_turn_pressed(num):
	turns_left = num
	update_counter()
	$watch.visible = false
	watch_on = false
	time_slots_selected.emit()


func turn_front():
	$back.visible = false
	$front.visible = true


func turn_back():
	$back.visible = true
	$front.visible = false


func _on_watch_segment_mouse_entered(extra_arg_0: int) -> void:
	if not watch_on or not time_slots[extra_arg_0]:
		return
	for x in extra_arg_0 + 1:
		time_hovered_sprites[x].visible = true


func _on_watch_segment_mouse_exited(extra_arg_0: int) -> void:
	for sprite in time_hovered_sprites:
		sprite.visible = false


func _on_watch_segment_input_event(viewport: Node, event: InputEvent, shape_idx: int, extra_arg_0: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_turn_pressed(extra_arg_0 + 1)
