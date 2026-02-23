extends TextureRect

var can_leave = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = str(int(Globals.player_gems))
	if Globals.player_gems < 50:
		$Label2.text = "F"
	elif Globals.player_gems < 200:
		$Label2.text = "C"
	elif Globals.player_gems < 500:
		$Label2.text = "B"
	elif Globals.player_gems < 750:
		$Label2.text = "A"
	elif Globals.player_gems < 950:
		$Label2.text = "S"
	else:
		$Label2.text = "S+"
		
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_leave && Input.is_action_just_pressed("hit_btn"):
		self.queue_free()
		Globals.title_screen()


func _on_timer_timeout() -> void:
	can_leave = true
	
