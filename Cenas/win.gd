extends Control

@onready var main_label = $VBoxContainer/Label
@onready var typing_timer = $VBoxContainer/Label/TypingTimer 

var full_text = "Conseguimos recuperar
o obelisco! 
Parabéns!"
var pos_letra = 0
var velocidade_digitacao = 0.1 


func _ready() -> void:

	full_text = main_label.text

	main_label.text = ""

	if is_instance_valid(typing_timer):
		typing_timer.wait_time = velocidade_digitacao
		typing_timer.start()
	else:

		print("AVISO: O nó 'TypingTimer' não foi encontrado. O texto aparecerá instantaneamente.")
		main_label.text = full_text


# Função acionada pelo 'timeout' do TypingTimer
func _on_typing_timer_timeout():
	# Verifica se ainda há letras para digitar
	if pos_letra < full_text.length():
		# Adiciona a próxima letra ao texto
		main_label.text += full_text[pos_letra]
		pos_letra += 1
		
		# Continua o timer para o próximo caractere
		typing_timer.start()
	else:
		# PARA o timer quando o texto estiver completo (NÃO desaparece)
		typing_timer.stop()


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/title_screen.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
