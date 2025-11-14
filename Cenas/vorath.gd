extends Area2D

class_name Vorath

var h_speed: float = 0.0
var v_speed: float = 100.0
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	position.x -= h_speed * delta
	
	if !ray_cast_2d.is_colliding():
		position.y += v_speed * delta
