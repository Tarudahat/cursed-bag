extends CharEnemy
class_name Boss

enum attack_stage {THINK, WINDUP, ATTACK, STUN}

@onready var atk_stage_timer: Timer
var current_atk_stage: attack_stage = attack_stage.THINK
var current_atk_id: int = 0
var attack_stage_durations: Dictionary = \
{attack_stage.THINK: 0.0, attack_stage.WINDUP: 0.0,
 attack_stage.ATTACK: 0.0, attack_stage.STUN: 0.0}

signal start_windup(atk_id: int)
signal start_attack(atk_id: int)
signal start_stun(atk_id: int)
signal start_think

func next_stage(stage: attack_stage) -> attack_stage:
	return (stage + 1) % attack_stage.size()

func _ready() -> void:
	super()
	
	Globals.boss = self
	atk_stage_timer = Timer.new()
	atk_stage_timer.wait_time = 0.1
	add_child(atk_stage_timer)
	atk_stage_timer.timeout.connect(_on_atk_stage_timer_timeout)
	
func _on_atk_stage_timer_timeout():
	# start timer next stage
	current_atk_stage = next_stage(current_atk_stage)
	atk_stage_timer.wait_time = \
	 attack_stage_durations[current_atk_stage]
	atk_stage_timer.start()
	match current_atk_stage:
		attack_stage.THINK:
			emit_signal("start_think") # new atk will be chosen by subclass
		attack_stage.WINDUP:
			emit_signal("start_windup", current_atk_id)
		attack_stage.ATTACK:
			emit_signal("start_attack", current_atk_id)
		attack_stage.STUN:
			emit_signal("start_stun", current_atk_id)
