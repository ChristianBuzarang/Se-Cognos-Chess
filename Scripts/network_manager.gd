extends Node

signal player_joined
signal start_game_requested(mode, match_seed, host_color, client_color)
signal move_received(start_pos, target_pos)
signal surrender_received(loser_team)
signal rematch_ready
signal rematch_canceled
signal host_discovered(ip, host_name)

var is_lan_match: bool = false
var my_network_team: int = 0 
var multiplayer_peer = ENetMultiplayerPeer.new()
const PORT = 8910

# UDP Broadcast Variables
var udp_peer = PacketPeerUDP.new()
var broadcast_port = 8911
var broadcast_timer = 0.0
var is_broadcasting = false
var is_listening = false
var my_host_name = "Player"


func _process(delta):
	# The HOST shouts its name to the entire WiFI network every seconds
	if is_broadcasting:
		broadcast_timer -= delta
		if broadcast_timer <= 0:
			broadcast_timer = 1.0
			udp_peer.set_dest_address("255.255.255.255", broadcast_port)
	
	# The CLIENT listens for anyone shouting on the WiFi
	if is_listening and udp_peer.get_available_packet_count() > 0:
		var ip = udp_peer.get_packet_ip()
		var packet = udp_peer.get_packet().get_string_from_utf8()
		if packet.begins_with("SE_COGNOS_CHESS|"):
			var h_name = packet.split("|")[1]
			host_discovered.emit(ip, h_name)

func host_game(host_name: String = "Host"):
	multiplayer_peer = ENetMultiplayerPeer.new() 
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
		
	is_lan_match = true
	my_network_team = 0
	
	# Starts broadcasting
	my_host_name = host_name
	is_broadcasting = true
	udp_peer = PacketPeerUDP.new()
	udp_peer.set_broadcast_enabled(true)

func join_game(ip: String):
	if ip == "": ip = "127.0.0.1" 
	
	multiplayer_peer = ENetMultiplayerPeer.new() 
	multiplayer_peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	is_lan_match = true
	my_network_team = 1
	stop_listening()


func cancel_connection():
	is_lan_match = false
	multiplayer.multiplayer_peer = null 
	if multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.disconnect(_on_peer_connected)
	is_broadcasting = false
	stop_listening()

func start_listening():
	is_listening = true
	udp_peer = PacketPeerUDP.new()
	udp_peer.bind(broadcast_port)

func stop_listening():
	is_listening = false
	if udp_peer: udp_peer.close()

func _on_peer_connected(_id):
	is_broadcasting = false
	if udp_peer: udp_peer.close()
	player_joined.emit()

func get_local_ip() -> String:
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.168.") or ip.begins_with("10.") or (ip.begins_with("172.") and not ip.contains(":")):
			return ip
	return "127.0.0.1"

# --- SENDING & RECEIVING DATA ---
func send_start_game(mode: int, match_seed: int, host_color: int, client_color: int):
	rpc("sync_start_game", mode, match_seed, host_color, client_color)

@rpc("authority", "call_local")
func sync_start_game(mode: int, match_seed: int, host_color: int, client_color: int):
	start_game_requested.emit(mode, match_seed, host_color, client_color)

func send_move(start_pos: Vector2i, target_pos: Vector2i):
	rpc("sync_execute_move", start_pos, target_pos)

@rpc("any_peer", "call_local")
func sync_execute_move(start_pos: Vector2i, target_pos: Vector2i):
	move_received.emit(start_pos, target_pos)

func send_surrender():
	rpc("sync_surrender", my_network_team)

@rpc("any_peer", "call_local")
func sync_surrender(loser_team: int):
	surrender_received.emit(loser_team)

# --- SETUP MENU SYNCING ---
func send_color_update(color_idx: int):
	rpc("sync_color_update", my_network_team, color_idx)

@rpc("any_peer", "call_local")
func sync_color_update(team: int, color_idx: int):
	# If the OTHER player changed their color, save it to our hidden Enemy slot!
	if team != my_network_team and Global.ui != null:
		Global.ui.enemy_color_dropdown.select(color_idx)

func send_setting_update(time_idx: int):
	rpc("sync_setting_update", time_idx)

@rpc("authority", "call_local")
func sync_setting_update(time_idx: int):
	if Global.ui != null: Global.ui.time_dropdown.select(time_idx)

func send_first_turn_update(goes_first: bool):
	rpc("sync_first_turn_update", goes_first)

@rpc("authority", "call_local")
func sync_first_turn_update(goes_first: bool):
	if Global.ui != null: Global.ui.check_first_turn.set_pressed_no_signal(goes_first)

func send_open_setup(mode: int):
	rpc("sync_open_setup", mode)

@rpc("authority", "call_remote")
func sync_open_setup(mode: int):
	if Global.ui != null: Global.ui.open_setup(mode)

func send_cancel_setup():
	rpc("sync_cancel_setup")

@rpc("any_peer", "call_local")
func sync_cancel_setup():
	if Global.ui != null:
		Global.ui.setup_menu.hide()
		Global.ui.game_modes_menu.show()
		cancel_connection()
		
		# Reset the PvP toggle text
		if Global.ui.pvp_toggle: 
			Global.ui.pvp_toggle.set_pressed_no_signal(false)
			Global.ui.pvp_toggle.text = "Mode: Currently on Player vs AI"

func send_rematch_ready():
	rpc("sync_rematch_ready")

@rpc("any_peer", "call_local")

func sync_rematch_ready():
	rematch_ready.emit()

func send_rematch_cancel(): 
	rpc("sync_rematch_calcel")
	
@rpc("any_peer", "call_local")
func sync_rematch_calcel():
	rematch_canceled.emit()
