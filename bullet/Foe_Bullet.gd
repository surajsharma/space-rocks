extends Area2D

@export var speed = 1000
@export var damage = 15

func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.x * speed * delta


func _on_body_entered(body):
	if body.name == "Player":
		body.shield -= damage
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
