class_name StateMachine
extends Node

enum FSMState {DRAFT, SETUP, MANAGEMENT, WORKER, H_WORKER, SHIFT, H_CLIENT}

@export var state_nodes : Array[State] = []

var state : FSMState
var history : Array[FSMState] = []


func _ready() -> void:
	#TODO: Bug in 4.0.3.stable requires this
	state_nodes.append($Draft)
	state_nodes.append($Setup)
	state_nodes.append($Management)
	state_nodes.append($Worker)
	state_nodes.append($Worker/HoldingWorker)
	state_nodes.append($Shift)
	state_nodes.append($Shift/HoldingClient)


func change_state(new_state : FSMState) -> void:
	history.append(state)
	state = new_state
	state_nodes[history[-1]].exit()
	state_nodes[state].enter()

	
