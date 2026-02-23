extends Area2D

@export var dir = Vector2.UP
@export var dist = 850

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position += dir * dist

		
