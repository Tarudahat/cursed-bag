extends Node2D

var orb = preload("res://entities/terrain/puzzles/orb_button.tscn")

@export var orb_count: int = 3

var orb_instances: Array

var current_sequence_len: int = 2
var answer_sequence: Array

var input_sequence: Array
var playing_sequence_idx: int = 0
var playing_sequence: bool = false

signal puzzle_failed
signal puzzle_succeeded

func _ready() -> void:
	# spawn orbs
	for orb_idx in orb_count:
		var orb_instance = orb.instantiate()
		orb_instances.append(orb_instance)
		orb_instance.global_position = global_position + Vector2.RIGHT * 600 * orb_idx
		# connect got_hit 
		orb_instance.got_hit.connect(handle_hit.bind(orb_idx))
		get_parent().call_deferred("add_child", orb_instance)
	
	for seq_entry_idx in round(2):
		answer_sequence.append(randi_range(0, orb_count - 1))
	$Timer.start()


func handle_hit(hp: int, orb_idx: int) -> void:
	if !playing_sequence:
		input_sequence.append(orb_idx)
		orb_instances[orb_idx].glow()
		
		# any mistakes so far?
		for seq_idx in input_sequence.size():
			if input_sequence[seq_idx] == answer_sequence[seq_idx]:
				if input_sequence.size() == current_sequence_len: # correctly did the stage
					current_sequence_len += 1
					
					if current_sequence_len >= answer_sequence.size():
						emit_signal("puzzle_succeeded")
						playing_sequence = true
					else:
						playing_sequence_idx = 0
						$Timer.start()
						
					input_sequence = []
					break
			else:
				emit_signal("puzzle_failed")
				# reset seq, replay simon
				input_sequence = []
				playing_sequence_idx = 0
				$Timer.start()


func _on_timer_timeout() -> void:
	playing_sequence = true
	call_deferred("play_sequence")

func play_sequence():
	if playing_sequence_idx < current_sequence_len:
		orb_instances[answer_sequence[playing_sequence_idx]].glow()
		playing_sequence_idx += 1
		$Timer.start()
	else:
		playing_sequence = false
