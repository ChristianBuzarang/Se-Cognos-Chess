extends Node

# --- SAFETY SIMULATION & RULES ---
func get_king_pos(board, team_to_check) -> Vector2i:
	for pos in board.board_state.keys():
		var p = board.board_state[pos]
		if p.team == team_to_check and p.current_type == p.PieceType.KING: return pos
	return Vector2i(-1, -1)

func is_in_check(board, team_to_check) -> bool:
	var king_pos = get_king_pos(board, team_to_check)
	for pos in board.board_state.keys():
		var p = board.board_state[pos]
		if p.team != team_to_check:
			if is_valid_move(board, p, pos, king_pos): return true
	return false

func is_safe_move(board, piece, start_pos: Vector2i, target_pos: Vector2i) -> bool:
	if not is_valid_move(board, piece, start_pos, target_pos): return false
		
	if piece.current_type == piece.PieceType.KING and abs(start_pos.x - target_pos.x) == 2:
		if is_in_check(board, piece.team): return false 
		var dir = sign(target_pos.x - start_pos.x)
		var middle = start_pos + Vector2i(dir, 0)
		
		board.board_state.erase(start_pos)
		board.board_state[middle] = piece
		var middle_check = is_in_check(board, piece.team)
		board.board_state.erase(middle)
		board.board_state[start_pos] = piece
		if middle_check: return false 
		
	var original_target_piece = board.board_state.get(target_pos)
	board.board_state.erase(start_pos)
	board.board_state[target_pos] = piece
	
	var in_check = is_in_check(board, piece.team)
	
	board.board_state.erase(target_pos)
	board.board_state[start_pos] = piece
	if original_target_piece != null: board.board_state[target_pos] = original_target_piece
		
	return not in_check

func is_valid_move(board, piece, start_pos: Vector2i, target_pos: Vector2i) -> bool:
	if board.hazards.has(target_pos):
		if board.hazards[target_pos] in ["earthquake", "flood", "typhoon"]: return false
		if board.hazards[target_pos] == "lava" and piece.current_type == piece.PieceType.KING: return false
	
	if board.board_state.has(target_pos):
		if piece.team == board.board_state[target_pos].team: return false
	
	var type = piece.current_type
	var dx = abs(start_pos.x - target_pos.x)
	var dy = abs(start_pos.y - target_pos.y)
	
	if type == piece.PieceType.ROOK:
		if start_pos.x == target_pos.x or start_pos.y == target_pos.y: return is_path_clear(board, start_pos, target_pos) 
	
	elif type == piece.PieceType.BISHOP:
		if dx == dy: return is_path_clear(board, start_pos, target_pos) 
	
	elif type == piece.PieceType.QUEEN:
		if (dx == dy) or (start_pos.x == target_pos.x or start_pos.y == target_pos.y): return is_path_clear(board, start_pos, target_pos) 
	
	elif type in [2, 3, 4, 5]: 
		if (dx == 2 and dy == 1) or (dx == 1 and dy == 2): return true
	
	elif type == piece.PieceType.KING:
		if dx <= 1 and dy <= 1: return true
		if not board.pieces_that_moved.has(piece) and dy == 0 and dx == 2:
			var direction = sign(target_pos.x - start_pos.x)
			var rook_x = 0 if direction == -1 else 7
			var rook_pos = Vector2i(rook_x, start_pos.y)
			if board.board_state.has(rook_pos):
				var rook = board.board_state[rook_pos]
				if rook.current_type == piece.PieceType.ROOK and not board.pieces_that_moved.has(rook):
					if is_path_clear(board, start_pos, rook_pos): return true
	
	elif type == piece.PieceType.PAWN:
		var forward = -1 if piece.team == board.Team.BLUE else 1
		var starting_row = 6 if piece.team == board.Team.BLUE else 1
		
		# --- STORY OVERRIDE: THE ILLEGAL MOVE (LEVEL 2 ONLY) ---
		if board.playing_campaign_level == 2 and piece.team == board.Team.BLUE:
			if target_pos.x == start_pos.x and target_pos.y == start_pos.y - forward:
				if not board.board_state.has(target_pos): return true
		
		if target_pos.x == start_pos.x and target_pos.y == start_pos.y + forward:
			if not board.board_state.has(target_pos): return true
		if target_pos.x == start_pos.x and target_pos.y == start_pos.y + (forward * 2):
			if start_pos.y == starting_row: 
				var middle_pos = Vector2i(start_pos.x, start_pos.y + forward)
				if not board.board_state.has(target_pos) and not board.board_state.has(middle_pos): return true
		if dx == 1 and target_pos.y == start_pos.y + forward:
			if board.board_state.has(target_pos): return true
			if target_pos == board.en_passant_target: return true
	
	elif type == piece.PieceType.AIRSHIP:
		if start_pos.x == target_pos.x or start_pos.y == target_pos.y: return true 
	
	elif type == piece.PieceType.ESPER:
		if dx <= 1 and dy <= 1: return true
		if (dx == 0 and dy == 3) or (dx == 3 and dy == 0):
			if board.board_state.has(target_pos): return true 
	
	elif type == piece.PieceType.JOKER:
		if (dx == 2 and dy == 1) or (dx == 1 and dy == 2): return true
		if dx == 1 and dy == 1: return true 
	
	elif type == piece.PieceType.ASSASSIN:
		if (dx == dy) or (start_pos.x == target_pos.x or start_pos.y == target_pos.y):
			if dx <= 2 and dy <= 2:
				return is_path_clear(board, start_pos, target_pos)

	return false

func is_path_clear(board, start_pos: Vector2i, target_pos: Vector2i) -> bool:
	var step_x = sign(target_pos.x - start_pos.x)
	var step_y = sign(target_pos.y - start_pos.y)
	var current_pos = start_pos + Vector2i(step_x, step_y)
	while current_pos != target_pos:
		if board.board_state.has(current_pos): return false 
		if board.hazards.has(current_pos):
			if board.hazards[current_pos] in ["earthquake", "flood", "typhoon"]: return false
		current_pos += Vector2i(step_x, step_y)
	return true
