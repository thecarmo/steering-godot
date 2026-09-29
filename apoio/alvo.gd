extends CharacterBody2D

func mover(delta: float) -> void:
	position += velocity * delta
	if position.x < 180.0 or position.x > 960.0:
		position.x = clampf(position.x, 180.0, 960.0)
		velocity.x *= -1.0
