extends CharEnemy

var magic_beam_rsrcs: Resource = preload("res://entities/enemies/mage_beam.tscn")
var magic_beam_effect_pool: Array[CharEntity.StatusEffect] = \
	[CharEntity.StatusEffect.TINY, CharEntity.StatusEffect.BOUNCY, CharEntity.StatusEffect.REVERSE]

var wander_start_pos: Vector2
var prev_pos: Vector2

var can_shoot: bool = false

func _ready() -> void:
	super()
	next_wander_target()
	
	speed = 200
	
	$BeamCD.wait_time = 1.0 + randf_range(0.2, 1.0)
	$BeamCD.start()
	$WanderCD.start()
	wander_start_pos = global_position
	
	

func _physics_process(delta: float) -> void:
	# wander around
	var t = 1.0 - $WanderCD.time_left / $WanderCD.wait_time
	var next_pos = Globals.bezier_curve(wander_start_pos, secundary_wander_target, wander_target, t) 
	
	velocity = prev_pos.direction_to(next_pos) * speed * speed_multiply
	prev_pos = next_pos
	
	
	# charge and shoot magic beam - confusion - tiny - bouncy
	if Globals.player_node && agro && can_shoot:
		var magic_beam_inst = magic_beam_rsrcs.instantiate()
		magic_beam_inst.status_effect = magic_beam_effect_pool[randi_range(0, magic_beam_effect_pool.size() - 1)]
		if magic_beam_inst.status_effect == StatusEffect.BOUNCY:
			magic_beam_inst.effect_duration = 2.0
			magic_beam_inst.knockback_strength *= 1.5
		magic_beam_inst.direction = global_position.direction_to(Globals.player_node.global_position)
		magic_beam_inst.global_position = global_position + magic_beam_inst.direction * 180
		magic_beam_inst.beam_owner = self
		get_parent().add_child(magic_beam_inst)
		
		$BeamCD.wait_time = 3.0 + randf_range(0.2, 1.0)
		$BeamCD.start()
		can_shoot = false
	
	char_entity_move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		agro = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		agro = false


func _on_beam_cd_timeout() -> void:
	can_shoot = true

func _on_wander_cd_timeout() -> void:
	next_wander_target()
	
	$WanderCD.wait_time = 3.0 + randf_range(0.2, 1.0)
	$WanderCD.start()
	wander_start_pos = global_position
	prev_pos = wander_start_pos
