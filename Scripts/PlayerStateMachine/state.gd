class_name State
extends Node2D

@export var player : Player
@export var fsm : StateMachine

func _ready() -> void:
	player = get_parent().get_parent() as Player
	fsm = get_parent() as StateMachine


func enter():
	pass


func exit():
	pass
