extends TextureButton

var state = 0

func press(val):
	state += val
	if state > 2:
		state = 0
	if state < 0:
		state = 2
	set_state(state)

func set_state(x):
	state = x
	$Sprite2D.visible = false
	$Sprite2D2.visible = false
	$Sprite2D3.visible = false
	if state == 0:
		$Sprite2D.visible = true
	if state == 1:
		$Sprite2D2.visible = true
	if state == 2:
		$Sprite2D3.visible = true

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_mask:
			MOUSE_BUTTON_MASK_LEFT:
				press(1)
			MOUSE_BUTTON_MASK_RIGHT:
				press(-1)
