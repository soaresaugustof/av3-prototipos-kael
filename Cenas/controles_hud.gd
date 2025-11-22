extends CanvasLayer

@export var tempo_exibicao: float = 4.0

@onready var painel_controles = $PainelControles
@onready var label_mover = $PainelControles/ControlesHBox/LabelMover 
@onready var label_pular = $PainelControles/ControlesHBox/LabelPular
@onready var timer_controles = $PainelControles/TimerControles


func _ready():
	label_mover.text = "Setas ← →: Mover"
	label_pular.text = "[Space]: Pular"
	
	painel_controles.show()
	
	if is_instance_valid(timer_controles):
		timer_controles.wait_time = tempo_exibicao
		
		if not timer_controles.timeout.is_connected(_on_timer_controles_timeout):
			timer_controles.timeout.connect(_on_timer_controles_timeout)
			
		timer_controles.start()

func _on_timer_controles_timeout():
	painel_controles.hide()
	
	timer_controles.queue_free()
