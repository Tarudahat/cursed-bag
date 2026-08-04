extends Area2D

@export var dir = Vector2.UP
@export var dist = 750

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if !body.should_change_screen_target:
			body.should_change_screen_target = true
			body.moved_room = true
			body.global_position += dir * dist
			body.room_respawn_point = body.global_position
