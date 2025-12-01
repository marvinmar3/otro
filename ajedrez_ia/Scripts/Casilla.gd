extends Area2D
# ============================================
# CASILLA DEL TABLERO DE AJEDREZ
# ============================================

signal casilla_clickeada(casilla)

var coordenadas: Vector2i = Vector2i.ZERO
var es_clara: bool = true

@onready var fondo = $ColorRect
@onready var resaltado = $Resaltado

const COLOR_CLARO = Color(0.9, 0.85, 0.7)
const COLOR_OSCURO = Color(0.6, 0.4, 0.2)
const COLOR_RESALTADO = Color(0.3, 0.8, 0.3, 0.5)

func _ready():
	input_event.connect(_al_input)
	resaltado.visible = false

func establecer_color(clara: bool):
	"""
	Establece el color de la casilla
	"""
	es_clara = clara
	if fondo:
		fondo.color = COLOR_CLARO if clara else COLOR_OSCURO

func resaltar():
	"""
	Muestra el indicador de casilla válida
	"""
	resaltado.visible = true
	resaltado.color = COLOR_RESALTADO

func quitar_resaltado():
	"""
	Oculta el indicador de casilla válida
	"""
	resaltado.visible = false

func _al_input(viewport, evento, shape_idx):
	"""
	Maneja los eventos de entrada en la casilla
	"""
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
			emit_signal("casilla_clickeada", self)
