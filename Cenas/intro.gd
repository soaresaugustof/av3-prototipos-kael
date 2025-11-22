extends Control


var falas = [
	"No centro de Letrânia, a magia nasce das palavras.",
	"O Obelisco dos Sons foi destruído por Vorath, o Silenciador.",
	"Sem ele, a fala do povo se fragmentou… e a magia se perdeu.",
	"Somente você, Kael Verbatim, pode restaurar os dígrafos sagrados.",
    "Sua jornada começa agora."
]

var indice_fala = 0
var texto_atual = ""
var pos_letra = 0
var velocidade = 0.1

func _ready():
	mostrar_fala()

func mostrar_fala():
	texto_atual = falas[indice_fala]
	pos_letra = 0
	$DialogLabel.text = ""
	$DialogTimer.wait_time = velocidade
	$DialogTimer.start()

func avancar():
	indice_fala += 1
	if indice_fala < falas.size():
		mostrar_fala()
	else:
		get_tree().change_scene_to_file("res://Cenas/main.tscn")


func _on_dialog_timer_timeout() -> void:
	if pos_letra < texto_atual.length():
		$DialogLabel.text += texto_atual[pos_letra]
		pos_letra += 1
		$DialogTimer.start()
	else:
		await get_tree().create_timer(0.6).timeout
		avancar()
