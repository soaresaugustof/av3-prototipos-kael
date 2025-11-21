extends Area2D

class_name Vorath

var h_speed: float = 0.0
var v_speed: float = 100.0
var is_defeated: bool = false

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Sprite

func _process(delta: float) -> void:
	if is_defeated:
		return
		
	position.x -= h_speed * delta
	
	if is_instance_valid(ray_cast_2d) and !ray_cast_2d.is_colliding():
		position.y += v_speed * delta

func _ready():
	animated_sprite_2d.play("default") 
	
	if is_instance_valid(animated_sprite_2d):
		if not animated_sprite_2d.animation_finished.is_connected(_on_defeat_animation_finished):
			animated_sprite_2d.animation_finished.connect(_on_defeat_animation_finished)

func defeat():
	print("DEBUG [Vorath]: Função defeat() chamada, tentando play('defeat').") 
	
	if is_instance_valid(animated_sprite_2d): 
		is_defeated = true
		
		animated_sprite_2d.play("defeat")
		var timer_duration = 2.0
		
		get_tree().create_timer(timer_duration).timeout.connect(
			func():
				queue_free()
		)
		print("DEBUG [Vorath]: Animação 'defeat' iniciada.") 
		
	else:
		print("DEBUG [Vorath]: NÓ DE ANIMAÇÃO AINDA INVÁLIDO!")
		queue_free()

func _on_defeat_animation_finished():
	if animated_sprite_2d.animation == "defeat":
		queue_free()
