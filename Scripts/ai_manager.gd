extends Node

# --- AI EVALUATION MATH ---
func get_piece_value(type_id: int) -> int:
	if type_id == 0: return 10
	if type_id == 1: return 50
	if type_id in [2, 3, 4, 5]: return 30
	if type_id == 6: return 30
	if type_id == 7: return 9000
	if type_id == 8: return 90
	if type_id == 9: return 60 # Airships
	if type_id == 10: return 40 # Espers
	if type_id == 11: return 35 # Jokers
	if type_id == 12: return 45 # Assassins
	return 0

func evaluate_board(board) -> int:
	var score = 0
	var ai_team = board.Team.RED if board.player_team == board.Team.BLUE else board.Team.BLUE
	
	var ai_material = 0
	var player_material = 0
	var ai_king_pos = Vector2i(-1, -1)
	var player_king_pos = Vector2i(-1, -1)
	
	for pos in board.board_state.keys():
		var p = board.board_state[pos]
		var val = get_piece_value(p.current_type)
		
		# SWARM MODE OVERRIDE
		if board.current_game_mode == board.GameMode.SWARM:
			if p.team == ai_team:
				score += val
				score += pos.y * 5
			else:
				if p.current_type == p.PieceType.KING: score -= 9000
				else: score -= val
			continue 
		
		# NORMAL MATH
		if pos.x >= 3 and pos.x <= 4 and pos.y >= 3 and pos.y <= 4:
			val += 2
		
		if p.team == ai_team:
			ai_material += val
			if p.current_type == p.PieceType.KING: ai_king_pos = pos
			score += val
		else:
			player_material += val
			if p.current_type == p.PieceType.KING: player_king_pos = pos
			score -= val
	
	# ENDGAME TACTICS
	if ai_material > player_material + 40 and player_material < 150:
		if player_king_pos.x != -1 and ai_king_pos.x != -1:
			var edge_dist_x = max(3 - player_king_pos.x, player_king_pos.x - 4)
			var edge_dist_y = max(3 - player_king_pos.y, player_king_pos.y - 4)
			score += (edge_dist_x + edge_dist_y) * 10
			var king_dist = abs(ai_king_pos.x - player_king_pos.x) + abs(ai_king_pos.y - player_king_pos.y)
			score -= king_dist * 5 
			
	return score

# --- MINIMAX SIMULATION ---
func get_all_legal_moves(board, team) -> Array:
	var moves = []
	for pos in board.board_state.keys():
		var piece = board.board_state[pos]
		if piece.team == team:
			for x in range(8):
				for y in range(8):
					var target = Vector2i(x, y)
					if Rulebook.is_safe_move(board, piece, pos, target):
						moves.append({"piece": piece, "start": pos, "target": target})
	return moves

func sim_move(board, piece, start_pos, target_pos) -> Dictionary:
	var temp = { 
		"captured": board.board_state.get(target_pos), 
		"promoted": false, 
		"suicide": false,
		"old_ep": board.en_passant_target,
		"ep_captured": null 
	}
	
	if piece.current_type == piece.PieceType.PAWN and target_pos == board.en_passant_target:
		var ep_pos = Vector2i(target_pos.x, start_pos.y)
		temp.ep_captured = board.board_state.get(ep_pos)
		board.board_state.erase(ep_pos)
	
	board.board_state.erase(start_pos)
	
	if board.hazards.has(target_pos) and board.hazards[target_pos] == "lava": temp.suicide = true
	else: board.board_state[target_pos] = piece
	
	if not temp.suicide and piece.current_type == piece.PieceType.PAWN:
		if target_pos.y == 0 or target_pos.y == 7:
			piece.current_type = piece.PieceType.QUEEN
			temp.promoted = true
	
	if piece.current_type == piece.PieceType.PAWN and abs(start_pos.y - target_pos.y) == 2:
		board.en_passant_target = Vector2i(start_pos.x, (start_pos.y + target_pos.y) / 2)
	else:
		board.en_passant_target = Vector2i(-1, -1)
	
	return temp

func undo_sim(board, piece, start_pos, target_pos, temp):
	if not temp.suicide:
		board.board_state.erase(target_pos)
	
	board.board_state[start_pos] = piece
	if temp.promoted: piece.current_type = piece.PieceType.PAWN
	if temp.captured != null: board.board_state[target_pos] = temp.captured
	
	board.en_passant_target = temp.old_ep
	if temp.ep_captured != null:
		var ep_pos = Vector2i(target_pos.x, start_pos.y)
		board.board_state[ep_pos] = temp.ep_captured

func minimax(board, depth: int, alpha: int, beta: int, maximizing: bool) -> int:
	var ai_team = board.Team.RED if board.player_team == board.Team.BLUE else board.Team.BLUE
	var team_to_move = ai_team if maximizing else board.player_team
	var moves = get_all_legal_moves(board, team_to_move)
	
	if moves.size() == 0:
		if Rulebook.is_in_check(board, team_to_move): return -99999 + depth if maximizing else 99999 - depth
		return 0 # Stalemate
	
	if depth == 0: return evaluate_board(board)
	
	if maximizing:
		var max_eval = -999999
		for move in moves:
			var temp = sim_move(board, move.piece, move.start, move.target)
			var eval = minimax(board, depth - 1, alpha, beta, false)
			undo_sim(board, move.piece, move.start, move.target, temp)
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if beta <= alpha: break
		return max_eval
	else:
		var min_eval = 999999
		for move in moves:
			var temp = sim_move(board, move.piece, move.start, move.target)
			var eval = minimax(board, depth - 1, alpha, beta, true)
			undo_sim(board, move.piece, move.start, move.target, temp)
			min_eval = min(min_eval, eval)
			beta = min(beta, eval)
			if beta <= alpha: break
		return min_eval

# --- TURN EXECUTIONS ---
func play_ai_turn(board):
	Global.ui.action_log.append_text("[color=#aaaaaa]AI is calculating...[/color]\n")
	
	var moves = get_all_legal_moves(board, board.current_turn)
	if moves.size() == 0: return
	
	var best_moves = []
	var max_eval = -999999
	
	for move in moves:
		if board.game_over: return 
		
		var temp = sim_move(board, move.piece, move.start, move.target)
		var eval = minimax(board, 1, -999999, 999999, false) 
		undo_sim(board, move.piece, move.start, move.target, temp)
		
		if eval > max_eval:
			max_eval = eval
			best_moves = [move]
		elif eval == max_eval:
			best_moves.append(move)
		
		await board.get_tree().process_frame 
	
	if board.game_over or board.current_turn != board.Team.RED: return
	
	var chosen = best_moves[randi() % best_moves.size()]
	board.execute_move(chosen.piece, chosen.start, chosen.target)

func play_ai_draft_turn(board):
	await board.get_tree().create_timer(0.5).timeout
	
	var p2_name = Helpers.get_team_color_name(board, board.Team.RED)
	var p2_hex = Helpers.get_team_hex(board, board.Team.RED)
	
	if board.red_data_points < 1: 
		board.red_draft_done = true
		Global.ui.action_log.append_text("[color=" + p2_hex + "]" + p2_name + " has run out of points and finished drafting.[/color]\n")
		board.current_turn = board.Team.BLUE
		board.check_draft_state()
		return
	
	var available_spots = []
	for x in range(8):
		for y in range(2):
			if not board.board_state.has(Vector2i(x, y)):
				available_spots.append(Vector2i(x, y))
	
	available_spots.sort_custom(func(a, b): 
		var dist_a = abs(a.x - 4) + abs(a.y - 0)
		var dist_b = abs(b.x - 4) + abs(b.y - 0)
		return dist_a < dist_b
	)
	
	var pos = available_spots[0]
	var options = []
	if board.red_data_points >= 9: options.append(9) # Queen
	if board.red_data_points >= 5: options.append(1) # Rook
	if board.red_data_points >= 3: options.append(3); options.append(2) # Bishop/Knight
	if board.red_data_points >= 1: options.append(0) # Pawn
	
	var chosen_piece = options.pick_random()
	board.red_data_points -= board.get_piece_cost(chosen_piece)
	
	Spawner.spawn_piece(board, pos.x, pos.y, board.Team.RED, chosen_piece)
	Global.ui.action_log.append_text("[color=" + p2_hex + "]" + p2_name + " drafted a piece.[/color]\n")
	
	board.current_turn = board.Team.BLUE
	board.check_draft_state()
