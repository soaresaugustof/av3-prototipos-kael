extends AnimatedSprite2D

func _trigger_animation(velocity: Vector2, direction: int):
	
	if direction != 0:
		scale.x = direction
	
	if not get_parent().is_on_floor():
		play("jump")

	elif velocity.x != 0:
		play("run")
	else:
		play("idle")
