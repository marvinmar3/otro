extends RefCounted
class_name PieceSimulation

# ============================================
# SIMULACIÓN LIGERA DE PIEZA PARA LA IA
# Extiende RefCounted en lugar de Node2D para mejor rendimiento
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

var piece_type: int
var color: int
var board_position: Vector2
var board_handle
var moved: bool

func _init(type, col, pos, board, has_moved = false):
	piece_type = type
	color = col
	board_position = pos
	board_handle = board
	moved = has_moved

func move_position(to_move: Vector2):
	moved = true
	board_position = to_move
	if piece_type == REY:
		board_handle.register_king(board_position, color)
	
	if piece_type == PEON and (
		(color == NEGRO and to_move.y == 7) or 
		(color == BLANCO and to_move.y == 0)
	):
		piece_type = REINA

func clone(_board):
	return PieceSimulation.new(piece_type, color, board_position, _board, moved)

func get_moveable_positions():
	match piece_type:
		PEON: return pawn_move_pos()
		ALFIL: return bishop_threat_pos()
		TORRE: return rook_threat_pos()
		CABALLO: return knight_threat_pos()
		REINA: return queen_threat_pos()
		REY: return king_threat_pos()
		_: return []

func get_threatened_positions():
	match piece_type:
		PEON: return pawn_threat_pos()
		ALFIL: return bishop_threat_pos()
		TORRE: return rook_threat_pos()
		CABALLO: return knight_threat_pos()
		REINA: return queen_threat_pos()
		REY: return king_threat_pos()
		_: return []

const PAWN_SPOT_INCREMENTS_MOVE = [[0, 1]]
const PAWN_SPOT_INCREMENTS_MOVE_FIRST = [[0, 1], [0, 2]]
const PAWN_SPOT_INCREMENTS_TAKE = [[-1, 1], [1, 1]]

func pawn_threat_pos():
	var positions = []
	for inc in PAWN_SPOT_INCREMENTS_TAKE:
		var pos = board_handle.spot_search_threat(
			color, board_position.x, board_position.y,
			inc[0], inc[1] if color == NEGRO else -inc[1],
			true, false
		)
		if pos != null:
			positions.append(pos)
	return positions

func pawn_move_pos():
	var positions = []
	var increments = PAWN_SPOT_INCREMENTS_MOVE if moved else PAWN_SPOT_INCREMENTS_MOVE_FIRST
	for inc in increments:
		var pos = board_handle.spot_search_threat(
			color, board_position.x, board_position.y,
			inc[0], inc[1] if color == NEGRO else -inc[1],
			false, true
		)
		if pos != null:
			positions.append(pos)
		else:
			break
	for inc in PAWN_SPOT_INCREMENTS_TAKE:
		var pos = board_handle.spot_search_threat(
			color, board_position.x, board_position.y,
			inc[0], inc[1] if color == NEGRO else -inc[1],
			true, false
		)
		if pos != null:
			positions.append(pos)
	return positions

const BISHOP_BEAM_INCREMENTS = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
func bishop_threat_pos():
	var positions = []
	for inc in BISHOP_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(color, board_position.x, board_position.y, inc[0], inc[1])
	return positions

const ROOK_BEAM_INCREMENTS = [[0, 1], [0, -1], [1, 0], [-1, 0]]
func rook_threat_pos():
	var positions = []
	for inc in ROOK_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(color, board_position.x, board_position.y, inc[0], inc[1])
	return positions

const KNIGHT_SPOT_INCREMENTS = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
func knight_threat_pos():
	var positions = []
	for inc in KNIGHT_SPOT_INCREMENTS:
		var pos = board_handle.spot_search_threat(color, board_position.x, board_position.y, inc[0], inc[1])
		if pos != null:
			positions.append(pos)
	return positions

const QUEEN_BEAM_INCREMENTS = [[1, 1], [1, -1], [-1, 1], [-1, -1], [0, 1], [0, -1], [1, 0], [-1, 0]]
func queen_threat_pos():
	var positions = []
	for inc in QUEEN_BEAM_INCREMENTS:
		positions += board_handle.beam_search_threat(color, board_position.x, board_position.y, inc[0], inc[1])
	return positions

const KING_SPOT_INCREMENTS = [[1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1]]
func king_threat_pos():
	var positions = []
	for inc in KING_SPOT_INCREMENTS:
		var pos = board_handle.spot_search_threat(color, board_position.x, board_position.y, inc[0], inc[1])
		if pos != null:
			positions.append(pos)
	return positions
