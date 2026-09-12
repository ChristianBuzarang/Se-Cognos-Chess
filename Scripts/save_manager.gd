extends Node

var save_path = "user://omnichess_save.json"

var player_stats = {
	"best_swarm_turns": 0,
	"fastest_modes": {},
	"match_history": []
}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(player_stats))

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var text = file.get_as_text()
		
		if text.strip_edges() == "": return
		
		var data = JSON.parse_string(text)
		if data != null:
			if data.has("best_swarm_turns"): player_stats["best_swarm_turns"] = data["best_swarm_turns"]
			if data.has("match_history"): player_stats["match_history"] = data["match_history"]
			if data.has("fastest_modes"): 
				for k in data["fastest_modes"].keys():
					if typeof(data["fastest_modes"][k]) == TYPE_FLOAT:
						data["fastest_modes"][k] = [data["fastest_modes"][k]]
				player_stats["fastest_modes"] = data["fastest_modes"]

func record_match(mode_name: String, result: String, time_in_seconds: float):
	var date_str = Time.get_date_string_from_system()
	var match_data = {
		"mode": mode_name,
		"result": result,
		"time": time_in_seconds,
		"date": date_str
	}
	
	player_stats["match_history"].push_front(match_data)
	if player_stats["match_history"].size() > 50:
		player_stats["match_history"].pop_back()
	save_game()

func wipe_save():
	player_stats = {
		"best_swarm_turns": 0,
		"fastest_modes": {},
		"match_history": []
	}
	Global.board.highest_unlocked_level = 1
	save_game()
