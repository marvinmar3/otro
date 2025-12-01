extends Node2D

# ============================================
# SCRIPT PRINCIPAL DEL JUEGO DE AJEDREZ
# ============================================

enum Jugador { BLANCAS, NEGRAS }

var turno_actual: int = Jugador.BLANCAS
var juego_terminado: bool = false
var modo_vs_ia: bool = true

@onready var tablero = $Tablero
@onready var ia_ajedrez = $IAajedrez
@onready var panel_razonamiento = $CanvasLayer/PanelRazonamiento
@onready var etiqueta_turno = $CanvasLayer/EtiquetaTurno

func _ready():
	# Conectar señales del tablero
	tablero.movimiento_realizado.connect(_al_realizar_movimiento)
	
	# Inicializar el tablero
	tablero.inicializar_tablero()
	_actualizar_etiqueta_turno()
	
	print("🎮 Juego de Ajedrez iniciado")

func _al_realizar_movimiento(desde: Vector2i, hasta: Vector2i):
	print("♟️ Movimiento: ", desde, " -> ", hasta)
	_cambiar_turno()
	
	if modo_vs_ia and turno_actual == Jugador.NEGRAS and not juego_terminado:
		_ejecutar_turno_ia()

func _cambiar_turno():
	if turno_actual == Jugador.BLANCAS:
		turno_actual = Jugador.NEGRAS
	else:
		turno_actual = Jugador.BLANCAS
	_actualizar_etiqueta_turno()

func _actualizar_etiqueta_turno():
	if etiqueta_turno:
		if turno_actual == Jugador.BLANCAS:
			etiqueta_turno.text = "⚪ Turno: Blancas"
		else:
			etiqueta_turno.text = "⚫ Turno: Negras (IA pensando...)"

func _ejecutar_turno_ia():
	print("\n🤖 IA analizando posición...")
	
	var estado_tablero = tablero.obtener_estado()
	
	var resultado_ia = ia_ajedrez.calcular_mejor_jugada(
		estado_tablero, 
		2  # NEGRO = 2
	)
	
	if panel_razonamiento:
		panel_razonamiento.mostrar_razonamiento(resultado_ia.arbol_decision)
	
	if resultado_ia.mejor_movimiento != null:
		var mov = resultado_ia.mejor_movimiento
		# Pequeña pausa para que se vea el pensamiento
		await get_tree().create_timer(0.5).timeout
		tablero.mover_pieza(mov.desde, mov.hasta)
		print("🤖 IA juega: ", mov.desde, " -> ", mov.hasta)

func reiniciar_juego():
	juego_terminado = false
	turno_actual = Jugador.BLANCAS
	tablero.inicializar_tablero()
	if panel_razonamiento:
		panel_razonamiento.limpiar()
	_actualizar_etiqueta_turno()
