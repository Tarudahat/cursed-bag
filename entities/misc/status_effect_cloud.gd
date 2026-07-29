extends Area2D

@export var status_effect: CharEntity.StatusEffect = CharEntity.StatusEffect.SLOW
@export var effect_duration: float = 5.0

@export var cloud_duration: float = 2
@export var re_poof_interval: float = 1

var should_fade_out: bool = false
var should_poof: bool = false

func _ready() -> void:
	$RePoofTimer.wait_time = re_poof_interval
	$ActiveTimer.wait_time = cloud_duration

func _process(delta: float) -> void:
	if should_poof:
		$CollisionShape2D.disabled = false
		$AnimationPlayer.play("poof")	
		should_poof = false
	
	if should_fade_out:
		$CollisionShape2D.disabled = true
		$AnimationPlayer.play("fade_out")
		should_fade_out = false

func _on_body_entered(body: Node2D) -> void:
	if body is CharEntity:
		if !body.has_status_effect(status_effect):
			body.apply_status_effect(status_effect, effect_duration)

func _on_active_timer_timeout() -> void:
	should_fade_out = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade_out":
			$RePoofTimer.start()
		"poof":
			$ActiveTimer.start()

func _on_re_poof_timer_timeout() -> void:
	should_poof = true
