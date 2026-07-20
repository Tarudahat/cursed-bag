extends CharacterBody2D
class_name CharEntity

enum StatusEffect {STUN, POISON, SLOW, INSTANT_DEATH, BOUNCY, TINY}
var has_tick_timer: Dictionary[StatusEffect, bool] = {StatusEffect.POISON: true}

@export var hp: int = 10
var max_hp = hp
@export var knockback_strength: float = 3750
@export var knockback_resistance: float = 0
@export var active_status_effects: Array[StatusEffect] = []
@export var default_status_effect_behaviours: bool = true

@export var interacts_with_floor: bool = true
@export var should_free_on_fall_hole: bool = true
@export var auto_free_on_death: bool = true
@export var can_knockback_during_inv: bool = false

@export var inv_duration: float = 1.0
@export var status_durations: Dictionary[StatusEffect, float]

@onready var dmg_timer: Timer
@onready var status_timers: Dictionary[StatusEffect, Timer]
@onready var status_tick_timers: Dictionary[StatusEffect, Timer]
@onready var falling_timer: Timer

var should_emit_fell: bool = false
var play_hardcoded_falling_animation: bool = false
var hole_global_pos: Vector2
var falling_into_hole: bool = false
var should_free: bool = false

var can_get_hit: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO

var speed_multiply: float = 1.0
var default_scale: Vector2

signal got_hit(hp)
signal got_healed(hp)
signal got_knocked_back(knockback_velocity)
signal inv_end
signal died
signal fell_into_hole

signal got_status_effect(status_effect, duration)
signal got_status_ticked(status_effect)
signal status_effect_cleared(status_effect)

func _ready() -> void:
	max_hp = hp
	default_scale = scale

	# setup default falling animation timer
	falling_timer = Timer.new()
	falling_timer.wait_time = 1.0
	falling_timer.one_shot = true
	add_child(falling_timer)
	falling_timer.timeout.connect(_on_falling_timer_timeout)

	# setup dmg timers
	dmg_timer = Timer.new()
	if inv_duration != null:
		dmg_timer.wait_time = inv_duration
	else:
		dmg_timer.wait_time = 1.0
	
	add_child(dmg_timer)
	dmg_timer.timeout.connect(_on_dmg_timer_timeout)
	
	# setup status effect timers
	for status_effect in StatusEffect.values():
		status_timers[status_effect] = Timer.new()
		add_child(status_timers[status_effect])
		status_timers[status_effect].timeout.connect(clear_status_effect.bind(status_effect))

		if has_tick_timer.has(status_effect):
			status_tick_timers[status_effect] = Timer.new()
			status_tick_timers[status_effect].timeout.connect(tick_status_effect.bind(status_effect))


#### dmg taking utilities ####

func heal(amount: int) -> void:
	hp += amount
	emit_signal("got_healed", hp)

func damage(amount: int) -> void:
	# can get hit? take hit
	if can_get_hit:
		can_get_hit = false
		dmg_timer.start()
		hp -= amount
		emit_signal("got_hit", hp)
		
		# signal death on hp death
		if hp <= 0 || has_status_effect(StatusEffect.INSTANT_DEATH):
			emit_signal("died")
			
			if auto_free_on_death:
				queue_free()

func _on_dmg_timer_timeout() -> void:
	can_get_hit = true
	emit_signal("inv_end")

#### status effect utilities ####

func has_status_effect(status_effect: StatusEffect) -> bool:
	return active_status_effects.find(status_effect) != -1

func apply_status_effect(status_effect: StatusEffect, duration: float = status_durations.get(status_effect, 1.0), tick_delay: float = 0.0) -> void:
	if !has_status_effect(status_effect):
		active_status_effects.append(status_effect)

		if default_status_effect_behaviours:
			match status_effect:
				StatusEffect.SLOW:
					speed_multiply = 0.4
				StatusEffect.TINY:
					scale = default_scale * 0.65
				StatusEffect.STUN:
					speed_multiply = 0.0

	status_timers[status_effect].wait_time = duration
	status_timers[status_effect].start()

	var tick_timer = status_tick_timers.get(status_effect, null)
	if tick_timer != null:
		tick_timer.wait_time = tick_delay
		tick_timer.start()

	emit_signal("got_status_effect", status_effect, duration)

func clear_status_effect(status_effect: StatusEffect) -> void:
	if has_status_effect(status_effect):
		if default_status_effect_behaviours:
			match status_effect:
				StatusEffect.SLOW:
					speed_multiply = 1.0
				StatusEffect.STUN:
					speed_multiply = 1.0
				StatusEffect.TINY:
					scale = default_scale

		active_status_effects.erase(status_effect)
		emit_signal("status_effect_cleared", status_effect)

func tick_status_effect(status_effect: StatusEffect) -> void:
	emit_signal("got_status_ticked", status_effect)
	status_tick_timers[status_effect].start()

func char_entity_move_and_slide() -> bool:
	var is_bouncy = has_status_effect(StatusEffect.BOUNCY)

	if is_bouncy:
		velocity = knockback_velocity
	elif !knockback_velocity.is_equal_approx(Vector2.ZERO):
		velocity = knockback_velocity
		knockback_velocity = Vector2.ZERO

	if falling_into_hole:
		velocity = global_position.direction_to(hole_global_pos) * 100
		if play_hardcoded_falling_animation:
			rotation += 0.1
			scale *= 0.9

	var move_and_slide_res = move_and_slide()

	if !falling_into_hole:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			var tilemap_layer = collider as TileMapLayer
			if tilemap_layer && Globals.level_node && Globals.level_node.has_node("tilemap") && tilemap_layer == Globals.level_node.get_node("tilemap"):
				var tile_pos = Globals.level_node.global_to_tilemap(collision.get_position())
				hole_global_pos = Globals.level_node.tilemap_to_global(tile_pos)
				var tile_data = tilemap_layer.get_cell_tile_data(tile_pos)
				var is_hole = tile_data.has_custom_data("is_hole") && tile_data.get_custom_data("is_hole")

				if is_hole && !falling_into_hole:
					falling_into_hole = true
					var has_anime_player = has_node("AnimationPlayer")

					if has_anime_player:
						var anime_player = get_node("AnimationPlayer")
						if anime_player.has_animation("fall"):
							anime_player.play("fall")
					else:
						play_hardcoded_falling_animation = true

					falling_timer.start()
					falling_timer.wait_time = 1.0
				else:
					if is_bouncy:
						knockback_velocity = (collision.get_normal().bounce((knockback_velocity * Vector2(randf_range(-1, 1), randf_range(-1, 1))).normalized())) * knockback_velocity.length() * 1.05

	if should_free:
		queue_free()
	if should_emit_fell:
		emit_signal("fell_into_hole")
		should_emit_fell = false

	return move_and_slide_res

func _on_falling_timer_timeout() -> void:
	if should_free_on_fall_hole:
		should_free = true
	should_emit_fell = true
	
#### knockback utilities ####

func knockback(knockback_velocity_arg: Vector2) -> void:
	if can_get_hit || can_knockback_during_inv && !has_status_effect(StatusEffect.BOUNCY):
		knockback_velocity = knockback_velocity_arg * (1 - knockback_resistance)
		emit_signal("got_knocked_back", knockback_velocity)
