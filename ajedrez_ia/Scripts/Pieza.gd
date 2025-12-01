extends Area2D
# ============================================
# PIEZA DE AJEDREZ
# Representa una pieza individual
# ============================================

signal pieza_clickeada(pieza)

# --- Tipos de piezas ---
enum TipoPieza { NINGUNA, PEON, TORRE, CABALLO, ALFIL, REINA, REY }
enum ColorPieza { NINGUNO, BLANCO, NEGRO }

# --- Propiedades ---
var tipo: int = TipoPieza.NINGUNA
var color: int = ColorPieza.NINGUNO
var posicion_tablero: Vector2i = Vector2i.ZERO
var esta_seleccionada: bool = false

# --- Referencias ---
@onready var sprite = $Sprite2D
@onready var indicador_seleccion = $IndicadorSeleccion

# --- Texturas de las piezas ---
# Rutas a los sprites en Assets/Pieces/
var texturas_piezas = {
	# Blancas
	Vector2i(TipoPieza.PEON, ColorPieza.BLANCO): "res://Assets/Pieces/white_pawn.png",
	Vector2i(TipoPieza.TORRE, ColorPieza.BLANCO): "res://Assets/Pieces/white_rook.png",
	Vector2i(TipoPieza.CABALLO, ColorPieza.BLANCO): "res://Assets/Pieces/white_knight.png",
	Vector2i(TipoPieza.ALFIL, ColorPieza.BLANCO): "res://Assets/Pieces/white_bishop.png",
	Vector2i(TipoPieza.REINA, ColorPieza.BLANCO): "res://Assets/Pieces/white_queen.png",
	Vector2i(TipoPieza.REY, ColorPieza.BLANCO): "res://Assets/Pieces/white_king.png",
	# Negras
	Vector2i(TipoPieza.PEON, ColorPieza.NEGRO): "res://Assets/Pieces/black_pawn.png",
	Vector2i(TipoPieza.TORRE, ColorPieza.NEGRO): "res://Assets/Pieces/black_rook.png",
	Vector2i(TipoPieza.CABALLO, ColorPieza.NEGRO): "res://Assets/Pieces/black_knight.png",
	Vector2i(TipoPieza.ALFIL, ColorPieza.NEGRO): "res://Assets/Pieces/black_bishop.png",
	Vector2i(TipoPieza.REINA, ColorPieza.NEGRO): "res://Assets/Pieces/black_queen.png",
	Vector2i(TipoPieza.REY, ColorPieza.NEGRO): "res://Assets/Pieces/black_king.png",
}

func _ready():
	input_event.connect(_al_input)
	indicador_seleccion.visible = false
	_actualizar_sprite()

func _actualizar_sprite():
	"""
	Actualiza el sprite según el tipo y color de la pieza
	"""
	var clave = Vector2i(tipo, color)
	if texturas_piezas.has(clave):
		sprite.texture = load(texturas_piezas[clave])

func seleccionar():
	"""
	Marca la pieza como seleccionada
	"""
	esta_seleccionada = true
	indicador_seleccion.visible = true

func deseleccionar():
	"""
	Quita la selección de la pieza
	"""
	esta_seleccionada = false
	indicador_seleccion.visible = false

func _al_input(viewport, evento, shape_idx):
	"""
	Maneja los eventos de entrada en la pieza
	"""
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
			emit_signal("pieza_clickeada", self)

func clone(_board):
	"""
	Crea una copia ligera de la pieza para simulación de la IA.
	Usa PieceSimulation en lugar de duplicar nodos de Godot.
	"""
	return PieceSimulation.new(tipo, color, Vector2(posicion_tablero.x, posicion_tablero.y), _board, false)
