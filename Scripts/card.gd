class_name Card
extends Node2D

var services = []

var origin         = Vector3(position.x, position.y, rotation)
var destination    = null
var sliding        = false
var slide_progress = 0.0
var slide_time     = 0.5

func slide_to_position(x, y, r, t):
	origin = Vector3(position.x, position.y, rotation)
	destination = Vector3(x, y, r)
	slide_time = t
	sliding = true

func slide(delta):
	if slide_progress < slide_time:
		slide_progress += delta
		var percent = clampf(slide_progress / slide_time, 0.0, 1.0)
		position.x = lerpf(origin.x, destination.x, percent)
		position.y = lerpf(origin.y, destination.y, percent)
		rotation   = lerpf(origin.z, destination.z, percent)
	else:
		sliding = false
		slide_progress = 0.0
