class_name WorkerState
extends State


func enter():
	self.visible = true
	player.selected_worker = null
	$ReturnButton/CollisionShape2D.disabled = false
	player.camera.position.y = 640
	for x in player.hand.size():
		player.hand[x].in_hand = false
		player.hand[x].slide_to_position(player.roster_positions[x].position.x, player.roster_positions[x].position.y, 0.0, 0.2)


func exit():
	self.visible = false
	$ReturnButton/CollisionShape2D.disabled = true

