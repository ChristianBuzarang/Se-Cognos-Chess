extends Node

func start_puzzle(board):
	if Global.ui.play_story: board.is_pvp = false
	else: board.is_pvp = board.Global.ui.pvp_toggle.button_pressed
	
	Global.ui.game_over_menu.hide()
	Global.ui.promotion_menu.hide()
	Global.ui.draft_menu.hide()
	Global.ui.action_log_panel.show()
	Global.ui.btn_quit.show()
	Global.ui.btn_undo.hide()
	Global.ui.btn_hint.show()
	Global.ui.btn_flip_board.show()
	board.in_draft_phase = false
	
	board.starting_time = -1.0
	board.current_match_time = 0.0
	
	for pos in board.board_state.keys():
		board.board_state[pos].queue_free()
	board.board_state.clear()
	board.pieces_that_moved.clear()
	board.clear_highlights()
	
	for fog in board.fog_sprites: fog.queue_free()
	board.fog_sprites.clear()
	
	for hs in board.hazard_sprites.values(): hs.queue_free()
	board.hazard_sprites.clear()
	board.hazards.clear()
	board.hazard_timers.clear()
	
	board.current_turn = board.Team.BLUE
	board.game_over = false
	board.is_promoting = false
	board.visible = true
	
	board.is_strict_puzzle = true
	board.puzzle_sequence.clear()
	board.puzzle_step = 0
	
	Global.ui.action_log.text = ""
	Global.ui.action_log.append_text("[color=#ffffff][b]--- PUZZLE STARTED ---[/b][/color]\n")

	var lvl = board.playing_campaign_level

	# CHESS LEVEL PUZZLES
	# --- ACT 1: THE FRACTURE (Random Mode) ---
	if lvl == 1:
		Spawner.spawn_piece(board, 5, 3, board.Team.BLUE, 7)
		Spawner.spawn_piece(board, 6, 3, board.Team.BLUE, 0)
		Spawner.spawn_piece(board, 5, 0, board.Team.RED, 7) 
		Spawner.spawn_piece(board, 5, 1, board.Team.RED, 0) 
		
		board.puzzle_sequence = [
			{"start": Vector2i(6, 3), "target": Vector2i(6, 2)}, # Player
			{"start": Vector2i(5, 1), "target": Vector2i(6, 2)}, # Enemy
			{"start": Vector2i(5, 3), "target": Vector2i(6, 2)}  # Player
		]
	elif lvl == 2:
		Spawner.spawn_piece(board, 5, 3, board.Team.BLUE, 7)
		Spawner.spawn_piece(board, 6, 3, board.Team.BLUE, 0)
		Spawner.spawn_piece(board, 5, 0, board.Team.RED, 7) 
		Spawner.spawn_piece(board, 5, 1, board.Team.RED, 0) 
		
		board.puzzle_sequence = [
			{"start": Vector2i(6, 3), "target": Vector2i(6, 4)},  # Player
			{"start": Vector2i(5, 1), "target": Vector2i(5, 2)}, # Enemy
			{"start": Vector2i(5, 3), "target": Vector2i(5, 2)}  # Player
		]
	
	# --- ACT 2: BLOOD MEMORY (Magic) ---
	elif lvl == 4:
		Spawner.spawn_piece(board, 4, 4, board.Team.BLUE, 10)    
		Spawner.spawn_piece(board, 1, 3, board.Team.RED, 1)  
		Spawner.spawn_piece(board, 7, 1, board.Team.RED, 6)   
		Spawner.spawn_piece(board, 1, 1, board.Team.RED, 0)  
		Spawner.spawn_piece(board, 4, 1, board.Team.RED, 0)
		
		board.puzzle_sequence = [
			{"start": Vector2i(4, 4), "target": Vector2i(4, 1)},  # Player
			{"start": Vector2i(1, 3), "target": Vector2i(1, 2)},  # Enemy
			{"start": Vector2i(4, 1), "target": Vector2i(7, 1)},  # Player
			{"start": Vector2i(1, 2), "target": Vector2i(7, 2)},  # Enemy
			{"start": Vector2i(7, 1), "target": Vector2i(7, 2)},  # Player
			{"start": Vector2i(1, 1), "target": Vector2i(1, 3)}  # Enemy
		]
	elif lvl == 5:
		Spawner.spawn_piece(board, 2, 4, board.Team.BLUE, 11)  
		Spawner.spawn_piece(board, 4, 3, board.Team.RED, 8)  
		Spawner.spawn_piece(board, 2, 1, board.Team.RED, 0)    
		Spawner.spawn_piece(board, 5, 1, board.Team.RED, 1)    
		Spawner.spawn_piece(board, 5, 4, board.Team.RED, 0)    
		
		board.puzzle_sequence = [
			{"start": Vector2i(2, 4), "target": Vector2i(4, 3)},  # Player
			{"start": Vector2i(2, 1), "target": Vector2i(2, 3)},  # Enemy
			{"start": Vector2i(4, 3), "target": Vector2i(5, 1)},  # Player
			{"start": Vector2i(5, 4), "target": Vector2i(5, 5)},  # Enemy
			{"start": Vector2i(5, 1), "target": Vector2i(4, 3)},  # Player
			{"start": Vector2i(2, 3), "target": Vector2i(2, 4)},  # Enemy
			{"start": Vector2i(4, 3), "target": Vector2i(5, 5)},  # Player
			{"start": Vector2i(2, 4), "target": Vector2i(2, 5)},  # Enemy
			{"start": Vector2i(5, 5), "target": Vector2i(3, 4)},  # Player
			{"start": Vector2i(2, 5), "target": Vector2i(2, 6)},  # Enemy
			{"start": Vector2i(3, 4), "target": Vector2i(2, 6)}  # Player
		]
	
	# --- ACT 3: HOPE OF THE COSMOS (Intergpsychic) ---
	elif lvl == 7:
		Spawner.spawn_piece(board, 3, 7, board.Team.BLUE, 7)
		Spawner.spawn_piece(board, 3, 6, board.Team.BLUE, 8)
		Spawner.spawn_piece(board, 4, 6, board.Team.BLUE, 0)
		Spawner.spawn_piece(board, 2, 2, board.Team.BLUE, 12)
		Spawner.spawn_piece(board, 3, 0, board.Team.RED, 7)    
		Spawner.spawn_piece(board, 4, 1, board.Team.RED, 8)    
		Spawner.spawn_piece(board, 5, 0, board.Team.RED, 1)    
		Spawner.spawn_piece(board, 3, 2, board.Team.RED, 0)    
		
		board.puzzle_sequence = [
			{"start": Vector2i(3, 6), "target": Vector2i(0, 3)},  # Player
			{"start": Vector2i(4, 1), "target": Vector2i(2, 1)},  # Enemy
			{"start": Vector2i(2, 2), "target": Vector2i(2, 1)},  # Player
			{"start": Vector2i(3, 0), "target": Vector2i(4, 0)},  # Enemy
			{"start": Vector2i(0, 3), "target": Vector2i(0, 0)}  # Player
		]
	elif lvl == 8:
		Spawner.spawn_piece(board, 4, 7, board.Team.BLUE, 7) 
		Spawner.spawn_piece(board, 0, 7, board.Team.BLUE, 9) 
		Spawner.spawn_piece(board, 7, 7, board.Team.BLUE, 9) 
		Spawner.spawn_piece(board, 3, 6, board.Team.BLUE, 0) 
		Spawner.spawn_piece(board, 4, 0, board.Team.RED, 7)   
		Spawner.spawn_piece(board, 7, 0, board.Team.RED, 9)    
		Spawner.spawn_piece(board, 0, 3, board.Team.RED, 6)    
		Spawner.spawn_piece(board, 7, 1, board.Team.RED, 0)    
		
		board.puzzle_sequence = [
			{"start": Vector2i(7, 7), "target": Vector2i(7, 0)},  # Player
			{"start": Vector2i(4, 0), "target": Vector2i(5, 1)},  # Enemy
			{"start": Vector2i(0, 7), "target": Vector2i(5, 7)},  # Player
			{"start": Vector2i(5, 1), "target": Vector2i(6, 1)},  # Enemy
			{"start": Vector2i(7, 0), "target": Vector2i(5, 0)},  # Player
			{"start": Vector2i(7, 1), "target": Vector2i(7, 3)},  # Enemy
			{"start": Vector2i(5, 0), "target": Vector2i(5, 6)},  # Player
			{"start": Vector2i(6, 1), "target": Vector2i(6, 2)},  # Enemy
			{"start": Vector2i(5, 6), "target": Vector2i(6, 6)},  # Player
			{"start": Vector2i(6, 2), "target": Vector2i(7, 2)},  # Enemy
			{"start": Vector2i(5, 7), "target": Vector2i(7, 7)}  # Player
		]
	
	# --- ACT 4: CATACLYSMIC EVENT (Disaster) ---
	elif lvl == 10:
		Spawner.spawn_piece(board, 2, 7, board.Team.BLUE, 7)   
		Spawner.spawn_piece(board, 5, 4, board.Team.BLUE, 8)   
		Spawner.spawn_piece(board, 6, 6, board.Team.BLUE, 0)   
		Spawner.spawn_piece(board, 2, 0, board.Team.RED, 7)    
		Spawner.spawn_piece(board, 0, 3, board.Team.RED, 2)    
		Spawner.spawn_piece(board, 3, 3, board.Team.RED, 0)
		
	elif lvl == 11:
		Spawner.spawn_piece(board, 2, 7, board.Team.BLUE, 7)   
		Spawner.spawn_piece(board, 5, 4, board.Team.BLUE, 8)   
		Spawner.spawn_piece(board, 6, 6, board.Team.BLUE, 0)   
		Spawner.spawn_piece(board, 2, 0, board.Team.RED, 7)    
		Spawner.spawn_piece(board, 0, 3, board.Team.RED, 2)    
		Spawner.spawn_piece(board, 3, 3, board.Team.RED, 0)
		
	
	# --- ACT 5: VOID OF REALITY (Blind) ---
	elif lvl == 13:
		Spawner.spawn_piece(board, 1, 7, board.Team.BLUE, 7)
		Spawner.spawn_piece(board, 4, 3, board.Team.BLUE, 8)
		Spawner.spawn_piece(board, 2, 7, board.Team.BLUE, 1)   
		Spawner.spawn_piece(board, 3, 0, board.Team.RED, 7)    
		Spawner.spawn_piece(board, 6, 3, board.Team.RED, 6)    
		Spawner.spawn_piece(board, 7, 0, board.Team.RED, 1) 
		Spawner.spawn_piece(board, 1, 3, board.Team.RED, 2) 
		Spawner.spawn_piece(board, 3, 1, board.Team.RED, 0)    
		
		board.puzzle_sequence = [
			{"start": Vector2i(4, 3), "target": Vector2i(6, 3)},  # Player
			{"start": Vector2i(3, 0), "target": Vector2i(4, 0)},  # Enemy
			{"start": Vector2i(2, 7), "target": Vector2i(2, 0)},  # Player
			{"start": Vector2i(4, 0), "target": Vector2i(5, 1)},  # Enemy
			{"start": Vector2i(2, 0), "target": Vector2i(7, 0)},  # Player
			{"start": Vector2i(1, 3), "target": Vector2i(2, 5)},  # Enemy
			{"start": Vector2i(1, 7), "target": Vector2i(2, 6)},  # Player
			{"start": Vector2i(2, 5), "target": Vector2i(4, 4)},  # Enemy
			{"start": Vector2i(6, 3), "target": Vector2i(3, 3)},  # Player
			{"start": Vector2i(5, 1), "target": Vector2i(4, 1)},  # Enemy
			{"start": Vector2i(7, 0), "target": Vector2i(7, 1)},  # Player
			{"start": Vector2i(4, 1), "target": Vector2i(3, 0)},  # Enemy
			{"start": Vector2i(3, 3), "target": Vector2i(3, 1)}  # Player
		]
	elif lvl == 14:
		Spawner.spawn_piece(board, 4, 5, board.Team.BLUE, 7)   
		Spawner.spawn_piece(board, 3, 4, board.Team.BLUE, 8)   
		Spawner.spawn_piece(board, 0, 2, board.Team.BLUE, 1)   
		Spawner.spawn_piece(board, 4, 0, board.Team.RED, 7)    
		Spawner.spawn_piece(board, 4, 1, board.Team.RED, 0)    
		Spawner.spawn_piece(board, 0, 1, board.Team.RED, 0)    
		
		board.puzzle_sequence = [
			{"start": Vector2i(3, 4), "target": Vector2i(0, 1)},  # Player
			{"start": Vector2i(4, 0), "target": Vector2i(5, 1)},  # Enemy
			{"start": Vector2i(0, 1), "target": Vector2i(3, 4)},  # Player
			{"start": Vector2i(4, 1), "target": Vector2i(4, 2)},  # Enemy
			{"start": Vector2i(0, 2), "target": Vector2i(0, 1)},  # Player
			{"start": Vector2i(5, 1), "target": Vector2i(4, 1)},  # Enemy
			{"start": Vector2i(0, 1), "target": Vector2i(0, 0)}  # Player
		]
	
	# --- ACT 6: THE 65TH TILE (Standard) ---
	elif lvl == 16:
		Spawner.spawn_piece(board, 6, 7, board.Team.BLUE, 7) 
		Spawner.spawn_piece(board, 6, 2, board.Team.BLUE, 8) 
		Spawner.spawn_piece(board, 3, 5, board.Team.BLUE, 6)
		Spawner.spawn_piece(board, 2, 7, board.Team.BLUE, 1)
		Spawner.spawn_piece(board, 4, 3, board.Team.BLUE, 0) 
		Spawner.spawn_piece(board, 6, 0, board.Team.RED, 7)  
		Spawner.spawn_piece(board, 3, 0, board.Team.RED, 8)  
		Spawner.spawn_piece(board, 5, 0, board.Team.RED, 1)  
		Spawner.spawn_piece(board, 3, 1, board.Team.RED, 2)  
		Spawner.spawn_piece(board, 4, 2, board.Team.RED, 0)  
		Spawner.spawn_piece(board, 6, 1, board.Team.RED, 0)  
		
	elif lvl == 17:
		Spawner.spawn_piece(board, 5, 7, board.Team.BLUE, 7) 
		Spawner.spawn_piece(board, 7, 7, board.Team.BLUE, 1)
		Spawner.spawn_piece(board, 3, 5, board.Team.BLUE, 1)
		Spawner.spawn_piece(board, 4, 1, board.Team.BLUE, 2)
		Spawner.spawn_piece(board, 5, 6, board.Team.BLUE, 0) 
		Spawner.spawn_piece(board, 7, 0, board.Team.RED, 7)
		Spawner.spawn_piece(board, 5, 0, board.Team.RED, 1)
		Spawner.spawn_piece(board, 5, 1, board.Team.RED, 0)
		Spawner.spawn_piece(board, 6, 1, board.Team.RED, 0)
		Spawner.spawn_piece(board, 7, 1, board.Team.RED, 0)
	
	elif lvl == 18:
		var player_first = [1, 2, 6, 8, 7, 6, 2, 1] 
		var player_second =  [1, 4, 6, 8, 7, 6, 4, 1] 
		
		for x in range(8):
			Spawner.spawn_piece(board, x, 0, board.Team.RED, player_second[x])  
			Spawner.spawn_piece(board, x, 1, board.Team.RED, 0)
			Spawner.spawn_piece(board, x, 7, board.Team.BLUE, player_first[x]) 
			Spawner.spawn_piece(board, x, 6, board.Team.BLUE, 0)
	
	# --- POST-SPAWN FOG OF WAR ---
	if board.current_game_mode == board.GameMode.BLIND:
		for pos in board.board_state.keys():
			var piece = board.board_state[pos]
			if piece.team != board.player_team:
				piece.visible = false
	board.update_fog_of_war()
	
	if board.puzzle_sequence.is_empty(): board.is_strict_puzzle = false

func play_puzzle_enemy_turn(board):
	await board.get_tree().create_timer(0.6).timeout
	
	if board.game_over or board.puzzle_step >= board.puzzle_sequence.size(): return
	
	var expected_move = board.puzzle_sequence[board.puzzle_step]
	if board.board_state.has(expected_move["start"]):
		var piece = board.board_state[expected_move["start"]]
		board.execute_move(piece, expected_move["start"], expected_move["target"])

func trigger_puzzle_victory(board):
	board.game_over = true
	board.sfx_win.play()
	
	Global.ui.btn_quit.hide()
	Global.ui.btn_flip_board.hide()
	Global.ui.btn_undo.hide()
	Global.ui.btn_hint.hide()
	
	Global.ui.action_log.append_text("[color=#55ff55][b]PUZZLE SOLVED![/b][/color]\n")
	Global.ui.winner_text.text = "PUZZLE SOLVED!\nVICTORY!"
	Global.ui.return_btn.text = "Back to Map"
	
	await board.get_tree().create_timer(2.0).timeout
	
	board.visible = false
	Global.ui.timers_ui.hide()
	Global.ui.action_log_panel.hide()
	Global.ui.game_over_menu.show()
	
	if board.playing_campaign_level == board.highest_unlocked_level: 
		board.highest_unlocked_level += 1
		SaveManager.save_game()
