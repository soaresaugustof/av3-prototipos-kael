extends CharacterBody2D

class_name Kael

@export_group("Locomotion")
@export var speed = 200
@export var jump_velocity = -350
@export var run_speed_damping = 0.5

@export_group("Fase")
@export var proxima_fase_path: String = ""
@export var tela_vitoria_path: String = "res://Cenas/tela_vitoria.tscn"

@export_group("Audio")
@export var digrafo_sound_falloff_distance = 300.0

@export_group("HUD")
@export var nome_da_fase: String = "Fase Desconhecida"
@export var hud_display_time: float = 3.0

@export_group("Hud Digrafo")
@export var nome_do_digrafo1: String = "Digrafo Desconhecido"
@export var nome_do_digrafo2: String = "Digrafo Desconhecido"
@export var nome_do_digrafo3: String = "Digrafo Desconhecido"
@export var digrafo_display_time: float = 3.0

@onready var nome_fase = $"HUDKael/NomeFase"
@onready var hud_timer = $"HUDKael/HUDTimer"

@onready var nome_digrafo = $"HUDDigrafo/FraseDigrafo"
@onready var digrafo_timer = $"HUDDigrafo/TimerDigrafo"

@export var subtitle_label: Label

@export var MaxScore = 3
@export var score = 0

var frase_completa = "Na manhã turva, o brilho antigo do trecho esculpido surgiu, nos guiou e quebrou o silêncio, esclarecendo o rumo que ressurgiu após o caos para o guerreiro."

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var jump = $Jump
@onready var restore_digrafo = $RestoreDigrafo
@onready var narration_player = $NarrationPlayer

func _ready() -> void:
	if is_instance_valid(nome_fase) and is_instance_valid(hud_timer):
		
		print("HUD de Fase: Pronto. Tentando exibir: ", nome_da_fase)
		
		nome_fase.text = nome_da_fase
		hud_timer.wait_time = hud_display_time
		
		if not hud_timer.timeout.is_connected(hide_fase_hud):
			hud_timer.timeout.connect(hide_fase_hud)
		
		show_fase_hud()
	else:
		print("ERRO CRÍTICO: Um ou mais nós do HUD não foram encontrados. (HUDKael/NomeFase ou HUDKael/HUDTimer)")


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		jump.play()
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
	
	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = lerp(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x,0,speed * delta)
	
	$AnimatedSprite2D._trigger_animation(velocity, direction)
	
	move_and_slide()
	
	_update_digrafo_volume()


func _update_digrafo_volume():
	var digrafo_nodes = get_parent().get_children().filter(
		func(node): return node.name.begins_with("Digrafo")
	)
	
	for digrafo in digrafo_nodes:
		var som_digrafo = digrafo.find_child("SomDigrafo")
		
		if is_instance_valid(som_digrafo) and digrafo.find_child("AnimatedSprite2D").visible:
			var distance = global_position.distance_to(digrafo.global_position)
			
			var proximity = 1.0 - clamp(distance / digrafo_sound_falloff_distance, 0.0, 1.0)
			
			var min_db = -50.0
			var max_db = 0.0
			var new_volume_db = lerp(min_db, max_db, proximity)
			
			som_digrafo.volume_db = new_volume_db


func play_narration(data: Dictionary):
	if is_instance_valid(narration_player):
		# 1. Carrega e toca o áudio narrado
		var narration_stream = load(data.audio_path)
		narration_player.stream = narration_stream
		narration_player.play()
	
	if is_instance_valid(subtitle_label):
		subtitle_label.text = data.text
		subtitle_label.show()
		
		get_tree().create_timer(data.duration).timeout.connect(hide_subtitle)

func hide_subtitle():
	if is_instance_valid(subtitle_label):
		subtitle_label.hide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Area2D:
		get_tree().change_scene_to_file("res://Cenas/game_over.tscn")


# --- Funções de Coleta do Dígrafo (Corrigidas) ---

func _on_digrafo_1_area_entered(area: Area2D) -> void:
	var digrafo_node = $"../Digrafo1"
	
	var som_digrafo = digrafo_node.find_child("SomDigrafo")
	if is_instance_valid(som_digrafo):
		som_digrafo.stop()
		som_digrafo.queue_free()
	
	nome_digrafo.text = nome_do_digrafo1
	digrafo_timer.wait_time = digrafo_display_time
		
	# Conecta APENAS UMA VEZ
	if not digrafo_timer.timeout.is_connected(hide_digrafo_hud):
		digrafo_timer.timeout.connect(hide_digrafo_hud)
		
	# CHAMA SEMPRE (Correção de Bug)
	show_digrafo_hud() 
	
	digrafo_node.find_child("AnimatedSprite2D").visible = false
	$"../Digrafo1/CollisionShape2D".queue_free()

	restore_digrafo.play()

	score += 1
	

func _on_digrafo_2_area_entered(area: Area2D) -> void:
	var digrafo_node = $"../Digrafo2"
	
	var som_digrafo = digrafo_node.find_child("SomDigrafo")
	if is_instance_valid(som_digrafo):
		som_digrafo.stop()
		som_digrafo.queue_free()
	
	nome_digrafo.text = nome_do_digrafo2
	digrafo_timer.wait_time = digrafo_display_time
		
	# Conecta APENAS UMA VEZ
	if not digrafo_timer.timeout.is_connected(hide_digrafo_hud):
		digrafo_timer.timeout.connect(hide_digrafo_hud)
		
	# CHAMA SEMPRE (Correção de Bug)
	show_digrafo_hud()
	
	digrafo_node.find_child("AnimatedSprite2D").visible = false
	$"../Digrafo2/CollisionShape2D".queue_free()

	restore_digrafo.play()

	score += 1


func _on_digrafo_3_area_entered(area: Area2D) -> void:
	var digrafo_node = $"../Digrafo3"
	
	var som_digrafo = digrafo_node.find_child("SomDigrafo")
	if is_instance_valid(som_digrafo):
		som_digrafo.stop()
		som_digrafo.queue_free()
	
	nome_digrafo.text = nome_do_digrafo3
	digrafo_timer.wait_time = digrafo_display_time
		
	# Conecta APENAS UMA VEZ
	if not digrafo_timer.timeout.is_connected(hide_digrafo_hud):
		digrafo_timer.timeout.connect(hide_digrafo_hud)
		
	# CHAMA SEMPRE (Correção de Bug)
	show_digrafo_hud()
	
	digrafo_node.find_child("AnimatedSprite2D").visible = false
	$"../Digrafo3/CollisionShape2D".queue_free()

	restore_digrafo.play()

	score += 1
	
	# --- LÓGICA DE DERROTA DO VORATH E FIM DE JOGO (Corrigida e Indentada) ---
	
	if nome_da_fase == "Fase Final: Torre do Silêncio": 
		var vorath_node = get_parent().find_child("Vorath")
		
		if is_instance_valid(vorath_node):
			print("Último Dígrafo coletado. Acionando derrota do Vorath.")
			
			var vorath_script = vorath_node as Vorath
			
			if is_instance_valid(vorath_script):
				vorath_script.defeat()
			else:
				print("ERRO: Script Vorath não encontrado. Usando call().")
				vorath_node.call("defeat")

			# Timer de 4s para animação e transição
			get_tree().create_timer(4.0).timeout.connect(
				func():
					if not tela_vitoria_path.is_empty():
						get_tree().change_scene_to_file(tela_vitoria_path)
					else:
						get_tree().quit()
			)
		else:
			# Se o Vorath não foi encontrado na fase final, transiciona imediatamente
			if not tela_vitoria_path.is_empty():
				get_tree().change_scene_to_file(tela_vitoria_path)
			else:
				get_tree().quit()


func _on_fim_de_cena_body_entered(body: Node2D) -> void:
	if body == self:
		
		if not proxima_fase_path.is_empty():
			get_tree().change_scene_to_file(proxima_fase_path)
		else:
			pass


func show_fase_hud():
	if is_instance_valid(nome_fase) and is_instance_valid(hud_timer):
		nome_fase.show()
		hud_timer.start()

func hide_fase_hud():
	if is_instance_valid(nome_fase):
		nome_fase.hide()

func show_digrafo_hud():
	if is_instance_valid(nome_digrafo) and is_instance_valid(digrafo_timer):
		nome_digrafo.show()
		digrafo_timer.start()

func hide_digrafo_hud():
	if is_instance_valid(nome_digrafo):
		nome_digrafo.hide()
