class_name Worker
extends Card

var title = "New Card"
var max_supers = 2
var capacity = 8
var stress = 0
signal card_clicked(card)
@export var spread_curve : Curve
@export var height_curve : Curve
@export var rotation_curve : Curve
@export var hand_width : float
@export var hand_height : float
@export var hand_rotation : float
var in_hand = false
var hand_ratio
var hand_position = Vector2(0, 0)
var hovered = false

func _process(delta):
	if sliding:
		slide(delta)
	if in_hand:
		position.x = hand_position.x + spread_curve.sample(hand_ratio) * hand_width
		position.y = hand_position.y - height_curve.sample(hand_ratio) * hand_height
		rotation   = rotation_curve.sample(hand_ratio) * hand_rotation
	if hovered:
		position.y = (hand_position.y - 50.0) - height_curve.sample(hand_ratio) * hand_height
		position.x = hand_position.x + spread_curve.sample(hand_ratio) * (hand_width + (hand_width * 0.2))
		rotation = rotation_curve.sample(hand_ratio) * (hand_rotation + (hand_rotation * 0.2))

func get_icon(x):
	var y = 32
	if x > 8:
		y += (x - 9) * 32
	else:
		y += x * 32
	return y

func setup(_title, _capacity, _services):
	if _title != "":
		title = _title
	capacity = _capacity
	services = _services
	$Sprite2D/Title.text = title
	$Sprite2D/Capacity.text = str(capacity)
	$Sprite2D/Bonus1/Icon1.visible = false
	$Sprite2D/Bonus2/Icon2.visible = false
	$Sprite2D/Bonus3/Icon3.visible = false
	$Sprite2D/Bonus4/Icon4.visible = false
	$Sprite2D/Bonus1/frame1.visible = false
	$Sprite2D/Bonus2/frame2.visible = false
	$Sprite2D/Bonus3/frame3.visible = false
	$Sprite2D/Bonus4/frame4.visible = false
	$Sprite2D/Bonus1/super1.visible = false
	$Sprite2D/Bonus2/super2.visible = false
	$Sprite2D/Bonus3/super3.visible = false
	$Sprite2D/Bonus4/super4.visible = false
	if services.size() > 1:
		$Sprite2D/Bonus1/Icon1.visible = true
		#TODO:Eliminate the -1 in the get_icon call
		$Sprite2D/Bonus1/Icon1.region_rect = Rect2(get_icon(services[1]-1), 0, 32, 32)
		if services[1] > 9:
			$Sprite2D/Bonus1/super1.visible = true
		else:
			$Sprite2D/Bonus1/frame1.visible = true
	if services.size() > 2:
		$Sprite2D/Bonus2/Icon2.visible = true
		$Sprite2D/Bonus2/Icon2.region_rect = Rect2(get_icon(services[2]-1), 0, 32, 32)
		if services[2] > 9:
			$Sprite2D/Bonus2/super2.visible = true
		else:
			$Sprite2D/Bonus2/frame2.visible = true
	if services.size() > 3:
		$Sprite2D/Bonus3/Icon3.visible = true
		$Sprite2D/Bonus3/Icon3.region_rect = Rect2(get_icon(services[3]-1), 0, 32, 32)
		if services[3] > 9:
			$Sprite2D/Bonus3/super3.visible = true
		else:
			$Sprite2D/Bonus3/frame3.visible = true
	if services.size() > 4:
		$Sprite2D/Bonus4/Icon4.visible = true
		$Sprite2D/Bonus4/Icon4.region_rect = Rect2(get_icon(services[4]-1), 0, 32, 32)
		if services[4] > 9:
			$Sprite2D/Bonus4/super4.visible = true
		else:
			$Sprite2D/Bonus4/frame4.visible = true


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("card_clicked", self)

func increase_stress(amount) -> bool:
	stress += amount
	$Label.text = str(stress)
	return stress > capacity

func decrease_stress(amount):
	stress -= amount
	if stress < 0:
		stress = 0
	$Label.text = str(stress)
