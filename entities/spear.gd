extends Area2D
class_name Spear

@export var dmg = 15
@export var speed = 2.1
@export var knockback_strength = 1000
@export var knockback_strength_throw = 1000
@export var knockback_strength_jab = 1500
@export var despawn_after_land: bool = false

var spear_owner

var t: float = 0
var target_position: Vector2
var starting_position: Vector2
var throw_height: float = 300

var being_thrown: bool = false
var being_jabbed: bool = false

var on_ground: bool = false
var should_despawn: bool = false
var should_reattach: bool = false

var started_despawn: bool = false
var shield_blocked: bool = false

signal spear_landed(target_pos)
signal jab_ended

func _ready() -> void:
	$CollisionShape2D.disabled = true

func reattach_to_owner() -> void:
	spear_owner.get_parent().remove_child(self)
	spear_owner.add_child(self)
	global_position = spear_owner.global_position
	on_ground = false
	$AnimationPlayer.play("RESET")
	rotation_degrees = -70
	$CollisionShape2D.shape.radius = 75
	$CollisionShape2D.disabled = true

func init_throw(target: Vector2):
	if !(spear_owner && spear_owner is Player):
		spear_owner.remove_child(self)
		spear_owner.get_parent().add_child(self)

	target_position = target
	shield_blocked = false
	$AnimationPlayer.play("charge_throw")
	t = 0

	knockback_strength = knockback_strength_throw
	$CollisionShape2D.disabled = true
	being_thrown = true

func perform_throw(delta):
	var mid_point = starting_position + (target_position - starting_position) / 2 + Vector2.UP * throw_height
	var new_pos = Globals.bezier_curve(starting_position, mid_point, target_position, 0.01)
	
	if $AnimationPlayer.is_playing():
		if spear_owner != null:
			starting_position = spear_owner.global_position
			if spear_owner.get("enemy_target_position"):
				target_position = spear_owner.enemy_target_position
		global_position = starting_position
	else: # after charge animation
		if t == 0 && spear_owner && spear_owner is Player:
			spear_owner.remove_child(self)
			spear_owner.get_parent().add_child(self)
	
		t += delta * speed
		new_pos = Globals.bezier_curve(starting_position, mid_point, target_position, t)

		if t < 0.90:
			look_at(new_pos)
		global_position = new_pos

		if t >= 0.20:
			if Globals.level_node && Globals.level_node.is_in_wall($CollisionShape2D.global_position):
				shield_blocked = true

		if t >= 0.75:
			$CollisionShape2D.disabled = false
				
		if t >= 1.0 || shield_blocked:
			$CollisionShape2D.shape.radius = 200
			on_ground = true
			emit_signal("spear_landed", target_position)
			being_thrown = false

func init_jab(target: Vector2):
	$AnimationPlayer.play("jab")
	look_at(target)
	knockback_strength = knockback_strength_jab
	$CollisionShape2D.disabled = true
	being_jabbed = true
		
func perform_jab():
	var t_lerp = $AnimationPlayer.current_animation_position / $AnimationPlayer.current_animation_length
	if t_lerp >= 0.9:
		$CollisionShape2D.disabled = false
	
	if t_lerp >= 1.0:
		emit_signal("jab_ended")
		$AnimationPlayer.play("RESET")
		being_jabbed = false
		
func _physics_process(delta: float) -> void:
	if being_thrown:
		perform_throw(delta)
	elif being_jabbed:
		perform_jab()
	
	if should_despawn:
		self.queue_free()
	if should_reattach:
		reattach_to_owner()
		should_reattach = false

	if spear_owner == null && on_ground && !started_despawn:
		$DespawnTimer.start()
		started_despawn = true

func _on_body_entered(body: Node2D) -> void:
	if body != spear_owner:
		if body.get_name() == "Shield":
			shield_blocked = true
		elif body is CharEntity && !on_ground:
				body.knockback(global_position.direction_to(body.global_position) * knockback_strength)
				if spear_owner.has_status_effect(CharEntity.StatusEffect.BOUNCER):
					body.apply_status_effect(CharEntity.StatusEffect.BOUNCY)
				body.damage(dmg)
	elif on_ground:
		should_reattach = true

func _on_despawn_timer_timeout() -> void:
	should_despawn = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if despawn_after_land && (anim_name == "throw_left" || anim_name == "throw_right"):
		$DespawnTimer.start()
