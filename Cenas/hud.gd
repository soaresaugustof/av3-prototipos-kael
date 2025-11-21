extends CanvasLayer
@onready var label: Label = $Control/Label
@onready var kael: Kael = $"../Kael"

func _process(delta: float) -> void:
	label.text = "Dígrafos coletados: " + str(kael.score) + "/" + str(kael.MaxScore)
