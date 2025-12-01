extends Node

# ============================================
# INTELIGENCIA ARTIFICIAL DEL AJEDREZ
# Implementa Minimax con Poda Alfa-Beta
# ============================================

# --- Valores de las piezas ---
const VALORES_PIEZAS = {
	0: 0,      # NINGUNA
	1: 100,    # PEON
	2: 500,    # TORRE
	3: 320,    # CABALLO
	4: 330,    # ALFIL
	5: 900,    # REINA
	6: 20000   # REY
}

# --- Configuración ---
var profundidad_busqueda: int = 3
var nodos_analizados: int = 0
var arbol_decision: Dictionary = {}

func calcular_mejor_jugada(estado_tablero: Array, color_ia: int) -> Dictionary:
	"""
	Calcula la mejor jugada usando Minimax con poda Alfa-Beta
	"""
	nodos_analizados = 0
	arbol_decision = {"tipo": "raiz", "hijos": [], "evaluacion": 0}
	
	var movimientos_posibles = GeneradorMovimientos.obtener_todos_movimientos(
		estado_tablero, 
		color_ia
	)
	
	if movimientos_posibles.is_empty():
		return {
			"mejor_movimiento": null,
			"evaluacion": 0,
			"arbol_decision": arbol_decision,
			"nodos_analizados": nodos_analizados
		}
	
	var mejor_movimiento = null
	var mejor_evaluacion = -INF
	var alfa = -INF
	var beta = INF
	
	for movimiento in movimientos_posibles:
		var tablero_simulado = _simular_movimiento(
			estado_tablero, 
			movimiento.desde, 
			movimiento.hasta
		)
		
		var evaluacion = _minimax(
			tablero_simulado,
			profundidad_busqueda - 1,
			alfa,
			beta,
			false,
			color_ia
		)
		
		if evaluacion > mejor_evaluacion:
			mejor_evaluacion = evaluacion
			mejor_movimiento = movimiento
		
		alfa = max(alfa, evaluacion)
	
	arbol_decision.evaluacion = mejor_evaluacion
	
	return {
		"mejor_movimiento": mejor_movimiento,
		"evaluacion": mejor_evaluacion,
		"arbol_decision": arbol_decision,
		"nodos_analizados": nodos_analizados
	}

func _minimax(tablero: Array, profundidad: int, alfa: float, beta: float, 
			  es_maximizador: bool, color_ia: int) -> float:
	"""
	Algoritmo Minimax con poda Alfa-Beta
	"""
	nodos_analizados += 1
	
	if profundidad == 0:
		return _evaluar_tablero(tablero, color_ia)
	
	var color_turno = color_ia if es_maximizador else _color_oponente(color_ia)
	var movimientos = GeneradorMovimientos.obtener_todos_movimientos(tablero, color_turno)
	
	if movimientos.is_empty():
		return 0
	
	if es_maximizador:
		var valor_maximo = -INF
		for movimiento in movimientos:
			var tablero_simulado = _simular_movimiento(tablero, movimiento.desde, movimiento.hasta)
			var evaluacion = _minimax(tablero_simulado, profundidad - 1, alfa, beta, false, color_ia)
			valor_maximo = max(valor_maximo, evaluacion)
			alfa = max(alfa, evaluacion)
			if beta <= alfa:
				break
		return valor_maximo
	else:
		var valor_minimo = INF
		for movimiento in movimientos:
			var tablero_simulado = _simular_movimiento(tablero, movimiento.desde, movimiento.hasta)
			var evaluacion = _minimax(tablero_simulado, profundidad - 1, alfa, beta, true, color_ia)
			valor_minimo = min(valor_minimo, evaluacion)
			beta = min(beta, evaluacion)
			if beta <= alfa:
				break
		return valor_minimo

func _evaluar_tablero(tablero: Array, color_ia: int) -> float:
	"""
	Evalúa la posición actual del tablero
	"""
	var puntuacion: float = 0.0
	
	for fila in range(8):
		for columna in range(8):
			var casilla = tablero[fila][columna]
			if casilla.tipo == 0:
				continue
			
			var valor_pieza = VALORES_PIEZAS[casilla.tipo]
			
			if casilla.color == color_ia:
				puntuacion += valor_pieza
			else:
				puntuacion -= valor_pieza
	
	return puntuacion

func _simular_movimiento(tablero: Array, desde: Vector2i, hasta: Vector2i) -> Array:
	"""
	Crea una copia del tablero con el movimiento aplicado
	"""
	var tablero_copia: Array = []
	for fila in tablero:
		var fila_copia: Array = []
		for celda in fila:
			fila_copia.append(celda.duplicate())
		tablero_copia.append(fila_copia)
	
	tablero_copia[hasta.y][hasta.x] = tablero_copia[desde.y][desde.x]
	tablero_copia[desde.y][desde.x] = {"tipo": 0, "color": 0}
	
	return tablero_copia

func _color_oponente(color: int) -> int:
	return 1 if color == 2 else 2
