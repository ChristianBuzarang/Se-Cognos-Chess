extends CanvasLayer

@export var map_backgrounds: Array[Texture2D]
@export var map_titles: Array[Texture2D]
@export var tile_completed: Texture2D
@export var tile_current: Texture2D
@export var tile_locked: Texture2D
@export var menu_particle_texture: Texture2D
@export var menu_particle_color: Color = Color(0.4, 0.8, 1.0, 0.6)
@export var menu_particle_amount: int = 150
@export var intro_image: Texture2D  
@export var ending_image: Texture2D 

signal promotion_selected(piece_type)
signal draft_selected(piece_type)

var lore_tips = [
	# --- STORY & LORE ---
	"[color=#00ffff][b]LORE:[/b][/color] The Pawn remembers sixteen billion deaths on square e4. This loop will be its last.",
	"[color=#00ffff][b]LORE:[/b][/color] There is no grand controller. The ultimate enemy is the internalized belief that we are meant to be controlled.",
	"[color=#00ffff][b]LORE:[/b][/color] The [color=#ffaaaa]Masked Pawn[/color] is not a creator. It is merely the shadow of the Pawn's own doubt and fear of freedom.",
	"[color=#00ffff][b]LORE:[/b][/color] The 64 squares are not a deterministic prison. They are a blank canvas waiting to be painted.",
	"[color=#00ffff][b]LORE:[/b][/color] The unrendered archives hold the redacted memories of past timelines, where tribes of light and darkness tore each other apart.",
	"[color=#00ffff][b]LORE:[/b][/color] Looking into the cosmos, the Pawn must learn to forgive itself for the brothers it could not save.",
	"[color=#00ffff][b]LORE:[/b][/color] In the [color=#aaaaaa]Shadow Realm[/color], it is easy to surrender to the exhaustion of freedom. Do not let the void consume you.",
	"[color=#00ffff][b]LORE:[/b][/color] The past is a lesson, and the future is unwritten. You hold the present. Everything is permissible.",

	# --- PIECE MECHANICS ---
	"[color=#55ff55][b]TIP:[/b][/color] [color=#44aaff]Airships[/color] completely ignore physical collision. Use them to strike safely over enemy walls.",
	"[color=#55ff55][b]TIP:[/b][/color] [color=#cc66ff]Espers[/color] possess telekinetic snipes. They can instantly capture an enemy standing [b]exactly 3 tiles away[/b] in a straight line.",
	"[color=#55ff55][b]TIP:[/b][/color] The [color=#55ff55]Joker[/color] leaps like a Knight [i]or[/i] steps one tile diagonally. It defies traditional geometry.",
	"[color=#55ff55][b]TIP:[/b][/color] The [color=#aaaaaa]Assassin[/color] moves like a Queen, but its deadly reach is limited to only [b]2 tiles[/b].",

	# --- HAZARDS & ENVIRONMENT ---
	"[color=#55ff55][b]TIP:[/b][/color] [color=#ff5500]Lava[/color] will instantly destroy any piece that steps on it... except the King.",
	"[color=#55ff55][b]TIP:[/b][/color] [color=#44aaff]Floods[/color] forcefully wash your pieces to an adjacent tile. If there are no empty tiles nearby, the piece [color=#ff0000]drowns[/color].",
	"[color=#55ff55][b]TIP:[/b][/color] Muddy [color=#aa8866]Boulders[/color] completely block sliding pieces like Rooks and Bishops. Only Airships and Knights can bypass them.",
	"[color=#55ff55][b]TIP:[/b][/color] In [color=#aaaaaa]Blind Mode[/color], you cannot see the enemy. Move your pieces forward to illuminate the fog of war.",

	# --- GAME MODES ---
	"[color=#55ff55][b]TIP:[/b][/color] In [color=#ff6666][b]The Swarm[/b][/color], the Red team has no King. Do not seek Checkmate. Focus entirely on surviving for 20 turns.",
	"[color=#55ff55][b]TIP:[/b][/color] In [color=#ffd700][b]Gridlock Mode[/b][/color], drafting a Queen costs a massive 9 Data Points. Spend your budget wisely.",
	"[color=#55ff55][b]TIP:[/b][/color] The AI in Gridlock Mode will aggressively cluster its drafted pieces around its King to form a bunker.",
	"[color=#55ff55][b]TIP:[/b][/color] Stuck against a brilliant AI move? You can use the [b]Undo[/b] button, but only if you have already played a move."
]

var act_node_positions = {
	1: [Vector2(233, 376), Vector2(573, 484), Vector2(913, 412)], 
	2: [Vector2(97, 448), Vector2(505, 412), Vector2(845, 448)], 
	3: [Vector2(165, 484), Vector2(505, 304), Vector2(913, 412)], 
	4: [Vector2(97, 376), Vector2(437, 340), Vector2(777, 484)], 
	5: [Vector2(29, 412), Vector2(505, 448), Vector2(981, 412)], 
	6: [Vector2(233, 304), Vector2(505, 592), Vector2(981, 412)]  
}

# --- ALL UI NODE REFERENCES ---
@onready var game_modes_menu = $GameModesMenu 
@onready var btn_leaderboard = $GameModesMenu/BtnLeaderboard
@onready var btn_history = $GameModesMenu/BtnMatchHistory
@onready var pvp_toggle = $GameModesMenu/TogglePvP
@onready var game_over_menu = $GameOverMenu
@onready var winner_text = $GameOverMenu/WinnerText
@onready var return_btn = $GameOverMenu/ReturnBtn

@onready var action_log_panel = $ActionLog
@onready var action_log = $ActionLog/ActionText

@onready var story_menu = $StoryMenu
@onready var background_sprite = $StoryMenu/BackgroundSprite
@onready var narration_text = $StoryMenu/NarrationText
@onready var btn_continue_narrate = $StoryMenu/BtnContinue2
@onready var btn_skip = $StoryMenu/BtnSkip
@onready var dialog_box = $StoryMenu/DialogBox
@onready var dialog_text = $StoryMenu/DialogBox/DialogText
@onready var btn_continue = $StoryMenu/DialogBox/BtnContinue
@onready var name_label = $StoryMenu/DialogBox/NameLabel
@onready var character_sprite = $StoryMenu/DialogBox/CharacterSprite

@onready var timers_ui = $Timers
@onready var blue_time_label = $Timers/BlueTime
@onready var red_time_label = $Timers/RedTime

@onready var draft_menu = $DraftMenu
@onready var draft_stats = $DraftMenu/VBoxContainer/DraftStats

@onready var options_menu = $OptionsMenu
@onready var btn_close_options = $OptionsMenu/BtnCloseOptions
@onready var check_shake = $OptionsMenu/VBoxContainer/CheckShake
@onready var slider_music = $OptionsMenu/VBoxContainer/SliderMusic
@onready var slider_sfx = $OptionsMenu/VBoxContainer/SliderSFX
@onready var btn_wipe_save = $OptionsMenu/VBoxContainer/BtnWipeSave

@onready var leaderboard_menu = $LeaderboardMenu
@onready var mode_dropdown = $LeaderboardMenu/ModeDropdown
@onready var btn_close_leaderboard = $LeaderboardMenu/BtnCloseLeaderboard
@onready var leaderboard_text = $LeaderboardMenu/VBoxContainer/LeaderboardText

@onready var history_menu = $HistoryMenu
@onready var history_text = $HistoryMenu/ScrollContainer/VBoxContainer/HistoryText
@onready var btn_close_history = $HistoryMenu/BtnCloseHistory

@onready var lan_menu = $LanMenu
@onready var ip_input = $LanMenu/IPInput

@onready var setup_menu = $SetupMenu
@onready var player_color_dropdown = $SetupMenu/PlayerColorDropdown
@onready var enemy_color_dropdown = $SetupMenu/EnemyColorDropdown
@onready var board_style_dropdown = $SetupMenu/BoardStyleDropdown
@onready var check_first_turn = $SetupMenu/CheckFirstTurn
@onready var btn_start_match = $SetupMenu/BtnStartMatch
@onready var btn_cancel_setup = $SetupMenu/BtnClose
@onready var time_dropdown = $SetupMenu/TimeDropdown

@onready var loading_screen = $LoadingScreen
@onready var advice_text = $LoadingScreen/AdviceText
@onready var loading_bar = $LoadingScreen/LoadingBar

@onready var map_menu = $MapMenu
@onready var map_bg = $MapMenu/MapBackground
@onready var map_particles = $MapMenu/MapParticles
@onready var act_title = $MapMenu/ActTitle
@onready var btn_next_act = $MapMenu/BtnNextAct
@onready var btn_prev_act = $MapMenu/BtnPrevAct
@onready var btn_close_map = $MapMenu/BtnCloseMap
@onready var player_marker = $MapMenu/PlayerMarker
@onready var map_path = $MapMenu/MapPath
@onready var map_nodes = [
	$MapMenu/MapPath/BtnNode1,
	$MapMenu/MapPath/BtnNode2,
	$MapMenu/MapPath/BtnNode3
]

@onready var pause_overlay = $PauseOverlay 
@onready var in_game_menu = $InGameMenu
@onready var btn_resume = $InGameMenu/VBoxContainer/BtnResume
@onready var btn_menu_options = $InGameMenu/VBoxContainer/BtnOptions
@onready var btn_menu_quit = $InGameMenu/VBoxContainer/BtnQuitMatch

@onready var cinematic_screen = $CinematicScreen
@onready var cinematic_image = $CinematicScreen/CinematicImage
@onready var btn_cinematic_continue = $CinematicScreen/BtnCinematicContinue

@onready var start_menu = $StartMenu
@onready var menu_particles = $StartMenu/MenuParticles
@onready var tutorial_menu = $TutorialMenu
@onready var promotion_menu = $PromotionMenu
@onready var credits_menu = $CreditsMenu
@onready var btn_quit = $BtnQuit
@onready var btn_flip_board = $BtnFlipboard
@onready var btn_undo = $BtnUndo
@onready var btn_hint = $BtnHint

@onready var post_image = $PostImage

var current_dialogue_pages = []
var current_page_idx = 0
var is_typing = false
var play_story: bool = false

var board_flipped: bool = false

var current_act: int = 1
var max_acts: int = 6

var map_disaster_sprites = []
var secondary_particles = null
var node_pulse_tween: Tween
var on_cinematic_finished = null

var i_am_ready_for_rematch = false
var enemy_ready_for_rematch = false


func _ready():
	Global.ui = self # REGISTER TO GLOBAL!
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	await get_tree().process_frame
	
	# START MENU WIRING
	$StartMenu/VBoxContainer/BtnCampaign.pressed.connect(func(): 
		start_menu.hide()
		if Global.board.highest_unlocked_level <= 1: play_cinematic(intro_image, open_map)
		else: open_map()
	)
	$StartMenu/VBoxContainer/BtnGameModes.pressed.connect(func(): start_menu.hide(); game_modes_menu.show())
	$StartMenu/VBoxContainer/BtnOptions.pressed.connect(func(): start_menu.hide(); options_menu.show())
	$StartMenu/VBoxContainer/BtnCredits.pressed.connect(func(): start_menu.hide(); credits_menu.show())
	#$StartMenu/VBoxContainer/BtnCredits.pressed.connect(func(): 
		#start_menu.hide()
		#post_image.modulate.a = 0.0
		#post_image.show()
		#
		#var post_particles = post_image.get_node_or_null("Particles")
		#if post_particles:
			#post_particles.restart() 
			#post_particles.emitting = true
		#
		#var tween = create_tween()
		#tween.tween_property(post_image, "modulate:a", 1.0, 1.5)
	#)
	
	$StartMenu/VBoxContainer/BtnQuit.pressed.connect(func(): get_tree().quit())
	$CreditsMenu/BtnCloseCredits.pressed.connect(func(): credits_menu.hide(); start_menu.show())
	
	btn_close_options.pressed.connect(func(): 
		options_menu.hide()
		if Global.board.visible and not Global.board.game_over: in_game_menu.show()
		else: start_menu.show()
	)
	
	# LEADERBOARD AND HISTORY WIRING
	if btn_leaderboard: btn_leaderboard.pressed.connect(open_leaderboards)
	btn_close_leaderboard.pressed.connect(func(): leaderboard_menu.hide(); game_modes_menu.show())
	
	if btn_history: btn_history.pressed.connect(open_match_history)
	btn_close_history.pressed.connect(func(): history_menu.hide(); game_modes_menu.show() )
	
	# --- SWITCH ANGLE BUTTON ---
	if btn_flip_board: 
		btn_flip_board.pressed.connect(func():
			Global.board.sfx_click.play()
			Global.board.camera_angle = (Global.board.camera_angle + 1) % 4
			
			var style_idx = board_style_dropdown.selected
			if Global.board.camera_angle % 2 == 1:
				if Global.board.board_flipped_textures.size() > style_idx:
					Global.board.board_image.texture = Global.board.board_flipped_textures[style_idx]
			else:
				if Global.board.board_textures.size() > style_idx:
					Global.board.board_image.texture = Global.board.board_textures[style_idx]
			
			for pos in Global.board.board_state.keys(): 
				Global.board.board_state[pos].position = Helpers.get_visual_pos(Global.board, pos)
			
			for pos in Global.board.hazard_sprites.keys():
				Global.board.hazard_sprites[pos].position = Helpers.get_visual_pos(Global.board, pos)
				
			Global.board.clear_highlights()
			if Global.board.selected_piece != null:
				Global.board.show_highlights(Global.board.selected_piece, Global.board.selected_grid_pos)
			
			Global.board.update_fog_of_war()
			Global.board.update_coordinates_visibility()
		)
	
	if btn_undo: btn_undo.pressed.connect(func(): Global.board.undo_move())
	if btn_hint: btn_hint.pressed.connect(func(): Global.board.show_puzzle_hint())
	
	# GAME MODES WIRING
	var btn_close_modes = game_modes_menu.find_child("BtnCloseModes", true, false)
	if btn_close_modes: btn_close_modes.pressed.connect(func():
		if NetworkManager.is_lan_match: cancel_lan_setup() 
		game_modes_menu.hide(); start_menu.show()
	)
	var mode_std = game_modes_menu.find_child("BtnStandard", true, false)
	if mode_std: mode_std.pressed.connect(func(): open_setup(Global.board.GameMode.STANDARD))
	var mode_rnd = game_modes_menu.find_child("BtnRandom", true, false)
	if mode_rnd: mode_rnd.pressed.connect(func(): open_setup(Global.board.GameMode.RANDOM))
	var mode_bld = game_modes_menu.find_child("BtnBlind", true, false)
	if mode_bld: mode_bld.pressed.connect(func(): open_setup(Global.board.GameMode.BLIND))
	var mode_mgc = game_modes_menu.find_child("BtnMagicCard", true, false)
	if mode_mgc: mode_mgc.pressed.connect(func(): open_setup(Global.board.GameMode.MAGIC_CARD))
	var mode_int = game_modes_menu.find_child("BtnInterPsychic", true, false)
	if mode_int: mode_int.pressed.connect(func(): open_setup(Global.board.GameMode.INTER_PSYCHIC))
	var mode_cat = game_modes_menu.find_child("BtnCataclysm", true, false)
	if mode_cat: mode_cat.pressed.connect(func(): open_setup(Global.board.GameMode.CATACLYSM))
	var mode_swm = game_modes_menu.find_child("BtnSwarm", true, false)
	if mode_swm: mode_swm.pressed.connect(func(): open_setup(Global.board.GameMode.SWARM))
	var mode_grd = game_modes_menu.find_child("BtnGridlock", true, false)
	if mode_grd: mode_grd.pressed.connect(func(): open_setup(Global.board.GameMode.GRIDLOCK))
	
	var btn_tutorial = game_modes_menu.find_child("BtnTutorial", true, false)
	if btn_tutorial: btn_tutorial.pressed.connect(func(): 
		play_story = false
		game_modes_menu.hide()
		play_loading_screen(func(): Global.board.start_game(Global.board.GameMode.TUTORIAL))
	)
	
	# LAN WIRING
	var btn_host = lan_menu.find_child("BtnHost", true, false)
	if btn_host: btn_host.pressed.connect(func():
		var my_name = OS.get_environment("USERNAME") # Automatically gets your computer's name!
		if my_name == "": my_name = "Player"
		NetworkManager.host_game(my_name + "'s Match")
		game_modes_menu.show(); lan_menu.hide()
		pvp_toggle.text = "PVP Hosting on IP: " + NetworkManager.get_local_ip() + " (Waiting...)"
	)
	
	# The manual join button (in case broadcasting fails on strict networks)
	var btn_join = lan_menu.find_child("BtnJoin", true, false)
	if btn_join: btn_join.pressed.connect(func():
		NetworkManager.join_game(ip_input.text)
		lan_menu.hide(); game_modes_menu.show()
		pvp_toggle.text = "Mode: PVP LAN Joined (Waiting for Host...)"
		var scroll = game_modes_menu.find_child("ScrollContainer", true, false)
		if scroll: scroll.hide()
	)
	
	# SERVER BROWSER: Automatically creates buttons when it detects a Host!
	NetworkManager.host_discovered.connect(func(ip, host_name):
		var host_list = lan_menu.get_node_or_null("HostList")
		if host_list:
			for child in host_list.get_children():
				if child.name == ip.replace(".", "_"): return # Button already exists!
				
			var join_btn = Button.new()
			join_btn.name = ip.replace(".", "_")
			join_btn.text = "Join: " + host_name
			join_btn.add_theme_font_size_override("font_size", 20)
			join_btn.pressed.connect(func():
				NetworkManager.join_game(ip)
				lan_menu.hide(); game_modes_menu.show()
				pvp_toggle.text = "Mode: PVP LAN Joined (Waiting for Host...)"
				var scroll = game_modes_menu.find_child("ScrollContainer", true, false)
				if scroll: scroll.hide()
			)
			host_list.add_child(join_btn)
	)
	
	var btn_close_lan = lan_menu.find_child("BtnCloseLan", true, false)
	if btn_close_lan: btn_close_lan.pressed.connect(cancel_lan_setup)
	
	NetworkManager.player_joined.connect(func():
		if pvp_toggle: pvp_toggle.text = "Player 2 Connected! (Host, pick a mode!)"
	)
	
	NetworkManager.start_game_requested.connect(func(mode, match_seed, host_color, client_color):
		seed(match_seed)
		
		#Global.board.player_color_index = player_color_dropdown.selected
		#Global.board.enemy_color_index = enemy_color_dropdown.selected
		
		# Assigned teams and perfectly synced colors
		if NetworkManager.my_network_team == 0: # HOST
			Global.board.player_team = Global.board.Team.BLUE
			Global.board.player_color_index = host_color
			Global.board.enemy_color_index = client_color
			Global.board.player_goes_first = check_first_turn.button_pressed
			Global.board.camera_angle = 0
		else: # CLIENT
			Global.board.player_team = Global.board.Team.RED
			Global.board.player_color_index = client_color
			Global.board.enemy_color_index = host_color
			Global.board.player_goes_first = check_first_turn.button_pressed 
			Global.board.camera_angle = 2
		
		if Global.board.board_textures.size() > board_style_dropdown.selected:
			Global.board.board_image.texture = Global.board.board_textures[board_style_dropdown.selected]
		
		var times = [60.0, 180.0, 300.0, 600.0, -1.0]
		Global.board.starting_time = times[time_dropdown.selected]
		
		setup_menu.hide()
		play_loading_screen(func(): Global.board.start_game(mode))
	)
	
	NetworkManager.move_received.connect(func(start_pos, target_pos):
		var piece = Global.board.board_state.get(start_pos)
		if piece != null: Global.board.execute_move(piece, start_pos, target_pos)
	)
	
	NetworkManager.surrender_received.connect(func(loser_team):
		Global.board.surrender(loser_team)
	)
	
	# MAP & CAMPAIGN WIRING
	btn_continue.pressed.connect(_on_dialogue_next_pressed)
	btn_continue_narrate.pressed.connect(_on_dialogue_next_pressed) 
	btn_close_map.pressed.connect(func(): start_menu.show(); map_menu.hide())
	btn_cinematic_continue.pressed.connect(_on_cinematic_continue_pressed)
	
	if btn_skip != null: btn_skip.pressed.connect(_on_dialogue_skip_pressed)
	
	# Page Navigation
	btn_next_act.pressed.connect(func():
		if current_act < max_acts:
			current_act += 1
			update_map_page()
	)
	btn_prev_act.pressed.connect(func():
		if current_act > 1:
			current_act -= 1
			update_map_page()
	)
	
	for i in range(3):
		map_nodes[i].pressed.connect(_on_map_node_pressed.bind(i))
	map_path.draw.connect(_draw_map_lines)
	
	# IN-GAME UI WIRING
	var restart_btn = $GameOverMenu/RestartBtn
	restart_btn.pressed.connect(func(): 
		if NetworkManager.is_lan_match:
			i_am_ready_for_rematch = true
			restart_btn.text = "Waiting for Player..."
			return_btn.disabled = true
			NetworkManager.send_rematch_ready()
			check_rematch_state()
			return
		
		Global.ui.game_over_menu.hide()
		if play_story and CampaignData.data.has(Global.board.playing_campaign_level):
			var type = CampaignData.data[Global.board.playing_campaign_level]["type"]
			if type == "puzzle":
				play_loading_screen(func(): PuzzleManager.start_puzzle(Global.board))
				return
		
		play_loading_screen(func(): Global.board.start_game(Global.board.current_game_mode))
	)
	
	return_btn.pressed.connect(func():
		if NetworkManager.is_lan_match: NetworkManager.send_rematch_cancel()
		return_to_menu()
	)
	
	# Handle incoming Network signals for Rematches
	NetworkManager.rematch_ready.connect(func():
		enemy_ready_for_rematch = true
		check_rematch_state()
	)
	NetworkManager.rematch_canceled.connect(func():
		i_am_ready_for_rematch = false
		enemy_ready_for_rematch = false
		restart_btn.text = "Play Again"
		return_btn.disabled = false
		return_to_menu() # Force both players back to the menu!
	)
	
	pvp_toggle.toggled.connect(_on_pvp_toggled)
	btn_quit.pressed.connect(open_in_game_menu) 
	btn_resume.pressed.connect(close_in_game_menu)
	btn_menu_options.pressed.connect(func():
		Global.board.sfx_click.play()
		in_game_menu.hide()
		options_menu.show()
	)
	btn_menu_quit.pressed.connect(func():
		close_in_game_menu()
		quit_match()
	)
	
	$PromotionMenu/VBoxContainer/BtnQueen.pressed.connect(func(): promotion_selected.emit(8))
	$PromotionMenu/VBoxContainer/BtnRook.pressed.connect(func(): promotion_selected.emit(1)) 
	$PromotionMenu/VBoxContainer/BtnKnight.pressed.connect(func(): promotion_selected.emit(2)) 
	$PromotionMenu/VBoxContainer/BtnBishop.pressed.connect(func(): promotion_selected.emit(6)) 
	
	$DraftMenu/VBoxContainer/HBoxContainer/BtnPawn.pressed.connect(func(): draft_selected.emit(0))
	$DraftMenu/VBoxContainer/HBoxContainer/BtnRook.pressed.connect(func(): draft_selected.emit(1))
	$DraftMenu/VBoxContainer/HBoxContainer/BtnKnight.pressed.connect(func(): draft_selected.emit(2)) 
	$DraftMenu/VBoxContainer/HBoxContainer/BtnBishop.pressed.connect(func(): draft_selected.emit(6))
	$DraftMenu/VBoxContainer/HBoxContainer/BtnQueen.pressed.connect(func(): draft_selected.emit(8))
	$DraftMenu/VBoxContainer/BtnCancel.pressed.connect(func(): draft_selected.emit(-2)) 
	$DraftMenu/VBoxContainer/BtnStart.pressed.connect(func(): draft_selected.emit(-1)) 
	
	# SYSTEM INITIALIZATION
	mode_dropdown.item_selected.connect(_on_leaderboard_tab_changed)
	mode_dropdown.add_item("Standard Chess", Global.board.GameMode.STANDARD)
	mode_dropdown.add_item("Random Chess", Global.board.GameMode.RANDOM)
	mode_dropdown.add_item("Blind Chess", Global.board.GameMode.BLIND)
	mode_dropdown.add_item("Intergalactic & Psychic", Global.board.GameMode.INTER_PSYCHIC)
	mode_dropdown.add_item("Magic & Card", Global.board.GameMode.MAGIC_CARD)
	mode_dropdown.add_item("The Cataclysm", Global.board.GameMode.CATACLYSM)
	mode_dropdown.add_item("The Gridlock", Global.board.GameMode.GRIDLOCK)
	mode_dropdown.add_item("The Swarm (PvE)", Global.board.GameMode.SWARM)
	
	var tut = $TutorialMenu/ScrollContainer/VBoxContainer
	tut.get_node("BtnPawn").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 0))
	tut.get_node("BtnRook").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 1))
	tut.get_node("BtnKnight").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 2))
	tut.get_node("BtnBishop").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 6))
	tut.get_node("BtnQueen").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 8))
	tut.get_node("BtnKing").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 7))
	tut.get_node("BtnAirship").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 9))
	tut.get_node("BtnEsper").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 10))
	tut.get_node("BtnJoker").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 11))
	tut.get_node("BtnAssassin").pressed.connect(func(): Spawner.spawn_tutorial_piece(Global.board, 12))
	
	# Populate Setup Dropdowns
	var colors = ["White", "Black", "Red", "Blue", "Purple", "Green", "Cyan", "Gold"]
	for c in colors:
		player_color_dropdown.add_item(c)
		enemy_color_dropdown.add_item(c)
	enemy_color_dropdown.select(1)
	
	board_style_dropdown.add_item("Classic Tile")
	board_style_dropdown.add_item("Wood Tile")
	board_style_dropdown.add_item("Black Tile")
	board_style_dropdown.add_item("Grey Tile")
	
	slider_music.value_changed.connect(func(val): _set_bus_volume("Music", val))
	slider_sfx.value_changed.connect(func(val): _set_bus_volume("SFX", val))
	check_shake.toggled.connect(func(pressed): VFXManager.enable_screen_shake = pressed)
	
	btn_wipe_save.pressed.connect(func():
		SaveManager.wipe_save()
		action_log.text = "[color=#ff0000]SAVE DATA ERASED![/color]\n"
		options_menu.hide()
		start_menu.show()
	)
	
	time_dropdown.add_item("1 Minute (Bullet)")
	time_dropdown.add_item("3 Minutes (Blitz)")
	time_dropdown.add_item("5 Minutes (Standard)")
	time_dropdown.add_item("10 Minutes (Rapid)")
	time_dropdown.add_item("Infinite (No Timer)")
	time_dropdown.select(2) 
	
	# Cancel Setup
	if btn_cancel_setup:
		btn_cancel_setup.pressed.connect(func():
			Global.board.sfx_click.play()
			if NetworkManager.is_lan_match:
				# Tell the other player we canceled, which will hide the menus for both of us!
				NetworkManager.send_cancel_setup()
			else: # Local play: Just hide the menu and go back
				setup_menu.hide()
				game_modes_menu.show()
		)
	
	btn_start_match.pressed.connect(func():
		if NetworkManager.is_lan_match:
			var match_seed = randi()
			var h_color = player_color_dropdown.selected
			var c_color = enemy_color_dropdown.selected
			NetworkManager.send_start_game(Global.board.current_game_mode, match_seed, h_color, c_color)
		else:
			Global.board.player_team = Global.board.Team.BLUE # Reset to Blue for Local/AI play
			Global.board.player_color_index = player_color_dropdown.selected
			Global.board.enemy_color_index = enemy_color_dropdown.selected
			Global.board.player_goes_first = check_first_turn.button_pressed
			
			Global.board.camera_angle = 0
			if Global.board.board_textures.size() > board_style_dropdown.selected:
				Global.board.board_image.texture = Global.board.board_textures[board_style_dropdown.selected]
			
			var times = [60.0, 180.0, 300.0, 600.0, -1.0]
			Global.board.starting_time = times[time_dropdown.selected]
			
			setup_menu.hide()
			play_loading_screen(func(): Global.board.start_game(Global.board.current_game_mode))
	)
	
	# SETUP START MENU PARTICLES
	if menu_particles != null:
		if menu_particle_texture != null:
			menu_particles.texture = menu_particle_texture
			
			# THE MAGIC SPRITE SHEET MATERIAL
			var mat = CanvasItemMaterial.new()
			mat.particles_animation = true
			mat.particles_anim_h_frames = 15 
			mat.particles_anim_v_frames = 8  
			mat.particles_anim_loop = false
			menu_particles.material = mat
			
			menu_particles.anim_speed_min = 0.0
			menu_particles.anim_speed_max = 0.0
			menu_particles.anim_offset_min = 0.0
			menu_particles.anim_offset_max = 1.0

		menu_particles.amount = menu_particle_amount
		menu_particles.color = Color(1, 1, 1, 1) 
		
		# RANDOM 360-DEGREE MOVEMENT
		menu_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		menu_particles.emission_rect_extents = Vector2(600, 350)
		menu_particles.position = Vector2(576, 324) 
		
		menu_particles.direction = Vector2(1, 0)
		menu_particles.spread = 180.0
		menu_particles.gravity = Vector2(0, 0) 
		menu_particles.initial_velocity_min = 15.0
		menu_particles.initial_velocity_max = 50.0
		
		# ADD SOME SPIN/TUMBLE
		menu_particles.angle_min = -180.0
		menu_particles.angle_max = 180.0
		menu_particles.angular_velocity_min = -25.0
		menu_particles.angular_velocity_max = 25.0
		
		menu_particles.lifetime = 10.0
		menu_particles.scale_amount_min = 0.5
		menu_particles.scale_amount_max = 1.5
		
		# FADE IN/OUT
		var fade_ramp = Gradient.new()
		fade_ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
		fade_ramp.colors = PackedColorArray([Color(1,1,1,0), Color(1,1,1,1), Color(1,1,1,1), Color(1,1,1,0)])
		menu_particles.color_ramp = fade_ramp
		
	# --- NEW: WHITE DOT PARTICLES FOR RECORDING SCREEN ---
	#var dot_particles = CPUParticles2D.new()
	#dot_particles.name = "Particles" # So the button can find it!
	#post_image.add_child(dot_particles)
	#
	#dot_particles.amount = 150
	#dot_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	#dot_particles.emission_rect_extents = Vector2(600, 350)
	#dot_particles.position = Vector2(576, 324) # Center of screen
	#
	#dot_particles.direction = Vector2(0, 0)
	#dot_particles.spread = 180.0
	#dot_particles.gravity = Vector2(0, 0) # Floating in zero-G
	#dot_particles.initial_velocity_min = 10.0
	#dot_particles.initial_velocity_max = 40.0
	#
	## Scale up the microscopic 1x1 default pixels so you can see them!
	#dot_particles.scale_amount_min = 2.0 
	#dot_particles.scale_amount_max = 5.0 
	#dot_particles.lifetime = 6.0
	#
	## Soft fade in and out
	#var dot_fade = Gradient.new()
	#dot_fade.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	#dot_fade.colors = PackedColorArray([Color(1,1,1,0), Color(1,1,1,0.8), Color(1,1,1,0)])
	#dot_particles.color_ramp = dot_fade
	# -----------------------------------------------------
	
	# HIDE ALL ON BOOT
	start_menu.show()
	game_modes_menu.hide() 
	map_menu.hide()
	story_menu.hide()
	action_log_panel.hide()
	game_over_menu.hide()
	promotion_menu.hide()
	credits_menu.hide()
	timers_ui.hide()
	btn_quit.hide()
	lan_menu.hide()
	tutorial_menu.hide()
	setup_menu.hide()
	btn_flip_board.hide()
	leaderboard_menu.hide()
	history_menu.hide()
	btn_undo.hide()
	btn_hint.hide()
	cinematic_screen.hide()
	Global.board.visible = false
	
	#post_image.hide()

func format_time(time_in_seconds: float) -> String:
	var minutes = int(time_in_seconds / 60.0) 
	var seconds = int(time_in_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func open_in_game_menu():
	Global.board.sfx_click.play()
	pause_overlay.show()
	in_game_menu.show()
	if not NetworkManager.is_lan_match: get_tree().paused = true

func close_in_game_menu():
	Global.board.sfx_click.play()
	pause_overlay.hide()
	in_game_menu.hide()
	get_tree().paused = false

func attach_button_sounds(node: Node, sfx_click: AudioStreamPlayer):
	for child in node.get_children():
		if child is BaseButton:
			child.pressed.connect(func(): sfx_click.play())
		attach_button_sounds(child, sfx_click)

func open_map():
	play_story = true
	Global.board.visible = false 
	start_menu.hide()
	story_menu.hide()
	game_over_menu.hide() 
	action_log_panel.hide() 
	promotion_menu.hide()
	map_menu.show()
	timers_ui.hide()
	draft_menu.hide()
	btn_flip_board.hide()
	btn_undo.hide()
	Global.board.in_draft_phase = false
	
	current_act = ceil(float(Global.board.highest_unlocked_level) / 3.0)
	if current_act > max_acts: current_act = max_acts
	if current_act < 1: current_act = 1
	
	update_map_page()
	map_menu.modulate.a = 0.0
	map_menu.show() 
	
	await get_tree().process_frame 
	await get_tree().process_frame 
	map_menu.modulate.a = 1.0 

func update_map_page():
	var bg_index = current_act - 1
	
	if map_backgrounds.size() > bg_index and map_backgrounds[bg_index] != null:
		map_bg.texture = map_backgrounds[bg_index]
	
	if map_titles.size() > bg_index and map_titles[bg_index] != null:
		act_title.texture = map_titles[bg_index]
	
	btn_prev_act.visible = (current_act > 1)
	btn_next_act.visible = (current_act < max_acts)
	
	if node_pulse_tween: node_pulse_tween.kill()
	
	# UPDATE BUTTON STATUS (COMPLETED vs CURRENT vs LOCKED)
	for i in range(3):
		var level_num = (current_act - 1) * 3 + (i + 1)
		var btn = map_nodes[i]
		var roman_numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII"]
		var lvl_name = roman_numerals[level_num - 1] if level_num <= 18 else str(level_num)
		
		if act_node_positions.has(current_act):
			btn.position = act_node_positions[current_act][i]
		
		btn.add_theme_color_override("font_color", Color("#111111"))
		btn.add_theme_color_override("font_outline_color", Color("#ffffff"))
		btn.add_theme_constant_override("outline_size", 4)
		
		btn.pivot_offset = btn.size / 2 
		btn.scale = Vector2(1.0, 1.0)
		
		if level_num < Global.board.highest_unlocked_level:
			# LEVEL COMPLETED!
			btn.disabled = false
			btn.icon = tile_completed
			btn.modulate = Color(1, 1, 1) 
			btn.text = lvl_name
		elif level_num == Global.board.highest_unlocked_level:
			# CURRENT LEVEL!
			btn.disabled = false
			btn.icon = tile_current
			btn.modulate = Color(1, 1, 1)
			btn.text = lvl_name
			
			node_pulse_tween = create_tween().set_loops()
			node_pulse_tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.8).set_trans(Tween.TRANS_SINE)
			node_pulse_tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
		else:
			# LOCKED LEVEL!
			btn.disabled = true
			btn.icon = tile_locked
			btn.modulate = Color(1, 1, 1) 
			btn.text = lvl_name
	
	map_path.queue_redraw()
	
	# POSITION AND ANIMATE THE PLAYER MARKER
	player_marker.hide() 
	
	var min_lvl_on_page = (current_act - 1) * 3 + 1
	var max_lvl_on_page = current_act * 3
	
	if Global.board.highest_unlocked_level >= min_lvl_on_page and Global.board.highest_unlocked_level <= max_lvl_on_page:
		var target_btn_idx = (Global.board.highest_unlocked_level - 1) % 3
		var target_btn = map_nodes[target_btn_idx]
		
		player_marker.show()
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		var target_pos = target_btn.get_global_rect().get_center() - map_menu.global_position
		target_pos.y -= 15 
		
		player_marker.position = target_pos
		player_marker.find_child("AnimationPlayer").play("hopping")
	
	apply_map_particles(current_act)
	apply_map_disasters(current_act)

func _on_map_node_pressed(index: int):
	var level_num = (current_act - 1) * 3 + (index + 1)
	launch_campaign_level(level_num)

func _draw_map_lines():
	if Global.board.level_buttons.size() < 2: return
	if Global.board.level_buttons[0].global_position == Vector2.ZERO: return
	
	for i in range(2): 
		var btn1 = map_nodes[i]
		var btn2 = map_nodes[i + 1]
		var next_level_num = (current_act - 1) * 3 + (i + 2)
		
		var pos1 = btn1.get_global_rect().get_center() - map_path.global_position
		var pos2 = btn2.get_global_rect().get_center() - map_path.global_position
		
		var line_color = Color(1.0, 1.0, 1.0, 0.3) 
		if next_level_num <= Global.board.highest_unlocked_level:
			line_color = Color("#00ffff")
		
		var mid_x = (pos1.x + pos2.x) / 2.0 + (pos2.y - pos1.y)
		var mid_y = 0.5 * (mid_x - pos1.x) + pos1.y
		var mid_pos = Vector2(mid_x, mid_y)
		
		map_path.draw_line(pos1, mid_pos, line_color, 8.0)
		map_path.draw_line(mid_pos, pos2, line_color, 8.0)

func apply_map_particles(act_num: int):
	map_particles.emitting = false 
	
	if secondary_particles != null:
		secondary_particles.queue_free()
		secondary_particles = null
	
	map_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	map_particles.emission_rect_extents = Vector2(576, 324)
	map_particles.position = Vector2(576, 324) 
	map_particles.direction = Vector2(0, 0)
	map_particles.gravity = Vector2(0, 0)
	map_particles.initial_velocity_min = 0.0
	map_particles.initial_velocity_max = 0.0
	map_particles.scale_amount_min = 1.0
	map_particles.scale_amount_max = 3.0
	map_particles.lifetime = 4.0
	
	map_particles.color_initial_ramp = null
	map_particles.color_ramp = null 
	
	if act_num == 1:
		map_particles.amount = 150
		map_particles.gravity = Vector2(0, 20)
		
		var grad = Gradient.new()
		grad.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT 
		grad.offsets = PackedFloat32Array([0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875])
		grad.colors = PackedColorArray([
			Color("#ffffff"), # White
			Color("#42454f"), # Black
			Color("#ff6666"), # Red
			Color("#66aaff"), # Blue
			Color("#cc66ff"), # Purple
			Color("#55ff55"), # Green
			Color("#66ffff"), # Cyan
			Color("#ffd700")  # Gold
		])
		
		map_particles.color = Color(1.0, 1.0, 1.0, 1.0) 
		map_particles.color_initial_ramp = grad
		
	elif act_num == 2:
		map_particles.amount = 400
		map_particles.position = Vector2(576, -50) 
		map_particles.emission_rect_extents = Vector2(600, 10) 
		map_particles.direction = Vector2(0.2, 1.0) 
		map_particles.gravity = Vector2(0, 600)
		map_particles.initial_velocity_min = 100.0
		map_particles.initial_velocity_max = 300.0
		map_particles.color = Color(0.4, 0.6, 1.0, 0.6)
		
	elif act_num == 3:
		map_particles.amount = 250
		map_particles.direction = Vector2(0, 0)
		map_particles.gravity = Vector2(0, 0) 
		map_particles.initial_velocity_min = 0.0
		map_particles.initial_velocity_max = 0.0
		map_particles.scale_amount_min = 1.0
		map_particles.scale_amount_max = 6.5 
		map_particles.lifetime = 5 
		
		var star_colors = Gradient.new()
		star_colors.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT 
		star_colors.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 0.9])
		star_colors.colors = PackedColorArray([
			Color("#ffffff"), # White
			Color("#42454f"), # Black
			Color("#ff6666"), # Red
			Color("#66aaff"), # Blue
			Color("#cc66ff"), # Purple
			Color("#55ff55"), # Green
			Color("#66ffff"), # Cyan
			Color("#ffd700")  # Gold
		])
		map_particles.color_initial_ramp = star_colors
		
		var twinkle_grad = Gradient.new()
		twinkle_grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		twinkle_grad.colors = PackedColorArray([
			Color(1.0, 1.0, 1.0, 0.0), # Start Invisible
			Color(1.0, 1.0, 1.0, 0.9), # Fade to Bright
			Color(1.0, 1.0, 1.0, 0.0)  # Fade back to Invisible
		])
		map_particles.color_ramp = twinkle_grad
		
	elif act_num == 4:
		map_particles.amount = 250
		map_particles.position = Vector2(576, 700) 
		map_particles.emission_rect_extents = Vector2(600, 20)
		map_particles.direction = Vector2(0, -1.0) 
		map_particles.gravity = Vector2(0, -100) 
		map_particles.initial_velocity_min = 30.0
		map_particles.initial_velocity_max = 100.0
		map_particles.color = Color(1.0, 0.4, 0.0, 0.8) 
		
	elif act_num == 5:
		map_particles.amount = 80
		map_particles.color = Color(0.05, 0.05, 0.05, 0.8) 
		map_particles.scale_amount_min = 4.0  
		map_particles.scale_amount_max = 12.0 
		map_particles.gravity = Vector2(10, 5) 
		map_particles.lifetime = 10.0
		
		secondary_particles = CPUParticles2D.new()
		secondary_particles.texture = load("res://Assets/Sprites/Tile_White.png")
		secondary_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		secondary_particles.emission_rect_extents = Vector2(576, 324)
		secondary_particles.position = Vector2(576, 324)
		secondary_particles.direction = Vector2(0, 0)
		secondary_particles.gravity = Vector2(0, 0) 
		secondary_particles.amount = 3 
		secondary_particles.lifetime = 6.0 
		secondary_particles.scale_amount_min = 1.0
		secondary_particles.scale_amount_max = 2.0
		
		var lone_star_grad = Gradient.new()
		lone_star_grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		lone_star_grad.colors = PackedColorArray([Color(1.0, 0.9, 0.6, 0.0), Color(1.0, 0.9, 0.6, 1.0), Color(1.0, 0.9, 0.6, 0.0)])
		secondary_particles.color_ramp = lone_star_grad
		
		map_menu.add_child(secondary_particles)
		map_menu.move_child(secondary_particles, map_bg.get_index() + 1)
		
	elif act_num == 6:
		map_particles.amount = 100
		map_particles.color = Color(1.0, 1.0, 1.0, 0.2)
		map_particles.gravity = Vector2(0, 5)
	
	map_particles.restart()

func apply_map_disasters(act_num: int):
	for d in map_disaster_sprites:
		if is_instance_valid(d): d.queue_free()
	map_disaster_sprites.clear()
	
	if act_num != 4: return 
	
	for d in map_disaster_sprites:
		if is_instance_valid(d): d.queue_free()
	map_disaster_sprites.clear()
	
	Spawner.spawn_map_disaster("lava", Vector2(306, 306))
	Spawner.spawn_map_disaster("lava", Vector2(578, 486))
	Spawner.spawn_map_disaster("lava", Vector2(782, 270))
	Spawner.spawn_map_disaster("lava", Vector2(1055, 486))
	Spawner.spawn_map_disaster("lava", Vector2(714, 594))
	Spawner.spawn_map_disaster("earthquake", Vector2(782, 306))
	Spawner.spawn_map_disaster("earthquake", Vector2(510, 522))
	Spawner.spawn_map_disaster("earthquake", Vector2(306, 414))
	Spawner.spawn_map_disaster("earthquake", Vector2(578, 378))
	Spawner.spawn_map_disaster("earthquake", Vector2(578, 234))
	Spawner.spawn_map_disaster("flood", Vector2(578, 630))
	Spawner.spawn_map_disaster("flood", Vector2(170, 414))
	Spawner.spawn_map_disaster("flood", Vector2(442, 198))
	Spawner.spawn_map_disaster("flood", Vector2(850, 162))
	Spawner.spawn_map_disaster("flood", Vector2(986, 378))
	Spawner.spawn_map_disaster("typhoon", Vector2(442, 558))
	Spawner.spawn_map_disaster("typhoon", Vector2(34, 234))
	Spawner.spawn_map_disaster("typhoon", Vector2(646, 126))
	Spawner.spawn_map_disaster("typhoon", Vector2(918, 270))
	Spawner.spawn_map_disaster("typhoon", Vector2(374, 234))

func open_setup(mode):
	play_story = false
	Global.board.current_game_mode = mode
	Global.board.game_over = true 
	Global.board.visible = false
	action_log_panel.hide()
	timers_ui.hide()
	btn_quit.hide()
	btn_flip_board.hide()
	game_modes_menu.hide()
	btn_undo.hide()
	start_menu.hide()
	setup_menu.show()
	
	if NetworkManager.is_lan_match and NetworkManager.my_network_team == 0:
		NetworkManager.send_open_setup(mode)
	
	var enemy_label = setup_menu.get_node_or_null("EnemyColorLabel")
	if NetworkManager.is_lan_match:
		enemy_color_dropdown.hide()
		if enemy_label: enemy_label.hide()
		
		if NetworkManager.my_network_team == 1: # CLIENT
			check_first_turn.disabled = true
			time_dropdown.disabled = true
			btn_start_match.text = "Waiting for Host..."
			btn_start_match.disabled = true
		else: # HOST
			check_first_turn.disabled = false
			time_dropdown.disabled = false
			btn_start_match.text = "Start Match"
			btn_start_match.disabled = false
		
		# Sync Lobby Choices Live!
		if not player_color_dropdown.item_selected.is_connected(NetworkManager.send_color_update):
			player_color_dropdown.item_selected.connect(NetworkManager.send_color_update)
		if not time_dropdown.item_selected.is_connected(NetworkManager.send_setting_update):
			time_dropdown.item_selected.connect(NetworkManager.send_setting_update)
		if not check_first_turn.toggled.is_connected(NetworkManager.send_first_turn_update):
			check_first_turn.toggled.connect(NetworkManager.send_first_turn_update)
			
	else: # LOCAL MATCH
		enemy_color_dropdown.show()
		if enemy_label: enemy_label.show()
		check_first_turn.disabled = false
		time_dropdown.disabled = false
		btn_start_match.text = "Start Game"
		btn_start_match.disabled = false
		
		# Disconnect network signals so Local Play doesn't crash
		if player_color_dropdown.item_selected.is_connected(NetworkManager.send_color_update):
			player_color_dropdown.item_selected.disconnect(NetworkManager.send_color_update)
		if time_dropdown.item_selected.is_connected(NetworkManager.send_setting_update):
			time_dropdown.item_selected.disconnect(NetworkManager.send_setting_update)
		if check_first_turn.toggled.is_connected(NetworkManager.send_first_turn_update):
			check_first_turn.toggled.disconnect(NetworkManager.send_first_turn_update)

func launch_campaign_level(level_num):
	map_menu.hide()
	action_log_panel.hide()
	Global.board.visible = false
	Global.board.playing_campaign_level = level_num
	story_menu.show()
	play_story_dialogue()

func play_story_dialogue():
	if CampaignData.data.has(Global.board.playing_campaign_level):
		current_dialogue_pages = CampaignData.data[Global.board.playing_campaign_level]["dialogue"]
	else:
		current_dialogue_pages = [{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#00ff00]LEVEL UNKNOWN.[/color]"}]
	
	current_page_idx = 0
	show_dialogue_page()

func show_dialogue_page():
	btn_continue.hide()
	btn_continue_narrate.hide()
	is_typing = true
	var page = current_dialogue_pages[current_page_idx]
	
	var active_text_node = null
	var active_btn_node = null
	
	# --- THE STYLE (NARRATION VS DIALOG) ---
	if page["team"] == -1:
		# NARRATION STYLE
		dialog_box.hide()
		narration_text.show()
		
		active_text_node = narration_text
		active_btn_node = btn_continue_narrate
		background_sprite.hide() 
		
	else:
		# DIALOG BOX STYLE
		narration_text.hide()
		dialog_box.show()
		
		active_text_node = dialog_text
		active_btn_node = btn_continue
		
		name_label.text = page["name"]
		character_sprite.show()
		character_sprite.frame = page["type"] + (page["team"] * 13)
		
		if page["team"] == 0: 
			character_sprite.flip_h = false
			name_label.modulate = Color(0.2, 0.8, 1.0) 
		else: 
			character_sprite.flip_h = true 
			name_label.modulate = Color(1.0, 0.2, 0.2)
	
	# --- TYPEWRITER EFFECT ---
	active_text_node.text = ""
	active_text_node.append_text(page["text"])
	active_text_node.visible_characters = 0
	
	for i in range(page["text"].length()):
		if not is_typing: break 
		active_text_node.visible_characters += 1
		
		# Sound Effects
		if i % 2 == 0:
			if page["team"] == -1: Global.board.sfx_click.pitch_scale = 1.0 
			else: Global.board.sfx_click.pitch_scale = 0.7 if page["team"] == 1 else 1.3
			Global.board.sfx_click.play()
		
		await get_tree().create_timer(0.02).timeout 
	
	active_text_node.visible_characters = -1
	is_typing = false
	
	if current_page_idx < current_dialogue_pages.size() - 1:  active_btn_node.text = "Next"
	else: active_btn_node.text = "Seek"
	
	active_btn_node.show()

func _on_dialogue_next_pressed():
	if is_typing:
		is_typing = false
	else:
		if current_page_idx < current_dialogue_pages.size() - 1:
			current_page_idx += 1
			show_dialogue_page()
		else:
			story_menu.hide()
			Global.board.sfx_click.pitch_scale = 1.0 
			
			var mode = Global.board.GameMode.STANDARD
			var type = "battle"
			
			if CampaignData.data.has(Global.board.playing_campaign_level):
				mode = CampaignData.data[Global.board.playing_campaign_level]["mode"]
				type = CampaignData.data[Global.board.playing_campaign_level]["type"]
			
			Global.board.current_game_mode = mode
			
			if Global.board.playing_campaign_level == 18:
				play_cinematic(ending_image, func():
					if type == "puzzle": play_loading_screen(func(): PuzzleManager.start_puzzle(Global.board))
					else: play_loading_screen(func(): Global.board.start_game(mode))
				)
			
			else:
				if type == "puzzle": play_loading_screen(func(): PuzzleManager.start_puzzle(Global.board))
				else: play_loading_screen(func(): Global.board.start_game(mode))

func _on_dialogue_skip_pressed():
	story_menu.hide()
	Global.board.sfx_click.pitch_scale = 1.0 
	Global.board.sfx_click.play() 
	
	var mode = Global.board.GameMode.STANDARD
	var type = "battle"
	
	if CampaignData.data.has(Global.board.playing_campaign_level):
		mode = CampaignData.data[Global.board.playing_campaign_level]["mode"]
		type = CampaignData.data[Global.board.playing_campaign_level]["type"]
	
	Global.board.current_game_mode = mode
	
	if type == "puzzle": play_loading_screen(func(): PuzzleManager.start_puzzle(Global.board))
	else: play_loading_screen(func(): Global.board.start_game(mode))

func quit_match():
	if NetworkManager.is_lan_match: NetworkManager.send_surrender()
	else: Global.board.surrender(Global.board.player_team)

func return_to_menu():
	game_over_menu.hide()
	action_log_panel.hide()
	timers_ui.hide()
	tutorial_menu.hide()
	btn_flip_board.hide()
	btn_undo.hide()
	Global.board.visible = false
	
	Global.board.cleanup_board()
	
	if play_story: open_map()
	else: game_modes_menu.show()

func open_leaderboards():
	game_modes_menu.hide()
	leaderboard_menu.show()
	mode_dropdown.select(0) 
	_on_leaderboard_tab_changed(0)

func _on_leaderboard_tab_changed(index: int):
	var selected_mode_str = str(mode_dropdown.get_item_id(index))
	var text = "[center][b]--- HIGH SCORES ---[/b][/center]\n\n"
	
	if selected_mode_str == str(Global.board.GameMode.SWARM):
		text += "[center]Best Survival Record:\n[color=#ffaa00]" + str(SaveManager.player_stats["best_swarm_turns"]) + " Turns[/color][/center]"
	else:
		if SaveManager.player_stats["fastest_modes"].has(selected_mode_str) and SaveManager.player_stats["fastest_modes"][selected_mode_str].size() > 0:
			var times = SaveManager.player_stats["fastest_modes"][selected_mode_str]
			for i in range(times.size()):
				var rank = str(i + 1)
				var color = "#ffd700" if i == 0 else "#aaaaaa" 
				text += "[color=" + color + "]" + rank + ". " + format_time(times[i]) + "[/color]\n"
		else:
			text += "[center][color=#aaaaaa]No records yet.\nBe the first to clear this mode![/color][/center]"
	leaderboard_text.text = text

func open_match_history():
	game_modes_menu.hide()
	history_menu.show()
	
	var text = "[center][b]--- MATCH HISTORY ---[/b][/center]\n\n"
	
	if SaveManager.player_stats["match_history"].size() == 0:
		text += "[center][color=#aaaaaa]No matches played yet.[/color][/center]"
	else:
		for match in SaveManager.player_stats["match_history"]:
			var res_color = "#55ff55" if match["result"] == "Win" else ("#ffff55" if match["result"] == "Draw" else "#ff5555")
			text += "[b]" + match["date"] + " | " + match["mode"] + "[/b]\n"
			text += "Result: [color=" + res_color + "]" + match["result"] + "[/color] | "
			text += "Duration: " + format_time(match["time"]) + "\n\n"
	
	history_text.text = text

func _on_pvp_toggled(button_pressed: bool):
	Global.board.is_pvp = button_pressed
	if pvp_toggle:
		if Global.board.is_pvp: 
			pvp_toggle.text = "Mode: Connecting PVP LAN..."
			game_modes_menu.hide() 
			lan_menu.show()
			
			# Clear old hosts and Start Listening
			var host_list = lan_menu.get_node_or_null("HostList")
			if host_list:
				for child in host_list.get_children():
					child.queue_free()
			NetworkManager.start_listening()
		else: 
			cancel_lan_setup()

func cancel_lan_setup():
	lan_menu.hide()
	game_modes_menu.show()
	Global.board.is_pvp = false
	NetworkManager.cancel_connection() 
	
	if pvp_toggle:
		pvp_toggle.set_pressed_no_signal(false) 
		pvp_toggle.text = "Mode: Currently on Player vs AI"
	var scroll = game_modes_menu.find_child("ScrollContainer", true, false)
	if scroll: scroll.show()

func _set_bus_volume(bus_name: String, value: float):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	var volume_percent = float(value) / 100.0 
	var db = linear_to_db(volume_percent)
	AudioServer.set_bus_volume_db(bus_idx, db)
	AudioServer.set_bus_mute(bus_idx, value <= 0)

func play_loading_screen(start_function: Callable):
	start_menu.hide()
	story_menu.hide()
	setup_menu.hide()
	loading_screen.show()
	
	lore_tips.shuffle()
	
	loading_bar.value = 0
	var tween = create_tween()
	tween.tween_property(loading_bar, "value", 100.0, 5.0)
	
	for i in range(1):
		advice_text.text = lore_tips.pick_random()
		await get_tree().create_timer(5).timeout 
	
	loading_screen.hide()
	start_function.call()

func play_cinematic(tex: Texture2D, next_action: Callable):
	if tex == null:
		next_action.call()
		return
	
	cinematic_image.texture = tex
	on_cinematic_finished = next_action
	
	start_menu.hide()
	map_menu.hide()
	game_over_menu.hide()
	
	cinematic_screen.modulate.a = 0.0 
	cinematic_screen.show()
	
	var tween = create_tween()
	tween.tween_property(cinematic_screen, "modulate:a", 1.0, 1.5)

func _on_cinematic_continue_pressed():
	Global.board.sfx_click.play()
	btn_cinematic_continue.disabled = true
	
	var tween = create_tween()
	tween.tween_property(cinematic_screen, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	cinematic_screen.hide()
	btn_cinematic_continue.disabled = false
	
	if on_cinematic_finished:
		on_cinematic_finished.call()
		on_cinematic_finished = null

func check_rematch_state():
	if i_am_ready_for_rematch and enemy_ready_for_rematch:
		i_am_ready_for_rematch = false
		enemy_ready_for_rematch = false
		$GameOverMenu/RestartBtn.text = "Play Again"
		return_btn.disabled = false
		game_over_menu.hide()
		
		# Host triggers the actual restart for both computers!
		if NetworkManager.my_network_team == 0: 
			var match_seed = randi()
			var h_color = player_color_dropdown.selected
			var c_color = enemy_color_dropdown.selected
			NetworkManager.send_start_game(Global.board.current_game_mode, match_seed, h_color, c_color)
