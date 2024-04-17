extends Node

@export var rock_scene : PackedScene
@export var enemy_scene : PackedScene

var screensize = Vector2.ZERO
var level = 0
var score = 0
var playing = false


var backgrounds = {
	"BG_0": preload("res://assets/bg/0.png"),
	"BG_1": preload("res://assets/bg/1.jpg"),
	"BG_2": preload("res://assets/bg/2.jpg"),
	"BG_3": preload("res://assets/bg/3.jpg"),
	"BG_4": preload("res://assets/bg/4.jpg"),
	"BG_5": preload("res://assets/bg/5.jpg"),
	"BG_6": preload("res://assets/bg/6.jpg"),
	"BG_7": preload("res://assets/bg/7.jpg")
}


func new_level():
	$LevelUpSound.play()
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in level:
		spawn_rock(3)
	$EnemyTimer.start(randf_range(5, 10))
	
	# Calculate index using modulus
	var background_index = level % backgrounds.size()

	# Get background name using the index
	var selected_bg = backgrounds.keys()[background_index]
	if level != 1:
		$Background.texture =backgrounds[selected_bg]


func new_game():
# remove any old rocks from previous game
	$Music.play()
	get_tree().call_group("rocks", "queue_free")
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true
	set_process(true)


# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport().get_visible_rect().size
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y

	var scale = viewportWidth / $Background.texture.get_size().x
	
	# Optional: Center the sprite, required only if the sprite's Offset>Centered checkbox is set
	$Background.set_position(Vector2(viewportWidth/2, viewportHeight/2))

	# Set same scale value horizontally/vertically to maintain aspect ratio
	# If however you don't want to maintain aspect ratio, simply set different
	# scale along x and y
	$Background.set_scale(Vector2(scale, scale))
	
	for i in 3:
		spawn_rock(3)
	
	set_process(false)


func spawn_rock(size, pos=null, vel=null):
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var r = rock_scene.instantiate()
	r.screensize = screensize
	r.start(pos, vel, size)
	call_deferred("add_child", r)
	r.exploded.connect(self._on_rock_exploded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not playing:
		return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()


func _on_rock_exploded(size, radius, pos, vel):
	$ExplosionSound.play()
	if size <= 1:
		score += 10
		$HUD.update_score(score)
		return
	else:
		score += 5
		$HUD.update_score(score)
				
	for offset in [-1, 1]:
		var dir = $Player.position.direction_to(pos).orthogonal() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)


func game_over():
	playing = false
	$HUD.game_over()
	$Music.play()


func _input(event):
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
		var message = $HUD/VBoxContainer/Message
		if get_tree().paused:
			message.text = "Paused"
			message.show()
		else:
			message.text = ""
			message.hide()


func _on_enemy_timer_timeout():
	var e = enemy_scene.instantiate()
	add_child(e)
	e.target = $Player
	e.connect("foe_destroyed", on_foe_destroyed) 
	$EnemyTimer.start(randf_range(20, 40))


func on_foe_destroyed():
	score += 15
	$HUD.update_score(score)
