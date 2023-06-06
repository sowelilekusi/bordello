class_name HoldingWorkerState
extends State

func _ready():
	player = get_parent().get_parent().get_parent() as Player
	fsm = get_parent().get_parent() as StateMachine

func enter():
	self.visible = true


func exit():
	self.visible = false

