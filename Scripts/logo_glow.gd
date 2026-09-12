extends TextureRect

var time = 0.0

func _process(delta):
	time += delta
	modulate.a = 0.6 + sin(time * 2.0) * 0.4
