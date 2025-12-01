extends Node
class_name GeneradorMovimientos

# ============================================
# GENERADOR DE MOVIMIENTOS LEGALES
# Calcula todos los movimientos válidos para cada pieza
# ============================================

# --- Tipos de piezas ---
const PEON = 1
const TORRE = 2
const CABALLO = 3
const ALFIL = 4
const REINA = 5
const REY = 6

# --- Colores ---
const BLANCO = 1
const NEGRO = 2

static func obtener_todos_movimientos(tablero: Array, color: int) -> Array:
	"""
	Obtiene todos los movimientos legales para un color
	"""
	var movimientos: Array = []
	
	for fila in range(8):
		for columna in range(8):
			var casilla = tablero[fila][columna]
			if casilla.color == color:
				var posicion = Vector2i(columna, fila)
				var movs = obtener_movimientos_validos(
					tablero, 
					posicion, 
					casilla.tipo, 
					color
				)
				
				for destino in movs:
					movimientos.append({
						"desde": posicion,
						"hasta": destino
					})
	
	return movimientos

static func obtener_movimientos_validos(tablero: Array, posicion: Vector2i, 
										tipo_pieza: int, color: int) -> Array:
	"""
	Calcula los movimientos válidos para una pieza específica
	"""
	var movimientos: Array = []
	
	match tipo_pieza:
		PEON:
			movimientos = _movimientos_peon(tablero, posicion, color)
		TORRE:
			movimientos = _movimientos_torre(tablero, posicion, color)
		CABALLO:
			movimientos = _movimientos_caballo(tablero, posicion, color)
		ALFIL:
			movimientos = _movimientos_alfil(tablero, posicion, color)
		REINA:
			movimientos = _movimientos_reina(tablero, posicion, color)
		REY:
			movimientos = _movimientos_rey(tablero, posicion, color)
	
	return movimientos

static func _movimientos_peon(tablero: Array, pos: Vector2i, color: int) -> Array:
	"""
	Calcula movimientos del peón
	"""
	var movimientos: Array = []
	var direccion = -1 if color == BLANCO else 1
	var fila_inicial = 6 if color == BLANCO else 1
	
	# Movimiento hacia adelante (un paso)
	var adelante = Vector2i(pos.x, pos.y + direccion)
	if _esta_dentro(adelante) and _esta_vacio(tablero, adelante):
		movimientos.append(adelante)
		
		# Dos pasos desde posición inicial
		if pos.y == fila_inicial:
			var dos_adelante = Vector2i(pos.x, pos.y + direccion * 2)
			if _esta_vacio(tablero, dos_adelante):
				movimientos.append(dos_adelante)
	
	# Capturas en diagonal
	for dx in [-1, 1]:
		var diagonal = Vector2i(pos.x + dx, pos.y + direccion)
		if _esta_dentro(diagonal) and _es_enemigo(tablero, diagonal, color):
			movimientos.append(diagonal)
	
	return movimientos

static func _movimientos_torre(tablero: Array, pos: Vector2i, color: int) -> Array:
	"""
	Calcula movimientos de la torre
	"""
	var direcciones = [
		Vector2i(0, -1),  # Arriba
		Vector2i(0, 1),   # Abajo
		Vector2i(-1, 0),  # Izquierda
		Vector2i(1, 0)    # Derecha
	]
	
	return _movimientos_linea(tablero, pos, color, direcciones)

static func _movimientos_alfil(tablero: Array, pos: Vector2i, color: int) -> Array:
	"""
	Calcula movimientos del alfil
	"""
	var direcciones = [
		Vector2i(-1, -1),  # Arriba-izquierda
		Vector2i(1, -1),   # Arriba-derecha
		Vector2i(-1, 1),   # Abajo-izquierda
		Vector2i(1, 1)     # Abajo-derecha
	]
	
	return _movimientos_linea(tablero, pos, color, direcciones)

static func _movimientos_reina(tablero: Array, pos: Vector2i, color: int) -> Array:
	"""
	Calcula movimientos de la reina
	"""
	var direcciones = [
		Vector2i(0, -1), Vector2i(0, 1),    # Verticales
		Vector2i(-1, 0), Vector2i(1, 0),    # Horizontales
		Vector2i(-1, -1), Vector2i(1, -1),  # Diagonales arriba
		Vector2i(-1, 1), Vector2i(1, 1)     # Diagonales abajo
	]
	
	return _movimientos_linea(tablero, pos, color, direcciones)

static func _movimientos_caballo(tablero: Array, pos: Vector2i, color: int) -> Array:
	"""
	Calcula movimientos del caballo (L)
	"""
	var movimientos: Array = []
	var saltos = [
		Vector2i(-2, -1), Vector2i(-2, 1),
		Vector2i(2, -1), Vector2i(2, 1),
		Vector2i(-1, -2), Vector2i(1, -2),
		Vector2i(-1, 2), Vector2i(1, 2)
	]
	
	for salto in saltos:
		var destino = pos + salto
		if _esta_dentro(destino):
			if _esta_vacio(tablero, destino) or _es_enemigo(tablero, destino, color):
				movimientos.append(destino)
	
	return movimientos

static func _movimientos_rey(tablero: Array, pos: Vector2i, color: int) -> Array:
	"""
	Calcula movimientos del rey
	"""
	var movimientos: Array = []
	var direcciones = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                   Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1)
	]
	
	for dir in direcciones:
		var destino = pos + dir
		if _esta_dentro(destino):
			if _esta_vacio(tablero, destino) or _es_enemigo(tablero, destino, color):
				movimientos.append(destino)
	
	return movimientos

static func _movimientos_linea(tablero: Array, pos: Vector2i, color: int, 
							   direcciones: Array) -> Array:
	"""
	Función auxiliar para piezas que se mueven en líneas
	"""
	var movimientos: Array = []
	
	for direccion in direcciones:
		var actual = pos + direccion
		
		while _esta_dentro(actual):
			if _esta_vacio(tablero, actual):
				movimientos.append(actual)
			elif _es_enemigo(tablero, actual, color):
				movimientos.append(actual)
				break
			else:
				break
			
			actual += direccion
	
	return movimientos

# --- Funciones auxiliares ---

static func _esta_dentro(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8

static func _esta_vacio(tablero: Array, pos: Vector2i) -> bool:
	return tablero[pos.y][pos.x].tipo == 0

static func _es_enemigo(tablero: Array, pos: Vector2i, color_propio: int) -> bool:
	var casilla = tablero[pos.y][pos.x]
	return casilla.tipo != 0 and casilla.color != color_propio
