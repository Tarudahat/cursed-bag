extends CharEnemy

@export var max_value = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


func _on_died() -> void:
	for i in randi_range(0, max_value):
		var gem_inst = gem.instantiate()
		gem_inst.position = position + Vector2(randi_range(-10, 10), randi_range(-10, 10))
		gem_inst.value = 1
		get_parent().add_child.call_deferred(gem_inst)
	
	$whole.visible = false
	$broken.visible = true
	$CollisionShape2D.set_deferred("disabled", true)
