extends CharacterBody2D

class_name Kael

@export_group("Locomotion")
@export var speed = 200
@export var jump_velocity = -350
@export var run_speed_damping = 0.5

@export_group("Audio")
# Distância MÁXIMA de onde o som espacial do dígrafo é audível (em pixels).
# Reduzido para 300.0 para um alcance mais localizado.
@export var digrafo_sound_falloff_distance = 300.0 

# Referência ao nó Label para exibir legendas. 
# Deve ser arrastado do Inspetor.
@export var subtitle_label: Label 

# Dicionário de narrações (texto e caminho para o arquivo de áudio)
var narration_data = {
	"Digrafo1": {"text": "A chave do ninho te guia no que lhe trouxe sossego.", "audio_path": "res://audio/fala_digrafo_1.ogg", "duration": 4.5},
	"Digrafo2": {"text": "Com a união dos fragmentos, o mapa se revela!", "audio_path": "res://audio/fala_digrafo_2.ogg", "duration": 3.0},
	"Digrafo3": {"text": "O conhecimento está restaurado. Avance!", "audio_path": "res://audio/fala_digrafo_3.ogg", "duration": 2.5}
	# Adicione mais conforme necessário
}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- NÓS DE ÁUDIO ---
# Estes nós DEVEM ser filhos do nó Kael.
@onready var jump = $Jump
@onready var restore_digrafo = $RestoreDigrafo
@onready var narration_player = $NarrationPlayer


func _physics_process(delta: float) -> void:
	
	# --- Lógica da Gravidade e Movimento ---
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Lógica de Pulo e SFX
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		jump.play() # Toca o som de pulo
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
	
	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x,0,speed * delta)
	
	$AnimatedSprite2D._trigger_animation(velocity, direction)
	
	move_and_slide()
	
	# --- Lógica de Volume Dinâmico (Spatial) ---
	_update_digrafo_volume()


# Função para ajustar o volume do SomDigrafo com base na proximidade do Kael ao Dígrafo
func _update_digrafo_volume():
	# Assume que todos os Dígrafos são irmãos do nó Kael.
	var digrafo_nodes = get_parent().get_children().filter(
		func(node): return node.name.begins_with("Digrafo")
	)
	
	for digrafo in digrafo_nodes:
		# Busca o nó AudioStreamPlayer que é filho do Dígrafo
		var som_digrafo = digrafo.find_child("SomDigrafo")
		
		# O volume dinâmico só é relevante se o dígrafo ainda não foi coletado (e o nó existe)
		if is_instance_valid(som_digrafo) and digrafo.find_child("AnimatedSprite2D").visible:
			var distance = global_position.distance_to(digrafo.global_position)
			
			# Mapeamento de Proximidade: 1.0 (Perto) -> 0.0 (Longe)
			# Clamp garante que o valor fique entre 0.0 e 1.0
			var proximity = 1.0 - clamp(distance / digrafo_sound_falloff_distance, 0.0, 1.0)
			
			# Conversão para Decibéis (dB): De -50 dB (mudo) a 0 dB (volume máximo)
			var min_db = -50.0
			var max_db = 0.0
			var new_volume_db = lerp(min_db, max_db, proximity)
			
			som_digrafo.volume_db = new_volume_db


# Função auxiliar para disparar a narração e as legendas
func play_narration(data: Dictionary):
	if is_instance_valid(narration_player):
		# 1. Carrega e toca o áudio narrado
		var narration_stream = load(data.audio_path) 
		narration_player.stream = narration_stream
		narration_player.play()
	
	if is_instance_valid(subtitle_label):
		# 2. Exibe a legenda
		subtitle_label.text = data.text
		subtitle_label.show()
		
		# 3. Cria um Timer para esconder a legenda após a duração da fala
		get_tree().create_timer(data.duration).timeout.connect(hide_subtitle)

func hide_subtitle():
	if is_instance_valid(subtitle_label):
		subtitle_label.hide()


# --- Funções de Sinal (Restauração de Dígrafos) ---

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Colisão de morte/reinício
	if area is Area2D:
		get_tree().reload_current_scene()


func _on_digrafo_1_area_entered(area: Area2D) -> void:
	var digrafo_node = $"../Digrafo1"
	
	# 1. Para o som espacial (SomDigrafo) e oculta o sprite
	var som_digrafo = digrafo_node.find_child("SomDigrafo")
	if is_instance_valid(som_digrafo):
		som_digrafo.stop()
		som_digrafo.queue_free() # Remove o nó de som espacial 
		
	digrafo_node.find_child("AnimatedSprite2D").visible = false

	# 2. Toca o SFX de pontuação/coleta
	restore_digrafo.play() 

	# 3. Dispara a narração e legendas
	play_narration(narration_data["Digrafo1"])


func _on_digrafo_2_area_entered(area: Area2D) -> void:
	var digrafo_node = $"../Digrafo2"
	
	# 1. Para o som espacial (SomDigrafo) e oculta o sprite
	var som_digrafo = digrafo_node.find_child("SomDigrafo")
	if is_instance_valid(som_digrafo):
		som_digrafo.stop()
		som_digrafo.queue_free()
		
	digrafo_node.find_child("AnimatedSprite2D").visible = false

	# 2. Toca o SFX de pontuação/coleta
	restore_digrafo.play() 

	# 3. Dispara a narração e legendas
	play_narration(narration_data["Digrafo2"])


func _on_digrafo_3_area_entered(area: Area2D) -> void:
	var digrafo_node = $"../Digrafo3"
	
	# 1. Para o som espacial (SomDigrafo) e oculta o sprite
	var som_digrafo = digrafo_node.find_child("SomDigrafo")
	if is_instance_valid(som_digrafo):
		som_digrafo.stop()
		som_digrafo.queue_free()
		
	digrafo_node.find_child("AnimatedSprite2D").visible = false

	# 2. Toca o SFX de pontuação/coleta
	restore_digrafo.play() 

	# 3. Dispara a narração e legendas
	play_narration(narration_data["Digrafo3"])
