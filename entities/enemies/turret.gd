extends StaticEnemy

var bullet_node = preload("res://entities/enemies/bullet.tscn")

var wave_count = 4
var wave = 1
var can_shoot_wave = true
var can_shoot = true

func _ready():
	super()
	$Sprite2D.material.set_shader_parameter("enabled", false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_shoot && can_shoot_wave:
		var ang = 0
		if wave % 2 == 0:
			ang = PI / 8
		for i in range(8):
			var blast = bullet_node.instantiate()
			blast.direction = Vector2(cos(ang), sin(ang))
			blast.position = position + blast.direction*10
			get_parent().add_child(blast)
			ang += PI / 4
			
		$shoot_wave_cooldown.start()
		can_shoot_wave = false
		wave += 1 
		if wave == wave_count:
			can_shoot = false
			$shoot_pattern_cooldown.start()
			wave = 0


func _on_shoot_pattern_cooldown_timeout() -> void:
	can_shoot = true

func _on_shoot_wave_cooldown_timeout() -> void:
	can_shoot_wave = true
	
func _on_got_hit(hp, val) -> void:
	$Sprite2D.material.set_shader_parameter("enabled", true)

func _on_inv_end() -> void:
	$Sprite2D.material.set_shader_parameter("enabled", false)
	
