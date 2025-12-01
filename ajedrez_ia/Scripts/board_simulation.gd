extends RefCounted
class_name BoardSimulation

# ============================================
# SIMULACIÓN LIGERA DEL TABLERO PARA LA IA
# Extiende RefCounted en lugar de Node2D para mejor rendimiento
# ============================================

var pieces = []
var white_king_pos: Vector2
var black_king_pos: Vector2

func get_piece(pos: Vector2):
	for piece in pieces:
		if piece.board_position == pos:
			return piece
	return null

func delete_piece(piece):
	for i in range(len(pieces)):
		if pieces[i] == piece:
			pieces.remove_at(i)
			return

func register_king(pos, col):
	match col:
		1:  # BLANCO
			white_king_pos = pos
		2:  # NEGRO
			black_king_pos = pos

func beam_search_threat(own_color, cur_x, cur_y, inc_x, inc_y):
	var threat_pos = []
	cur_x += inc_x
	cur_y += inc_y
	
	while cur_x >= 0 and cur_x < 8 and cur_y >= 0 and cur_y < 8:
		var cur_pos = Vector2(cur_x, cur_y)
		var cur_piece = get_piece(cur_pos)
		if cur_piece != null:
			if cur_piece.color != own_color:
				threat_pos.append(cur_pos)
			break
		threat_pos.append(cur_pos)
		cur_x += inc_x
		cur_y += inc_y
	
	return threat_pos

func spot_search_threat(own_color, cur_x, cur_y, inc_x, inc_y, threat_only = false, free_only = false):
	cur_x += inc_x
	cur_y += inc_y
	
	if cur_x >= 8 or cur_x < 0 or cur_y >= 8 or cur_y < 0:
		return null
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	if cur_piece != null:
		if free_only:
			return null
		return cur_pos if cur_piece.color != own_color else null
	return cur_pos if not threat_only else null

func clone():
	var new_board = BoardSimulation.new()
	new_board.white_king_pos = white_king_pos
	new_board.black_king_pos = black_king_pos
	new_board.pieces = []
	
	for piece in pieces:
		var cloned_piece = piece.clone(new_board)
		new_board.pieces.append(cloned_piece)
	
	return new_board
