extends TileMapLayer

@export var piece_scene: PackedScene
@export var board_textures: Array[Texture2D]
@export var board_flipped_textures: Array[Texture2D] 
@export var disaster_scene: PackedScene

enum GameMode { STANDARD, RANDOM, BLIND, INTER_PSYCHIC, MAGIC_CARD, CATACLYSM, SWARM, GRIDLOCK, TUTORIAL }
var current_game_mode: GameMode = GameMode.STANDARD

enum Team { BLUE, RED }
var current_turn: Team = Team.BLUE
var player_team: Team = Team.BLUE 

var board_state = {}
var selected_piece = null
var selected_grid_pos = Vector2i(-1, -1)
var active_highlights = []
var fog_sprites = []
var pieces_that_moved = [] 
var level_buttons = []
var en_passant_target = Vector2i(-1, -1) 

var hazards = {}
var hazard_sprites = {}
var hazard_timers = {}
var total_moves_played = 0 

var swarm_turns_survived = 0
var swarm_target_turns = 20

var playing_campaign_level = 0
var highest_unlocked_level = 1
var total_campaign_levels = 18

var is_pvp: bool = false
var blue_time: float = 300.0
var red_time: float = 300.0
var starting_time: float = 300.0

var game_over: bool = true
var is_promoting: bool = false

var in_draft_phase: bool = false
var blue_data_points: int = 20
var red_data_points: int = 20
var blue_draft_done: bool = false
var red_draft_done: bool = false
var draft_pos: Vector2i

var current_match_time: float = 0.0

var player_color_index = 0
var enemy_color_index = 1
var player_goes_first = false
var camera_angle: int = 0 
var history_stack = [] 

# --- PUZZLE VARIABLES ---
var is_strict_puzzle: bool = false
var puzzle_sequence: Array = []
var puzzle_step: int = 0

# --- AUDIO & CAMERAS
@onready var sfx_move = $SfxMove
@onready var sfx_click = $SfxClick
@onready var sfx_capture = $SfxCapture
@onready var sfx_check = $SfxCheck
@onready var sfx_win = $SfxWin
@onready var camera = $Camera2D
@onready var board_image = $BoardImage
@onready var coords_control = $Control


func _ready():
	# REGISTER TO GLOBALS
	Global.board = self
	VFXManager.camera = $Camera2D
	
	Global.ui.attach_button_sounds($UI, sfx_click)
	SaveManager.load_game()

func _process(delta):
	if delta > 0.2: return 
	if game_over or is_promoting or not self.visible or in_draft_phase: return
	if Global.ui.play_story and CampaignData.data[playing_campaign_level]["type"] == "puzzle":  return
	
	current_match_time += delta
	
	if starting_time > 0:
		if current_turn == Team.BLUE:
			blue_time -= delta
			if blue_time <= 0: time_out(Team.RED)
		else:
			red_time -= delta
			if red_time <= 0: time_out(Team.BLUE)
		
		Global.ui.blue_time_label.text = Global.ui.format_time(blue_time)
		Global.ui.red_time_label.text = Global.ui.format_time(red_time)
		
		Global.ui.blue_time_label.add_theme_color_override("font_color", Color(Helpers.get_team_hex(self, Team.BLUE)))
		Global.ui.red_time_label.add_theme_color_override("font_color", Color(Helpers.get_team_hex(self, Team.RED)))

func cleanup_board():
	en_passant_target = Vector2i(-1, -1)
	for pos in board_state.keys(): board_state[pos].queue_free()
	board_state.clear()
	for fog in fog_sprites: fog.queue_free()
	fog_sprites.clear()
	for hs in hazard_sprites.values(): hs.queue_free()
	hazard_sprites.clear()
	hazards.clear()
	pieces_that_moved.clear()
	clear_highlights()
	total_moves_played = 0 

func start_game(mode: GameMode):
	if NetworkManager.is_lan_match and multiplayer.get_peers().size() == 0:
		if Global.ui.pvp_toggle: Global.ui.pvp_toggle.text = "ERROR: Wait for Player 2 to join!"
		return
	
	current_game_mode = mode
	current_match_time = 0.0
	
	en_passant_target = Vector2i(-1, -1)
	
	# --- MULTIPLAYER PERSPECTIVE ---
	if NetworkManager.is_lan_match:
		if NetworkManager.my_network_team == Team.RED:
			camera_angle = 2
			Global.ui.board_flipped = true
		else:
			camera_angle = 0
			Global.ui.board_flipped = false
	
	update_coordinates_visibility()
	
	if Global.ui.play_story: is_pvp = false
	else: is_pvp = Global.ui.pvp_toggle.button_pressed
	
	Global.ui.start_menu.hide()
	Global.ui.game_modes_menu.hide()
	Global.ui.game_over_menu.hide()
	Global.ui.promotion_menu.hide()
	Global.ui.draft_menu.hide()
	Global.ui.btn_quit.show()
	Global.ui.btn_flip_board.show()
	in_draft_phase = false 
	
	cleanup_board()
	hazard_timers.clear()
	
	current_turn = Team.BLUE if player_goes_first else Team.RED
	game_over = false
	is_promoting = false
	self.visible = true
	
	is_strict_puzzle = false
	puzzle_sequence.clear()
	puzzle_step = 0
	
	Global.ui.action_log.text = "" 
	var mode_name = GameMode.keys()[current_game_mode].replace("_", " ")
	Global.ui.action_log.append_text("[color=#ffffff][b]--- " + mode_name + " CHESS STARTED ---[/b][/color]\n")
	
	# --- THE MODE ROUTER ---
	if current_game_mode == GameMode.RANDOM: Spawner.setup_random_board(self)
	elif current_game_mode == GameMode.BLIND: Spawner.setup_blind_board(self) 
	elif current_game_mode == GameMode.INTER_PSYCHIC: Spawner.setup_interpsychic_board(self) 
	elif current_game_mode == GameMode.MAGIC_CARD: Spawner.setup_magiccard_board(self) 
	elif current_game_mode == GameMode.CATACLYSM: Spawner.setup_cataclysm_board(self)
	elif current_game_mode == GameMode.SWARM: Spawner.setup_swarm_board(self)
	elif current_game_mode == GameMode.GRIDLOCK: Spawner.setup_gridlock_board(self) 
	elif current_game_mode == GameMode.TUTORIAL: Spawner.setup_tutorial_board(self)
	else: Spawner.setup_standard_board(self)
	
	blue_time = starting_time
	red_time = starting_time
	
	if current_game_mode == GameMode.TUTORIAL:
		Global.ui.tutorial_menu.show()
		Global.ui.action_log_panel.hide()
		Global.ui.timers_ui.hide()
	else:
		Global.ui.tutorial_menu.hide()
		Global.ui.action_log_panel.show()
		if starting_time > 0: Global.ui.timers_ui.show()
		else: Global.ui.timers_ui.hide() 
		
		check_for_game_over()
		
		if not game_over:
			if not is_pvp and current_turn != player_team:
				AIManager.play_ai_turn(self)
	
	history_stack.clear() 
	Global.ui.btn_undo.show()
	Global.ui.btn_hint.hide()

# --- INPUT & INTERACTION s---
func _unhandled_input(event):
	if game_over or is_promoting: return 
	if NetworkManager.is_lan_match and current_turn != NetworkManager.my_network_team: return
	if not is_pvp and current_turn != player_team and not in_draft_phase: return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_pixel = get_local_mouse_position()
		var grid_pos = Helpers.get_logical_pos(self, clicked_pixel) 
		
		if grid_pos.x >= 0 and grid_pos.x <= 7 and grid_pos.y >= 0 and grid_pos.y <= 7:
			if in_draft_phase:
				if current_turn == player_team and not blue_draft_done:
					handle_draft_click(grid_pos)
			else:
				if not is_pvp and current_turn != player_team: return
				handle_click(grid_pos)

func handle_click(grid_pos: Vector2i):
	var clicked_piece = board_state.get(grid_pos) 
	
	if clicked_piece != null and (selected_piece == null or clicked_piece.team == selected_piece.team):
		if clicked_piece.team != current_turn: return
		if clicked_piece == selected_piece: deselect_piece() 
		else: select_piece(clicked_piece, grid_pos) 
		return
	
	if selected_piece != null:
		if Rulebook.is_safe_move(self, selected_piece, selected_grid_pos, grid_pos):
			if is_strict_puzzle:
				var expected_move = puzzle_sequence[puzzle_step]
				if selected_grid_pos == expected_move["start"] and grid_pos == expected_move["target"]:
					execute_move(selected_piece, selected_grid_pos, grid_pos)
				else:
					Global.ui.action_log.append_text("[color=#ffaa00]Incorrect move. Try again![/color]\n")
					deselect_piece()
			else:
				if NetworkManager.is_lan_match: NetworkManager.send_move(selected_grid_pos, grid_pos)
				else: execute_move(selected_piece, selected_grid_pos, grid_pos)
		else:
			deselect_piece()

# --- THE GRIDLOCK MECHANICS ---
func handle_draft_click(grid_pos: Vector2i):
	if grid_pos.y < 6:
		Global.ui.action_log.append_text("[color=#ffaa00]You can only place pieces on your side of the board (Ranks 1 and 2)![/color]\n")
		return
	if board_state.has(grid_pos):
		Global.ui.action_log.append_text("[color=#ffaa00]A piece is already there![/color]\n")
		return
	
	draft_pos = grid_pos
	Global.ui.draft_stats.text = "Data Points: " + str(blue_data_points)
	Global.ui.draft_menu.move_to_front()
	Global.ui.draft_menu.show()
	var chosen_type = await Global.ui.draft_selected
	Global.ui.draft_menu.hide()
	
	if chosen_type == -2: return 
	
	var p1_name = Helpers.get_team_color_name(self, Team.BLUE)
	var p1_hex = Helpers.get_team_hex(self, Team.BLUE)
	if chosen_type == -1:
		blue_draft_done = true
		Global.ui.action_log.append_text("[color=" + p1_hex + "]" + p1_name + " has finished drafting.[/color]\n")
		check_draft_state()
		return
	
	var cost = get_piece_cost(chosen_type)
	if blue_data_points >= cost:
		blue_data_points -= cost
		Spawner.spawn_piece(self, draft_pos.x, draft_pos.y, Team.BLUE, chosen_type)
		Global.ui.action_log.append_text("[color=" + p1_hex + "]" + p1_name + " drafted " + Helpers.get_piece_name(chosen_type) + ".[/color]\n")
		current_turn = Team.RED
		check_draft_state()
	else:
		Global.ui.action_log.append_text("[color=#ff0000]Not enough Data Points![/color]\n")

func check_draft_state():
	if blue_draft_done and red_draft_done:
		in_draft_phase = false
		current_turn = Team.BLUE
		Global.ui.action_log.append_text("[color=#55ff55][b]DRAFTING COMPLETE. BATTLE COMMENCES![/b][/color]\n")
		return
	
	if current_turn == Team.RED:
		if red_draft_done:
			current_turn = Team.BLUE
			check_draft_state() 
		else:
			AIManager.play_ai_draft_turn(self)
	elif current_turn == Team.BLUE:
		if blue_draft_done:
			current_turn = Team.RED
			check_draft_state() 

func get_piece_cost(type: int) -> int:
	if type == 0: return 1
	if type == 1: return 5
	if type in [2, 3, 4, 5]: return 3
	if type == 6: return 3
	if type == 8: return 9
	return 0

# --- EXECUTING MOVES &  LOGIC ---
func execute_move(piece, start_pos: Vector2i, target_pos: Vector2i):
	save_state_snapshot()
	total_moves_played += 1
	
	if not pieces_that_moved.has(piece): pieces_that_moved.append(piece)
	
	# --- ACTION LOG SETUP ---
	var team_name = Helpers.get_team_color_name(self, piece.team)
	var piece_name = Helpers.get_piece_name(piece.current_type)
	var start_sq = Helpers.get_chess_notation(start_pos)
	var target_sq = Helpers.get_chess_notation(target_pos)
	var raw_log_msg = team_name + " " + piece_name + " moved: " + start_sq + " -> " + target_sq
	if current_game_mode == GameMode.BLIND: raw_log_msg = team_name + " made a move."
	
	# --- CASTLING ---
	if piece.current_type == piece.PieceType.KING and abs(start_pos.x - target_pos.x) == 2:
		var direction = sign(target_pos.x - start_pos.x)
		var rook_x = 0 if direction == -1 else 7
		var rook_pos = Vector2i(rook_x, start_pos.y)
		var rook_target = target_pos - Vector2i(direction, 0) 
		var rook = board_state[rook_pos]
		rook.position = Helpers.get_visual_pos(self, rook_target)
		board_state.erase(rook_pos)
		board_state[rook_target] = rook
		if not pieces_that_moved.has(rook): pieces_that_moved.append(rook)
		raw_log_msg = team_name + " King Castled!"
		if current_game_mode == GameMode.BLIND: raw_log_msg = team_name + " performed a special move."	
	
	# --- EN PASSANT CAPTURE EXECUTION ---
	if piece.current_type == piece.PieceType.PAWN and target_pos == en_passant_target:
		var ep_pawn_pos = Vector2i(target_pos.x, start_pos.y)
		if board_state.has(ep_pawn_pos):
			var doomed_team = board_state[ep_pawn_pos].team
			board_state[ep_pawn_pos].queue_free()
			board_state.erase(ep_pawn_pos)
			
			var hex_color = Helpers.get_team_hex(self, doomed_team)
			VFXManager.create_explosion(ep_pawn_pos, Color(hex_color))
			VFXManager.shake_camera(10.0)
			sfx_capture.play()
			raw_log_msg = team_name + " Pawn captured En Passant on " + target_sq
			if current_game_mode == GameMode.BLIND: raw_log_msg = team_name + " captured a piece!"
	
	if piece.current_type == piece.PieceType.PAWN and abs(start_pos.y - target_pos.y) == 2:
			en_passant_target = Vector2i(start_pos.x, int((start_pos.y + target_pos.y) / 2.0))
	else:
		en_passant_target = Vector2i(-1, -1) 
	
	# --- CAPTURING ---
	if board_state.has(target_pos):
		var doomed_team = board_state[target_pos].team
		board_state[target_pos].queue_free()
		var hex_color = Helpers.get_team_hex(self, doomed_team)
		VFXManager.create_explosion(target_pos, Color(hex_color))
		VFXManager.shake_camera(10.0)
		raw_log_msg = team_name + " " + piece_name + " captured on " + target_sq
		if current_game_mode == GameMode.BLIND: raw_log_msg = team_name + " captured a piece!"
		sfx_capture.play()
	else:
		sfx_move.play()
	
	piece.position = Helpers.get_visual_pos(self, target_pos)
	board_state.erase(start_pos)
	board_state[target_pos] = piece
	deselect_piece()
	
	# --- PAWN PROMOTION ---
	if piece.current_type == piece.PieceType.PAWN:
		if (piece.team == Team.BLUE and target_pos.y == 0) or (piece.team == Team.RED and target_pos.y == 7):
			if piece.team == player_team:
				is_promoting = true
				Global.ui.promotion_menu.show()
				var chosen_type = await Global.ui.promotion_selected
				piece.current_type = chosen_type
				Global.ui.promotion_menu.hide()
				is_promoting = false
			else:
				piece.current_type = piece.PieceType.QUEEN 
			
			raw_log_msg += " (Promoted!)"
	
	# --- CATACLYSM LOGIC ---
	if current_game_mode == GameMode.CATACLYSM:
		if hazards.has(target_pos) and hazards[target_pos] == "lava":
			Global.ui.action_log.append_text("[color=#ff0000][b]FATAL ERROR: " + team_name + " melted in the lava![/b][/color]\n")
			var hex_color = Helpers.get_team_hex(self, piece.team)
			piece.queue_free()
			board_state.erase(target_pos)
			VFXManager.create_explosion(target_pos, Color(hex_color)) 
			VFXManager.shake_camera(15.0)
		
		var expired = []
		for h_pos in hazard_timers.keys():
			if total_moves_played >= hazard_timers[h_pos]:
				expired.append(h_pos)
		for e_pos in expired:
			hazards.erase(e_pos)
			hazard_timers.erase(e_pos)
			if hazard_sprites.has(e_pos):
				hazard_sprites[e_pos].queue_free()
				hazard_sprites.erase(e_pos)
			Global.ui.action_log.append_text("[color=#44aaff]The flood at " + Helpers.get_chess_notation(e_pos) + " subsided.[/color]\n")
		
		if total_moves_played % 4 == 0: trigger_disaster()
	
	# --- SWARM LOGIC ---
	if current_game_mode == GameMode.SWARM:
		if piece.team == Team.BLUE:
			swarm_turns_survived += 1
			Global.ui.action_log.append_text("[color=#00ffff]Turns Survived: " + str(swarm_turns_survived) + " / " + str(swarm_target_turns) + "[/color]\n")
			
			if not Global.ui.play_story and swarm_turns_survived > SaveManager.player_stats["best_swarm_turns"]:
				SaveManager.player_stats["best_swarm_turns"] = swarm_turns_survived
				SaveManager.save_game()
			
			if swarm_turns_survived > SaveManager.player_stats["best_swarm_turns"]:
				SaveManager.player_stats["best_swarm_turns"] = swarm_turns_survived
				SaveManager.save_game()
			
			if swarm_turns_survived >= swarm_target_turns:
				trigger_swarm_victory()
				return
		else:
			Spawner.spawn_swarm_enemy(self)
	
	# --- UPDATE THE UI ---
	if Global.ui.action_log != null:
		var hex_color = Helpers.get_team_hex(self, piece.team)
		Global.ui.action_log.append_text("[color=" + hex_color + "]" + raw_log_msg + "[/color]\n")
		
	print(raw_log_msg) 
	
	if current_game_mode == GameMode.TUTORIAL:
		current_turn = Team.BLUE 
	else:
		current_turn = Team.RED if current_turn == Team.BLUE else Team.BLUE
		
		if current_game_mode == GameMode.BLIND and current_turn == player_team:
			var round_num = int(total_moves_played / 2.0)
			if round_num % 3 == 2:
				Global.ui.action_log.append_text("[color=#ffd700][b]*** LIGHT FLARE! All enemies revealed! ***[/b][/color]\n")
			elif round_num % 3 == 0 and total_moves_played > 0:
				Global.ui.action_log.append_text("[color=#888888][b]*** Lights out. The fog returns. ***[/b][/color]\n")
			
		refresh_blind_mode() 
		
		if is_strict_puzzle:
			puzzle_step += 1
			if puzzle_step >= puzzle_sequence.size(): PuzzleManager.trigger_puzzle_victory(self)
			elif current_turn != player_team: PuzzleManager.play_puzzle_enemy_turn(self)
		else:
			check_for_game_over()
			if not game_over:
				if not is_pvp and current_turn != player_team: AIManager.play_ai_turn(self)

# --- CHECK & CHECKMATE ---
func check_for_game_over():
	var has_legal_moves = false
	for pos in board_state.keys():
		var p = board_state[pos]
		if p.team == current_turn:
			for x in range(8):
				for y in range(8):
					if Rulebook.is_safe_move(self, p, pos, Vector2i(x, y)):
						has_legal_moves = true
						break
			if has_legal_moves: break
	
	if not has_legal_moves:
		game_over = true
		Global.ui.btn_quit.hide() 
		Global.ui.btn_flip_board.hide()
		Global.ui.btn_undo.hide()
		Global.ui.btn_hint.hide()
		sfx_win.play()
		
		if Global.ui.play_story: Global.ui.return_btn.text = "Back to Map"
		else: Global.ui.return_btn.text = "Game Modes"
		
		if current_game_mode == GameMode.SWARM and current_turn == Team.RED:
			VFXManager.shake_camera(30.0)
			Global.ui.winner_text.text = "SWARM WIPED OUT!\nVICTORY!" 
			Global.ui.action_log.append_text("[color=#55ff55][b]SWARM WIPED OUT![/b][/color]\n")
		
		elif Rulebook.is_in_check(self, current_turn):
			VFXManager.shake_camera(30.0)
			var winner_team = Team.RED if current_turn == Team.BLUE else Team.BLUE
			var winner_name = Helpers.get_team_color_name(self, winner_team)
			
			if winner_team == player_team: Global.ui.winner_text.text = "CHECKMATE!\nVICTORY! You Win!" 
			else: Global.ui.winner_text.text = "CHECKMATE!\nDEFEAT! You Lose!" 
			
			Global.ui.action_log.append_text("[color=#55ff55][b]CHECKMATE! " + winner_name.to_upper() + " WINS![/b][/color]\n")
		
		else:
			Global.ui.winner_text.text = "STALEMATE!\nIt's a draw!"
			Global.ui.action_log.append_text("[color=#ffff55][b]STALEMATE! It's a draw![/b][/color]\n")
		
		await get_tree().create_timer(3.0).timeout
		
		Global.ui.game_over_menu.show()
		self.visible = false
		Global.ui.timers_ui.hide()
		Global.ui.action_log_panel.hide()
		
		if current_game_mode == GameMode.SWARM and current_turn == Team.RED:
			if Global.ui.play_story and playing_campaign_level == highest_unlocked_level: 
				highest_unlocked_level += 1
				SaveManager.save_game()
			log_match_history(Team.BLUE)
		
		elif Rulebook.is_in_check(self, current_turn):
			var winner_team = Team.RED if current_turn == Team.BLUE else Team.BLUE
			if winner_team == Team.BLUE:
				# QUICK BATTLE
				if not Global.ui.play_story and current_game_mode != GameMode.SWARM:
					var mode_str = str(current_game_mode)
					
					if not SaveManager.player_stats["fastest_modes"].has(mode_str):
						SaveManager.player_stats["fastest_modes"][mode_str] = []
					
					SaveManager.player_stats["fastest_modes"][mode_str].append(current_match_time)
					SaveManager.player_stats["fastest_modes"][mode_str].sort()
					
					if SaveManager.player_stats["fastest_modes"][mode_str].size() > 5:
						SaveManager.player_stats["fastest_modes"][mode_str] = SaveManager.player_stats["fastest_modes"][mode_str].slice(0, 5)
					
					log_match_history(winner_team)
					SaveManager.save_game()
				
				# CAMPAIGN PROGRESSION
				if Global.ui.play_story:
					if playing_campaign_level == highest_unlocked_level:
						highest_unlocked_level += 1
						SaveManager.save_game()
		else:
			log_match_history(Team.BLUE, true)
	else:
		if Rulebook.is_in_check(self, current_turn):
			VFXManager.shake_camera(15.0)
			var team_name = Helpers.get_team_color_name(self, current_turn)
			var team_hex = Helpers.get_team_hex(self, current_turn)
			Global.ui.action_log.append_text("[color=" + team_hex + "][b]CHECK!!! " + team_name.to_upper() + " is under attack![/b][/color]\n")
			sfx_check.play()

func time_out(winner_team: Team):
	game_over = true
	Global.ui.btn_quit.hide()
	Global.ui.btn_flip_board.hide()
	Global.ui.btn_undo.hide()
	
	var winner_str = Helpers.get_team_color_name(self, winner_team)
	var loser_team = Team.BLUE if winner_team == Team.RED else Team.RED
	var loser_str = Helpers.get_team_color_name(self, loser_team)
	
	if winner_team == player_team: Global.ui.winner_text.text = "TIME OUT!\nVICTORY!" 
	else: Global.ui.winner_text.text = "TIME OUT!\nDEFEAT!" 
	
	Global.ui.action_log.append_text("[color=#ffaa00][b]TIME OUT! " + loser_str.to_upper() + " CLOCK REACHED 0:00![/b][/color]\n")
	Global.ui.action_log.append_text("[color=#55ff55][b]" + winner_str.to_upper() + " WINS![/b][/color]\n")
	
	if Global.ui.play_story: Global.ui.return_btn.text = "Back to Map"
	else: Global.ui.return_btn.text = "Game Modes"
	
	await get_tree().create_timer(3.0).timeout
	
	Global.ui.game_over_menu.show() 
	self.visible = false
	Global.ui.timers_ui.hide()
	Global.ui.action_log_panel.hide()
	
	if Global.ui.play_story and winner_team == Team.BLUE:
		if playing_campaign_level == highest_unlocked_level:
			highest_unlocked_level += 1
			SaveManager.save_game()
	
	log_match_history(winner_team)

# --- THE SWARM MECHANICS ---
func trigger_swarm_victory():
	game_over = true
	Global.ui.btn_quit.hide()
	Global.ui.btn_flip_board.hide()
	Global.ui.btn_undo.hide()
	sfx_win.play()
	
	Global.ui.winner_text.text = "SURVIVED!\nVICTORY!"
	Global.ui.action_log.append_text("[color=#55ff55][b]THE SWARM WAS SURVIVED! YOU WON![/b][/color]\n")
	
	if Global.ui.play_story: Global.ui.return_btn.text = "Back to Map"
	else: Global.ui.return_btn.text = "Game Modes"
	
	await get_tree().create_timer(3.0).timeout
	
	Global.ui.game_over_menu.show()
	self.visible = false
	Global.ui.timers_ui.hide()
	Global.ui.action_log_panel.hide()
	
	log_match_history(Team.BLUE)
	
	if Global.ui.play_story and playing_campaign_level == highest_unlocked_level: 
		highest_unlocked_level += 1
		SaveManager.save_game()

# --- THE CATACLYSM MECHANIC ---
func trigger_disaster():
	var disaster_type = ""
	
	if playing_campaign_level == 10: disaster_type = "lava" if randf() > 0.5 else "flood"
	elif playing_campaign_level == 11: disaster_type = "earthquake" if randf() > 0.5 else "typhoon"
	
	else:
		var rng = randf()
		disaster_type = "earthquake"
		if rng > 0.75: disaster_type = "lava"
		elif rng > 0.50: disaster_type = "flood"
		elif rng > 0.25: disaster_type = "typhoon"
		
		var hazard_pos = Vector2i(randi() % 8, randi() % 8)
		
		if disaster_type == "earthquake":
			while hazards.has(hazard_pos) or board_state.has(hazard_pos):
				hazard_pos = Vector2i(randi() % 8, randi() % 8)
		else:
			var valid_pos = false
			while not valid_pos:
				hazard_pos = Vector2i(randi() % 8, randi() % 8)
				valid_pos = not hazards.has(hazard_pos)
				if board_state.has(hazard_pos) and board_state[hazard_pos].current_type == 7:
					valid_pos = false
		
		hazards[hazard_pos] = disaster_type
		var danger_tile = disaster_scene.instantiate()
		danger_tile.position = Helpers.get_visual_pos(self, hazard_pos)
		danger_tile.y_sort_enabled = false 
		danger_tile.z_index = 2 
		danger_tile.scale = Vector2(1.0, 1.0) 
		
		add_child(danger_tile)
		hazard_sprites[hazard_pos] = danger_tile
		
		var anim = danger_tile.get_node_or_null("AnimationPlayer")
		if anim: anim.play(disaster_type)
		
		var duration = 0
		if disaster_type == "typhoon": duration = 2 # 1 Turn
		elif disaster_type == "flood": duration = 4 # 2 Turns
		elif disaster_type == "lava" or disaster_type == "earthquake": duration = 6 # 3 Turns
		hazard_timers[hazard_pos] = total_moves_played + duration
		
		var sq_name = Helpers.get_chess_notation(hazard_pos)
		if disaster_type == "earthquake":
			Global.ui.action_log.append_text("[color=#aaaaaa][b]DISASTER: A boulder crashed onto " + sq_name + "![/b][/color]\n")
		elif disaster_type == "lava":
			Global.ui.action_log.append_text("[color=#ffaa00][b]WARNING: Tile " + sq_name + " erupted into lava![/b][/color]\n")
			if board_state.has(hazard_pos):
				var doomed = board_state[hazard_pos]
				var hex_color = Helpers.get_team_hex(self, doomed.team)
				Global.ui.action_log.append_text("[color=#ff0000][b]CATASTROPHE! " + Helpers.get_piece_name(doomed.current_type) + " burned![/b][/color]\n")
				doomed.queue_free()
				board_state.erase(hazard_pos)
				VFXManager.create_explosion(hazard_pos, Color(hex_color))
				VFXManager.shake_camera(15.0)
		elif disaster_type == "flood":
			Global.ui.action_log.append_text("[color=#44aaff][b]WARNING: Tile " + sq_name + " flooded![/b][/color]\n")
			if board_state.has(hazard_pos):
				var victim = board_state[hazard_pos]
				var bounced = false
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						if dx == 0 and dy == 0: continue
						var n_pos = hazard_pos + Vector2i(dx, dy)
						if n_pos.x >= 0 and n_pos.x <= 7 and n_pos.y >= 0 and n_pos.y <= 7:
							if not board_state.has(n_pos) and not hazards.has(n_pos):
								board_state.erase(hazard_pos)
								board_state[n_pos] = victim
								var safe = not Rulebook.is_in_check(self, victim.team)
								if safe:
									bounced = true
									victim.position = Helpers.get_visual_pos(self, n_pos)
									Global.ui.action_log.append_text("[color=#44aaff]The flood washed " + Helpers.get_piece_name(victim.current_type) + " to " + Helpers.get_chess_notation(n_pos) + "![/color]\n")
									break 
								else:
									board_state.erase(n_pos)
									board_state[hazard_pos] = victim
					if bounced: break
				if not bounced:
					var hex_color = Helpers.get_team_hex(self, victim.team)
					Global.ui.action_log.append_text("[color=#ff0000][b]DROWNED! " + Helpers.get_piece_name(victim.current_type) + " had nowhere to wash ashore![/b][/color]\n")
					victim.queue_free()
					board_state.erase(hazard_pos)
					VFXManager.create_explosion(hazard_pos, Color(hex_color))
					VFXManager.shake_camera(15.0)
		elif disaster_type == "typhoon":
			Global.ui.action_log.append_text("[color=#aaaaaa][b]WARNING: A Typhoon struck " + sq_name + "![/b][/color]\n")
			if board_state.has(hazard_pos):
				var victim = board_state[hazard_pos]
				var safe_spots = []
				for x in range(8):
					for y in range(8):
						var p = Vector2i(x,y)
						if not board_state.has(p) and not hazards.has(p):
							board_state.erase(hazard_pos)
							board_state[p] = victim
							if not Rulebook.is_in_check(self, victim.team):
								safe_spots.append(p)
							board_state.erase(p)
							board_state[hazard_pos] = victim
				
				if safe_spots.size() > 0:
					var random_landing = safe_spots.pick_random()
					board_state.erase(hazard_pos)
					victim.position = Helpers.get_visual_pos(self, random_landing)
					board_state[random_landing] = victim
					Global.ui.action_log.append_text("[color=#aaaaaa]Typhoon blew " + Helpers.get_piece_name(victim.current_type) + " to " + Helpers.get_chess_notation(random_landing) + "![/color]\n")
				else:
					var hex_color = Helpers.get_team_hex(self, victim.team)
					Global.ui.action_log.append_text("[color=#ff0000][b]DESTROYED! " + Helpers.get_piece_name(victim.current_type) + " was blown off the board![/b][/color]\n")
					victim.queue_free()
					board_state.erase(hazard_pos)
					VFXManager.create_explosion(hazard_pos, Color(hex_color))
				VFXManager.shake_camera(15.0)

# --- PIECE SELECT HELPERS ---
func select_piece(piece, grid_pos):
	sfx_click.play()
	deselect_piece() 
	selected_piece = piece
	selected_grid_pos = grid_pos
	selected_piece.modulate = piece.base_color * 1.5
	show_highlights(selected_piece, selected_grid_pos)
	
	if current_game_mode == GameMode.BLIND and piece.team == player_team:
		for pos in board_state.keys():
			var enemy = board_state[pos]
			if enemy.team != player_team:
				if Rulebook.is_safe_move(self, piece, grid_pos, pos):
					enemy.visible = true
	
	update_fog_of_war()

func deselect_piece():
	if selected_piece != null:
		selected_piece.modulate = selected_piece.base_color
		selected_piece = null
		selected_grid_pos = Vector2i(-1, -1)
	clear_highlights() 
	refresh_blind_mode()

func show_highlights(piece, start_pos):
	for x in range(8):
		for y in range(8):
			var target = Vector2i(x, y)
			if Rulebook.is_safe_move(self, piece, start_pos, target): draw_highlight(target)

func draw_highlight(grid_pos):
	var highlight = Sprite2D.new()
	highlight.texture = load("res://Assets/Sprites/Tile_White.png")
	highlight.modulate = Color(0, 1, 0, 0.5) 
	highlight.position = Helpers.get_visual_pos(self, grid_pos)
	highlight.y_sort_enabled = false 
	highlight.z_index = 10
	add_child(highlight)
	active_highlights.append(highlight)

func clear_highlights():
	for hl in active_highlights: hl.queue_free()
	active_highlights.clear()

# --- FOG OF WAR SYSTEM ---
func is_blind_light_turn() -> bool:
	if current_game_mode != GameMode.BLIND: return false
	var round_num = int(total_moves_played / 2.0)
	return (round_num % 3) == 2

func refresh_blind_mode():
	if current_game_mode != GameMode.BLIND: return
	var light_turn = is_blind_light_turn()
	
	for pos in board_state.keys():
		var p = board_state[pos]
		if p.team != player_team:
			p.visible = light_turn 
			
	update_fog_of_war()

func update_fog_of_war():
	for fog in fog_sprites: fog.queue_free()
	fog_sprites.clear()
	
	if current_game_mode != GameMode.BLIND: return 
	if is_blind_light_turn(): return 
	
	for x in range(8):
		for y in range(8):
			var pos = Vector2i(x, y)
			var needs_fog = true
			
			if board_state.has(pos):
				var p = board_state[pos]
				if p.visible == true:
					needs_fog = false
			
			if needs_fog:
				var dark_tile = Sprite2D.new()
				dark_tile.texture = load("res://Assets/Sprites/Tile_White.png")
				dark_tile.modulate = Color(0, 0, 0, 0.7) 
				dark_tile.position = Helpers.get_visual_pos(self, pos)
				dark_tile.y_sort_enabled = false 
				dark_tile.z_index = 3
				add_child(dark_tile)
				fog_sprites.append(dark_tile)

func return_to_menu():
	Global.ui.game_over_menu.hide()
	Global.ui.action_log_panel.hide()
	Global.ui.timers_ui.hide()
	Global.ui.tutorial_menu.hide()
	Global.ui.btn_flip_board.hide()
	Global.ui.btn_undo.hide()
	self.visible = false
	
	cleanup_board()
	
	if Global.ui.play_story: 
		if Global.board.playing_campaign_level == 18:
			Global.ui.credits_menu.show()
		else:
			Global.ui.open_map()
	else: 
		Global.ui.game_modes_menu.show()

func log_match_history(winner_team: Team, is_draw: bool = false):
	if Global.ui.play_story: return 
	var mode_name = GameMode.keys()[current_game_mode].replace("_", " ")
	var result = "Draw"
	if not is_draw: result = "Win" if winner_team == player_team else "Loss"
	SaveManager.record_match(mode_name, result, current_match_time)

# --- UNDO SYSTEM ---
func save_state_snapshot():
	var snapshot = {
		"pieces": [],
		"hazards": hazards.duplicate(true),
		"hazard_timers": hazard_timers.duplicate(true),
		"current_turn": current_turn,
		"total_moves": total_moves_played,
		"swarm_turns": swarm_turns_survived,
		"en_passant_target": en_passant_target,
		"moved_piece_positions": []
	}
	
	for pos in board_state.keys():
		var p = board_state[pos]
		snapshot["pieces"].append({
			"pos": pos,
			"type": p.current_type,
			"team": p.team
		})
		if pieces_that_moved.has(p):
			snapshot["moved_piece_positions"].append(pos)
	
	history_stack.append(snapshot)

func undo_move():
	if is_strict_puzzle: return
	if NetworkManager.is_lan_match or in_draft_phase or history_stack.size() == 0: return
	
	if not is_pvp and current_turn != player_team:
		Global.ui.action_log.append_text("[color=#ff0000]Cannot undo while the AI is thinking![/color]\n")
		return
	
	if not is_pvp and history_stack.size() < 2:
		Global.ui.action_log.append_text("[color=#ff0000]You must make a move before you can undo![/color]\n")
		return
	
	sfx_click.play()
	
	var pops_needed = 1
	if not is_pvp and current_turn == player_team and history_stack.size() >= 2: pops_needed = 2
	
	var snapshot = null
	for i in range(pops_needed): snapshot = history_stack.pop_back()
	
	if snapshot == null: return
	for pos in board_state.keys(): board_state[pos].queue_free()
	board_state.clear()
	pieces_that_moved.clear()
	
	for hs in hazard_sprites.values(): hs.queue_free()
	hazard_sprites.clear()
	hazards.clear()
	
	for p_data in snapshot["pieces"]:
		Spawner.spawn_piece(self, p_data["pos"].x, p_data["pos"].y, p_data["team"], p_data["type"])
		if snapshot["moved_piece_positions"].has(p_data["pos"]):
			pieces_that_moved.append(board_state[p_data["pos"]])
	
	for h_pos in snapshot["hazards"].keys():
		Spawner.spawn_manual_hazard(self, h_pos, snapshot["hazards"][h_pos])
	
	current_turn = snapshot["current_turn"]
	total_moves_played = snapshot["total_moves"]
	swarm_turns_survived = snapshot["swarm_turns"]
	hazard_timers = snapshot["hazard_timers"].duplicate(true)
	en_passant_target = snapshot["en_passant_target"]
	
	if is_strict_puzzle: puzzle_step = max(0, puzzle_step - pops_needed)
	
	game_over = false
	Global.ui.game_over_menu.hide()
	Global.ui.btn_quit.show()
	self.visible = true
	deselect_piece()
	update_fog_of_war()
	
	Global.ui.action_log.append_text("[color=#aaaaaa]--- TIME REVERSED (Undo) ---[/color]\n")

func surrender(loser_team: Team):
	game_over = true
	Global.ui.btn_quit.hide()
	Global.ui.btn_flip_board.hide()
	Global.ui.btn_undo.hide()
	Global.ui.btn_hint.hide()
	Global.ui.draft_menu.hide()
	Global.ui.tutorial_menu.hide()
	
	var winner_team = Team.RED if loser_team == Team.BLUE else Team.BLUE
	var winner_str = Helpers.get_team_color_name(self, winner_team)
	var loser_str = Helpers.get_team_color_name(self, loser_team)
	
	if winner_team == player_team: Global.ui.winner_text.text = "SURRENDER!\nVICTORY!" 
	else: Global.ui.winner_text.text = "SURRENDER!\nDEFEAT!" 
	
	Global.ui.action_log.append_text("[color=#ffaa00][b]" + loser_str.to_upper() + " SURRENDERED![/b][/color]\n")
	Global.ui.action_log.append_text("[color=#55ff55][b]" + winner_str.to_upper() + " WINS![/b][/color]\n")
	sfx_win.play()
	
	if Global.ui.play_story: Global.ui.return_btn.text = "Back to Map"
	else: Global.ui.return_btn.text = "Game Modes"
	
	await get_tree().create_timer(3.0).timeout
	
	Global.ui.game_over_menu.show() 
	self.visible = false
	Global.ui.timers_ui.hide()
	Global.ui.action_log_panel.hide()
	
	if Global.ui.play_story and winner_team == Team.BLUE:
		if playing_campaign_level == highest_unlocked_level:
			highest_unlocked_level += 1
			SaveManager.save_game()
	
	log_match_history(winner_team)

func update_coordinates_visibility():
	if coords_control == null: return
	
	var active_index = camera_angle + 1 
	
	for i in range(1, 5):
		var num_node = coords_control.get_node_or_null("Numbers_" + str(i))
		var let_node = coords_control.get_node_or_null("Letters_" + str(i))
		
		if num_node: num_node.visible = (i == active_index)
		if let_node: let_node.visible = (i == active_index)

# --- STRICT PUZZLE LOGIC ---
func play_puzzle_enemy_turn():
	await get_tree().create_timer(0.6).timeout
	var expected_move = puzzle_sequence[puzzle_step]
	var piece = board_state[expected_move["start"]]
	execute_move(piece, expected_move["start"], expected_move["target"])

func trigger_puzzle_victory():
	game_over = true
	sfx_win.play()
	
	self.visible = false
	Global.ui.timers_ui.hide()
	Global.ui.action_log_panel.hide()
	
	Global.ui.action_log.append_text("[color=#55ff55][b]PUZZLE SOLVED![/b][/color]\n")
	
	if playing_campaign_level == highest_unlocked_level: highest_unlocked_level += 1
	
	Global.ui.open_map()

func show_puzzle_hint():
	if not is_strict_puzzle or current_turn != player_team or game_over: return
	if puzzle_step >= puzzle_sequence.size(): return
	
	sfx_click.play()
	clear_highlights() 
	
	var expected_move = puzzle_sequence[puzzle_step]
	
	var start_hl = Sprite2D.new()
	start_hl.texture = load("res://Assets/Sprites/Tile_White.png")
	start_hl.modulate = Color(1.0, 0.84, 0.0, 0.6) # Glowing Gold!
	start_hl.position = Helpers.get_visual_pos(self, expected_move["start"])
	start_hl.y_sort_enabled = false
	start_hl.z_index = 10
	add_child(start_hl)
	active_highlights.append(start_hl)
	
	var target_hl = Sprite2D.new()
	target_hl.texture = load("res://Assets/Sprites/Tile_White.png")
	target_hl.modulate = Color(1.0, 0.84, 0.0, 0.6) # Glowing Gold!
	target_hl.position = Helpers.get_visual_pos(self, expected_move["target"])
	target_hl.y_sort_enabled = false
	target_hl.z_index = 10
	add_child(target_hl)
	active_highlights.append(target_hl)
	
	if Global.ui.action_log != null:
		Global.ui.action_log.append_text("[color=#ffd700]Hint Used![/color]\n")
