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
var medium_threshold := 5
var good_threshold := 8
var satisfaction := 1
var watch_on := false

@export var pip_sprites: Array[TextureRect] = []
@export var icon_list: Array[Node2D] = []
@export var time_button_sprites: Array[TextureRect] = []
@export var time_hovered_sprites: Array[TextureRect] = []
@export var watch: TextureRect


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
	good_threshold = 10 - (6 - services.size())
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
	watch.visible = true


func update_counter():
	$"front/Turns Left Counter".text = str(turns_left)


func _on_turn_pressed(num):
	turns_left = num
	update_counter()
	watch.visible = false
	watch_on = false
	time_slots_selected.emit()


func turn_front():
	$back.visible = false
	$front.visible = true


func turn_back():
	$back.visible = true
	$front.visible = false


func set_satisfaction(num):
	satisfaction = 1 + num
	$front/ColorRect.position.x = 134 + ((satisfaction - 1) * 20.0)


func _on_watch_segment_mouse_entered(extra_arg_0: int) -> void:
	if not watch_on or not time_slots[extra_arg_0]:
		return
	for x in extra_arg_0 + 1:
		time_hovered_sprites[x].visible = true


func _on_watch_segment_mouse_exited(_extra_arg_0: int) -> void:
	for sprite in time_hovered_sprites:
		sprite.visible = false


func _on_watch_segment_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, extra_arg_0: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_turn_pressed(extra_arg_0 + 1)
