class_name SetupState
extends State


func enter():
	self.visible = true
	player.draft = player.DraftType.STARTING_HAND
	player.draft_workers(4, 2)


func exit():
	self.visible = false
