extends Node

# --- THE BOARD SPAWNERS ---
func setup_standard_board(board):
	var player_first = [1, 4, 6, 8, 7, 6, 4, 1] 
	var player_second =  [1, 2, 6, 8, 7, 6, 2, 1] 
	
	var player = player_first if board.player_goes_first else player_second
	var enemy = player_second if board.player_goes_first else player_first
	
	for x in range(8):
		spawn_piece(board, x, 0, board.Team.RED, enemy[x])  
		spawn_piece(board, x, 1, board.Team.RED, 0)
		spawn_piece(board, x, 7, board.Team.BLUE, player[x]) 
		spawn_piece(board, x, 6, board.Team.BLUE, 0)            

func setup_random_board(board):
	var valid_board = false
	while not valid_board:
		for pos in board.board_state.keys():
			board.board_state[pos].queue_free()
		board.board_state.clear()
		
		var blue_pieces = generate_random_team()
		var red_pieces = generate_random_team()
		var blue_index = 0
		var red_index = 0
		
		for y in range(2):
			for x in range(8):
				spawn_piece(board, x, y, board.Team.RED, red_pieces[red_index])
				red_index += 1
		for y in range(6, 8):
			for x in range(8):
				spawn_piece(board, x, y, board.Team.BLUE, blue_pieces[blue_index])
				blue_index += 1
		
		if not Rulebook.is_in_check(board, board.Team.BLUE) and not Rulebook.is_in_check(board, board.Team.RED):
			valid_board = true

func setup_blind_board(board):
	setup_standard_board(board) 
	board.refresh_blind_mode()

func setup_interpsychic_board(board):
	var player_first = [9, 4, 10, 8, 7, 10, 4, 9] 
	var player_second =  [9, 2, 10, 8, 7, 10, 2, 9] 
	
	var player = player_first if board.player_goes_first else player_second
	var enemy = player_second if board.player_goes_first else player_first
	
	for x in range(8):
		spawn_piece(board, x, 0, board.Team.RED, enemy[x])  
		spawn_piece(board, x, 1, board.Team.RED, 0)
		spawn_piece(board, x, 7, board.Team.BLUE, player[x]) 
		spawn_piece(board, x, 6, board.Team.BLUE, 0)          

func setup_magiccard_board(board):
	var player_first = [1, 11, 12, 8, 7, 12, 11, 1] 
	var player_second =  [1, 11, 12, 8, 7, 12, 11, 1] 
	
	var player = player_first if board.player_goes_first else player_second
	var enemy = player_second if board.player_goes_first else player_first
	
	for x in range(8):
		spawn_piece(board, x, 0, board.Team.RED, enemy[x])  
		spawn_piece(board, x, 1, board.Team.RED, 0)
		spawn_piece(board, x, 7, board.Team.BLUE, player[x]) 
		spawn_piece(board, x, 6, board.Team.BLUE, 0)    

func setup_cataclysm_board(board):
	setup_standard_board(board)
	board.hazards.clear()
	for hs in board.hazard_sprites.values(): hs.queue_free()
	board.hazard_sprites.clear()
	board.total_moves_played = 0

func setup_swarm_board(board):
	var player_first = [1, 4, 6, 8, 7, 6, 4, 1] 
	for x in range(8):
		spawn_piece(board, x, 7, board.Team.BLUE, player_first[x]) 
		spawn_piece(board, x, 6, board.Team.BLUE, 0)
	for x in range(8):
		spawn_piece(board, x, 0, board.Team.RED, 2 if randf() > 0.7 else 0)
		spawn_piece(board, x, 1, board.Team.RED, 0)
	board.swarm_turns_survived = 0

func setup_gridlock_board(board):
	spawn_piece(board, 4, 0, board.Team.RED, 7)
	spawn_piece(board, 4, 7, board.Team.BLUE, 7)
	board.blue_data_points = 20
	board.red_data_points = 20
	board.blue_draft_done = false
	board.red_draft_done = false
	board.in_draft_phase = true
	board.current_turn = board.Team.BLUE
	Global.ui.action_log.append_text("[color=#00ffff][b]DRAFT PHASE! Players take turns placing pieces.[/b][/color]\n")

func setup_tutorial_board(board):
	spawn_tutorial_piece(board, 0)

# --- PIECE INSTANTIATORS ---
func spawn_tutorial_piece(board, type_id: int):
	for pos in board.board_state.keys(): board.board_state[pos].queue_free()
	board.board_state.clear()
	board.pieces_that_moved.clear()
	board.clear_highlights()
	
	spawn_piece(board, 4, 4, board.Team.BLUE, type_id)
	spawn_piece(board, 1, 1, board.Team.RED, 0)
	spawn_piece(board, 7, 1, board.Team.RED, 0)
	spawn_piece(board, 1, 7, board.Team.RED, 0)
	spawn_piece(board, 4, 1, board.Team.RED, 0) 
	spawn_piece(board, 7, 7, board.Team.RED, 0)
	
	board.current_turn = board.Team.BLUE 
	Global.ui.action_log.append_text("[color=#66aaff]Spawned " + Helpers.get_piece_name(type_id) + " for testing.[/color]\n")

func spawn_piece(board, x: int, y: int, team: int, type_id: int):
	var new_piece = board.piece_scene.instantiate()
	var grid_pos = Vector2i(x, y)
	new_piece.position = Helpers.get_visual_pos(board, grid_pos)
	new_piece.current_type = type_id
	new_piece.team = team 
	
	#if team == board.Team.BLUE: new_piece.current_color = board.player_color_index
	#else: new_piece.current_color = board.enemy_color_index
	
	if team == board.player_team: 
		new_piece.current_color = board.player_color_index
	else:
		new_piece.current_color = board.enemy_color_index
	
	board.add_child(new_piece)
	board.board_state[grid_pos] = new_piece

func spawn_manual_hazard(board, pos: Vector2i, type: String):
	board.hazards[pos] = type
	var danger_tile = board.disaster_scene.instantiate()
	
	danger_tile.position = Helpers.get_visual_pos(board, pos)
	danger_tile.y_sort_enabled = false 
	danger_tile.z_index = 2
	danger_tile.scale = Vector2(1.0, 1.0) 
	
	board.add_child(danger_tile)
	board.hazard_sprites[pos] = danger_tile
	
	var anim = danger_tile.get_node_or_null("AnimationPlayer")
	if anim: anim.play(type)

func generate_random_team() -> Array:
	var pieces = []
	var possible_types = [0, 1, 2, 6, 8] 
	for i in range(15): pieces.append(possible_types.pick_random())
	pieces.append(7) # King is 7!
	pieces.shuffle() 
	return pieces

func spawn_swarm_enemy(board):
	var empty_spots = []
	for x in range(8):
		for y in range(2):
			var pos = Vector2i(x, y)
			if not board.board_state.has(pos) and not board.hazards.has(pos):
				empty_spots.append(pos)
				
	if empty_spots.size() > 0:
		var spawn_pos = empty_spots.pick_random()
		var type = 2 if randf() > 0.8 else 0 
		spawn_piece(board, spawn_pos.x, spawn_pos.y, board.Team.RED, type)
		Global.ui.action_log.append_text("[color=#ff6666][b]A new enemy joined the Swarm at " + Helpers.get_chess_notation(spawn_pos) + "![/b][/color]\n")

func spawn_map_disaster(anim_name: String, screen_pos: Vector2):
	if Global.board.disaster_scene == null: return 
	
	var danger_tile = Global.board.disaster_scene.instantiate()
	danger_tile.position = screen_pos
	danger_tile.scale = Vector2(2, 2) 
	
	Global.ui.map_menu.add_child(danger_tile)
	Global.ui.map_menu.move_child(danger_tile, Global.ui.map_bg.get_index() + 1)
	Global.ui.map_disaster_sprites.append(danger_tile)
	
	var anim = danger_tile.get_node_or_null("AnimationPlayer")
	if anim: anim.play(anim_name)
