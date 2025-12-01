extends Control

# ============================================
# VISUALIZADOR DE RAZONAMIENTO DE LA IA
# ============================================

@onready var etiqueta_info = $VBoxContainer/EtiquetaInfo

func mostrar_razonamiento(arbol: Dictionary):
	if etiqueta_info:
		etiqueta_info.text = "Evaluación: " + str(arbol.get("evaluacion", 0))

func limpiar():
	if etiqueta_info:
		etiqueta_info.text = ""
