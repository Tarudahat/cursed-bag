extends CharEntity
class_name CharEnemy

var gem = preload("res://entities/misc/gem.tscn")

@export var value = 10
@export var default_death = true

var atk = 5
var speed = 500

func _ready() -> void:
	super() # init hp and timers
	auto_free_on_death = false

func damage(amount: int) -> void:
	if can_get_hit:
		can_get_hit = false
		dmg_timer.start()
		hp -= amount
		emit_signal("got_hit", hp)
		
		if hp <= 0:
			emit_signal("died")
			if default_death:
				for i in value:
					var gem_inst = gem.instantiate()
					gem_inst.position = position + Vector2(randi_range(-10, 10), randi_range(-10, 10))
					gem_inst.value = 1
					get_parent().add_child.call_deferred(gem_inst)
				self.queue_free()
