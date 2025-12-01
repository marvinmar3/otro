extends Node2D

# ============================================
# GESTIÓN DEL TABLERO DE AJEDREZ
# Maneja las piezas, casillas y movimientos
# ============================================

# --- Señales para comunicar eventos ---
signal movimiento_realizado(desde: Vector2i, hasta: Vector2i)
signal jaque_mate(ganador: int)
signal tablas()
signal pieza_seleccionada(pieza)

# --- Constantes del tablero ---
const TAMANO_TABLERO: int = 8  # 8x8 casillas
const TAMANO_CASILLA: int = 64  # Píxeles por casilla

# --- Tipos de piezas ---
enum TipoPieza { NINGUNA, PEON, TORRE, CABALLO, ALFIL, REINA, REY }
enum ColorPieza { NINGUNO, BLANCO, NEGRO }

# --- Estado del tablero ---
# Matriz 8x8 que representa el tablero
# Cada celda contiene un diccionario con {tipo, color}
var matriz_tablero: Array = []

# --- Variables de selección ---
var pieza_seleccionada_actual = null  # Referencia a la pieza seleccionada
var casillas_validas: Array = []  # Movimientos válidos de la pieza seleccionada

# --- Referencias a escenas ---
@onready var escena_casilla = preload("res://Scenes/Casilla.tscn")
@onready var escena_pieza = preload("res://Scenes/Pieza.tscn")

# --- Contenedores ---
var casillas: Array = []  # Matriz de nodos Casilla
var piezas: Array = []  # Lista de todas las piezas en el tablero

func _ready():
"""
Inicializa el tablero al cargar
"""
_crear_casillas()

func _crear_casillas():
"""
Crea las 64 casillas del tablero con colores alternados
"""
for fila in range(TAMANO_TABLERO):
var fila_casillas: Array = []
for columna in range(TAMANO_TABLERO):
var casilla = escena_casilla.instantiate()
casilla.position = Vector2(columna * TAMANO_CASILLA, fila * TAMANO_CASILLA)

# Alternar colores: blanco si suma par, negro si suma impar
var es_casilla_clara = (fila + columna) % 2 == 0
casilla.establecer_color(es_casilla_clara)
casilla.coordenadas = Vector2i(columna, fila)

# Conectar señal de clic
casilla.casilla_clickeada.connect(_al_clickear_casilla)

add_child(casilla)
fila_casillas.append(casilla)

casillas.append(fila_casillas)

func inicializar_tablero():
"""
Coloca todas las piezas en su posición inicial
"""
# Limpiar piezas existentes
for pieza in piezas:
pieza.queue_free()
piezas.clear()

# Inicializar matriz vacía
matriz_tablero = []
for fila in range(TAMANO_TABLERO):
var fila_tablero: Array = []
for columna in range(TAMANO_TABLERO):
fila_tablero.append({
"tipo": TipoPieza.NINGUNA,
"color": ColorPieza.NINGUNO
})
matriz_tablero.append(fila_tablero)

# --- Colocar piezas negras (arriba, filas 0 y 1) ---
_colocar_fila_principal(0, ColorPieza.NEGRO)
_colocar_fila_peones(1, ColorPieza.NEGRO)

# --- Colocar piezas blancas (abajo, filas 6 y 7) ---
_colocar_fila_peones(6, ColorPieza.BLANCO)
_colocar_fila_principal(7, ColorPieza.BLANCO)

func _colocar_fila_principal(fila: int, color: int):
"""
Coloca la fila de piezas principales (torres, caballos, etc.)
"""
var orden_piezas = [
TipoPieza.TORRE, TipoPieza.CABALLO, TipoPieza.ALFIL, TipoPieza.REINA,
TipoPieza.REY, TipoPieza.ALFIL, TipoPieza.CABALLO, TipoPieza.TORRE
]

for columna in range(TAMANO_TABLERO):
_crear_pieza(Vector2i(columna, fila), orden_piezas[columna], color)

func _colocar_fila_peones(fila: int, color: int):
"""
Coloca una fila completa de peones
"""
for columna in range(TAMANO_TABLERO):
_crear_pieza(Vector2i(columna, fila), TipoPieza.PEON, color)

func _crear_pieza(posicion: Vector2i, tipo: int, color: int):
"""
Crea una pieza y la coloca en el tablero
"""
var pieza = escena_pieza.instantiate()
pieza.tipo = tipo
pieza.color = color
pieza.posicion_tablero = posicion
pieza.position = Vector2(posicion.x * TAMANO_CASILLA, posicion.y * TAMANO_CASILLA)

# Conectar señal de clic en la pieza
pieza.pieza_clickeada.connect(_al_clickear_pieza)

add_child(pieza)
piezas.append(pieza)

# Actualizar la matriz del tablero
matriz_tablero[posicion.y][posicion.x] = {
"tipo": tipo,
"color": color
}

func _al_clickear_pieza(pieza):
"""
Maneja el evento cuando se hace clic en una pieza
"""
# Deseleccionar pieza anterior si existe
if pieza_seleccionada_actual != null:
pieza_seleccionada_actual.deseleccionar()
_limpiar_casillas_validas()

# Si es una pieza del jugador actual (blancas)
if pieza.color == ColorPieza.BLANCO:
pieza_seleccionada_actual = pieza
pieza.seleccionar()

# Calcular y mostrar movimientos válidos
casillas_validas = GeneradorMovimientos.obtener_movimientos_validos(
matriz_tablero, 
pieza.posicion_tablero,
pieza.tipo,
pieza.color
)
_mostrar_casillas_validas()

emit_signal("pieza_seleccionada", pieza)

func _al_clickear_casilla(casilla):
"""
Maneja el evento cuando se hace clic en una casilla
"""
if pieza_seleccionada_actual == null:
return

# Verificar si la casilla es un movimiento válido
if casilla.coordenadas in casillas_validas:
mover_pieza(pieza_seleccionada_actual.posicion_tablero, casilla.coordenadas)

# Deseleccionar
pieza_seleccionada_actual.deseleccionar()
pieza_seleccionada_actual = null
_limpiar_casillas_validas()

func mover_pieza(desde: Vector2i, hasta: Vector2i):
"""
Mueve una pieza de una posición a otra
desde: coordenadas de origen
hasta: coordenadas de destino
"""
# Buscar la pieza en la posición origen
var pieza_a_mover = _obtener_pieza_en(desde)
if pieza_a_mover == null:
return

# Capturar pieza enemiga si existe
var pieza_capturada = _obtener_pieza_en(hasta)
if pieza_capturada != null:
piezas.erase(pieza_capturada)
pieza_capturada.queue_free()
print("💥 Pieza capturada!")

# Actualizar matriz del tablero
matriz_tablero[hasta.y][hasta.x] = matriz_tablero[desde.y][desde.x]
matriz_tablero[desde.y][desde.x] = {
"tipo": TipoPieza.NINGUNA,
"color": ColorPieza.NINGUNO
}

# Mover la pieza visualmente
pieza_a_mover.posicion_tablero = hasta
pieza_a_mover.position = Vector2(hasta.x * TAMANO_CASILLA, hasta.y * TAMANO_CASILLA)

# Verificar condiciones de fin de juego
_verificar_fin_juego()

emit_signal("movimiento_realizado", desde, hasta)

func _obtener_pieza_en(posicion: Vector2i):
"""
Retorna la pieza en una posición específica, o null si no hay
"""
for pieza in piezas:
if pieza.posicion_tablero == posicion:
return pieza
return null

func _mostrar_casillas_validas():
"""
Resalta las casillas donde la pieza seleccionada puede moverse
"""
for coordenada in casillas_validas:
casillas[coordenada.y][coordenada.x].resaltar()

func _limpiar_casillas_validas():
"""
Quita el resaltado de todas las casillas
"""
for coordenada in casillas_validas:
casillas[coordenada.y][coordenada.x].quitar_resaltado()
casillas_validas.clear()

func obtener_estado() -> Array:
"""
Retorna una copia del estado actual del tablero
Útil para que la IA analice posiciones
"""
var copia: Array = []
for fila in matriz_tablero:
var fila_copia: Array = []
for celda in fila:
fila_copia.append(celda.duplicate())
copia.append(fila_copia)
return copia

func _verificar_fin_juego():
"""
Verifica si hay jaque mate o tablas
"""
# TODO: Implementar detección de jaque mate y tablas
pass

func clone():
	"""
	Crea una copia ligera del tablero para simulación de la IA.
	Usa BoardSimulation en lugar de duplicar nodos de Godot.
	"""
	var fake_board = BoardSimulation.new()
	fake_board.white_king_pos = Vector2.ZERO
	fake_board.black_king_pos = Vector2.ZERO
	fake_board.pieces = []
	
	for pieza in piezas:
		var cloned_piece = pieza.clone(fake_board)
		fake_board.pieces.append(cloned_piece)
	
	return fake_board
