extends Node

# --- TRANSLATORS ---
func get_chess_notation(pos: Vector2i) -> String:
	var file = String.chr(97 + pos.x) 
	var rank = str(8 - pos.y) 
	return file + rank

func get_piece_name(type_id: int) -> String:
	var names = {
		0: "Pawn", 1: "Rook", 2: "Knight", 3: "Knight", 4: "Knight", 5: "Knight", 6: "Bishop",
		7: "King", 8: "Queen", 9: "Airship", 10: "Esper", 11: "Joker", 12: "Assassin"
	}
	return names.get(type_id, "Piece")

# --- MATH HELPERS ---
func get_visual_pos(board, grid_pos: Vector2i) -> Vector2:
	if board.camera_angle == 1:
		return board.map_to_local(Vector2i(grid_pos.y, 7 - grid_pos.x))
	elif board.camera_angle == 2:
		return board.map_to_local(Vector2i(7 - grid_pos.x, 7 - grid_pos.y))
	elif board.camera_angle == 3:
		return board.map_to_local(Vector2i(7 - grid_pos.y, grid_pos.x))
	return board.map_to_local(grid_pos)

func get_logical_pos(board, clicked_pixel: Vector2) -> Vector2i:
	var grid_pos = board.local_to_map(clicked_pixel)
	if board.camera_angle == 1:
		return Vector2i(7 - grid_pos.y, grid_pos.x)
	elif board.camera_angle == 2:
		return Vector2i(7 - grid_pos.x, 7 - grid_pos.y)
	elif board.camera_angle == 3:
		return Vector2i(grid_pos.y, 7 - grid_pos.x)
	return grid_pos

# --- DYNAMIC COLOR HELPERS ---
func get_team_color_name(board, team) -> String:
	var c_index = board.player_color_index if team == board.player_team else board.enemy_color_index
	var colors_list = ["White", "Black", "Red", "Blue", "Purple", "Green", "Cyan", "Gold"]
	return colors_list[c_index]

func get_team_hex(board, team) -> String:
	var c_index = board.player_color_index if team == board.player_team else board.enemy_color_index
	var hexes = ["#ffffff", "#888888", "#ff6666", "#66aaff", "#cc66ff", "#55ff55", "#66ffff", "#ffd700"]
	return hexes[c_index]
