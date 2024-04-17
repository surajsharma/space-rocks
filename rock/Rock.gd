extends RigidBody2D
var screensize = Vector2.ZERO
var size
var radius
var scale_factor = 0.2
signal exploded

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius,
	screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius,
	screensize.y + radius)
	physics_state.transform = xform


func start(_position, _velocity, _size):
	position = _position
	size = _size
	mass = 1.5 * size
	$Sprite2D.scale = Vector2.ONE * scale_factor * size
	radius = int($Sprite2D.texture.get_size().x / 2 *
	$Sprite2D.scale.x)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)
	$Explosion.scale = Vector2.ONE * 0.75 * size


func explode():
	$CollisionShape2D.set_deferred("disabled", true)
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	exploded.emit(size, radius, position, linear_velocity)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	queue_free()	
