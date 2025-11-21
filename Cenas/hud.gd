extends CanvasLayer
@onready var label: Label = $Control/Label
@onready var kael: Kael = $"../Kael"

func _process(delta: float) -> void:
	label.text = "DIGRAFOS COLETADOS: " + str(kael.score) + "/" + str(kael.MaxScore)
