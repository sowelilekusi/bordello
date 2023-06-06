extends Node2D

var service = Data.services.CIRCLE

func get_icon(x):
	var y = 0
	if x > 9:
		y += (x - 9) * 32
	else:
		y += x * 32
	return y

func set_service(_service):
	service = _service
	$Label.text = str(Data.service_prices[service])
	$Label.visible = true
	$"Icon1".region_rect = Rect2(get_icon(service), 0, 32, 32)
