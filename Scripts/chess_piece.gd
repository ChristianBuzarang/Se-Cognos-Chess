extends Sprite2D

enum Team { BLUE, RED } 
@export var team: Team = Team.BLUE

enum PieceColor { WHITE=0, BLACK=1, RED=2, BLUE=3, PURPLE=4, GREEN=5, CYAN=6, GOLD=7 }
@export var current_color: PieceColor = PieceColor.WHITE

enum PieceType { 
	PAWN = 0, 
	ROOK = 1, 
	KNIGHT_TOPLEFT = 2, 
	KNIGHT_TOPRIGHT = 3,
	KNIGHT_BOTTOMRIGHT = 4,
	KNIGHT_BOTTOMLEFT = 5, 
	BISHOP = 6, 
	KING = 7, 
	QUEEN = 8,
	AIRSHIP = 9, 
	ESPER = 10, 
	JOKER = 11, 
	ASSASSIN = 12
}

var base_color: Color = Color(1, 1, 1, 1)

@export var current_type: PieceType = PieceType.PAWN:
	set(new_value):
		current_type = new_value
		apply_sprite()

func _ready():
	apply_sprite()

func apply_sprite():
	frame = current_type + (current_color * 15)
	modulate = Color(1, 1, 1, 1)
