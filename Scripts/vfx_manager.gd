extends Node

var camera: Camera2D
var shake_strength: float = 0.0
var enable_screen_shake: bool = true

func _process(delta):
	if camera != null and shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, 5 * delta)
		camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func shake_camera(intensity: float):
	if enable_screen_shake: shake_strength = intensity

func create_explosion(target_pos: Vector2i, color: Color):
	if Global.board == null: return
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.5
	particles.spread = 180.0
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 6.0
	particles.color = color
	
	particles.position = Helpers.get_visual_pos(Global.board, target_pos)
	particles.y_sort_enabled = false
	particles.z_index = 20 
	Global.board.add_child(particles)
	particles.emitting = true
	
	get_tree().create_timer(0.5).timeout.connect(particles.queue_free)
