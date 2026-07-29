extends CharEnemy

var player_in_range: bool = false

func _ready() -> void:
	super()
	$StatusEffectCloud/RePoofTimer.wait_time = 999999

func _on_agro_body_entered(body: Node2D) -> void:
	if body is Player:
		$StatusEffectCloud/RePoofTimer.wait_time = $StatusEffectCloud.re_poof_interval
		$StatusEffectCloud/ActiveTimer.wait_time = $StatusEffectCloud.cloud_duration
		if !$StatusEffectCloud/AnimationPlayer.is_playing() && $StatusEffectCloud/ActiveTimer.time_left == 0.0:
			$StatusEffectCloud/AnimationPlayer.play("poof")

func _on_agro_body_exited(body: Node2D) -> void:
	if body is Player:
		$StatusEffectCloud/RePoofTimer.wait_time = 999999


func _on_got_hit(hp: Variant) -> void:
	$Sprite2D.material.set_shader_parameter("enabled", true)


func _on_inv_end() -> void:
	$Sprite2D.material.set_shader_parameter("enabled", false)
