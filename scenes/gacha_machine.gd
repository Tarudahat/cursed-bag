extends Node

var balls_rsrc = preload("res://scenes/gacha_ball.tscn")
var gacha_balls: Array[Node2D] = []

var rolling: bool = false

func _ready() -> void:
	var gotten_gacha_count: int = Persistant.persistant_data["gacha_items"].size()\
		+ Persistant.persistant_data["gacha_skins"].size()\
		+ Persistant.persistant_data["gacha_weapons"].size()
		
	for i in Gacha.gacha_max - gotten_gacha_count:
		var ball_inst = balls_rsrc.instantiate()
		gacha_balls.append(ball_inst)
		ball_inst.global_position = $GachaBalls.global_position + 50*Vector2(cos(i/10), sin(i/10))
		add_child(ball_inst)
		
	$Sprite2D/Label.text = str(Persistant.persistant_data["gem_count"])
	

# --- anim slop ---

func mix():
	for ball in gacha_balls:
		if ball && ball.global_position.y > $Camera2D.global_position.y - 350:
			var t = ($rumbling_timer.time_left / $rumbling_timer.wait_time) * 2 * PI 
			ball.apply_force(Vector2.UP * sin(t*10) * 10000 + Vector2.LEFT*5000, Vector2.DOWN*50) 

func free_bottom_ball():
	var max_y: int = -99999
	var max_ball = -1
	for ball_idx in gacha_balls.size():
		if gacha_balls[ball_idx] && max_y < gacha_balls[ball_idx].global_position.y:
			max_ball = ball_idx
			max_y = gacha_balls[ball_idx].global_position.y
			
	if max_ball > -1:
		gacha_balls[max_ball].queue_free()
		gacha_balls[max_ball] = null
	
func _physics_process(delta: float) -> void:
	if rolling:
		mix()

func _on_rumbling_timer_timeout() -> void:
	rolling = false
	$waitabit.start()

# --- ---- ---- ---

func _on_waitabit_timeout() -> void:
	call_deferred("free_bottom_ball")
	
	Persistant.persistant_data["gem_count"] -= Gacha.GACHA_ROLL_COST
	
	var roll = Gacha.roll()
	var item_type: int = roll.x
	var item = roll.y
		
	Persistant.persistant_data[["gacha_weapons","gacha_skins","gacha_items"][item_type]].append(item)

	$Label.text = str(item_type) + " W|S|I " + str(item)


func _on_button_button_up() -> void:
	if Persistant.persistant_data["gem_count"] >= Gacha.GACHA_ROLL_COST:
		if !Gacha.all_collected():
			rolling = true
			$rumbling_timer.call_deferred("start")
		else:
			print("gg u have them all")
		$Sprite2D/Label.text = str(Persistant.persistant_data["gem_count"])


func _on_button_2_button_up() -> void:
	Globals.title_screen()
	self.queue_free()
