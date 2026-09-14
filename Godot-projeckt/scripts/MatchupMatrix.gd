class_name MatchupMatrix
extends RefCounted

## 10x10 Matchup Matrix für Gold Rush Due
## S = Schere, T = Stein, P = Papier, M = Mann, N = Schlange
## G-Präfix = Golden (GS, GT, GP, GM, GN)

const ALL_CARDS: Array[String] = ["S", "T", "P", "M", "N", "GS", "GT", "GP", "GM", "GN"]

const MATRIX: Dictionary = {
	"S":  {"S": false, "T": false, "P": true,  "M": true,  "N": true,  "GS": false, "GT": false, "GP": true,  "GM": true,  "GN": true},
	"T":  {"S": true,  "T": false, "P": false, "M": true,  "N": true,  "GS": true,  "GT": false, "GP": false, "GM": true,  "GN": true},
	"P":  {"S": false, "T": true,  "P": false, "M": false, "N": false, "GS": false, "GT": true,  "GP": false, "GM": false, "GN": false},
	"M":  {"S": false, "T": false, "P": true,  "M": false, "N": false, "GS": false, "GT": false, "GP": true,  "GM": true,  "GN": false},
	"N":  {"S": false, "T": false, "P": true,  "M": true,  "N": false, "GS": false, "GT": false, "GP": true,  "GM": true,  "GN": false},
	"GS": {"S": true,  "T": false, "P": true,  "M": true,  "N": true,  "GS": false, "GT": false, "GP": true,  "GM": false, "GN": true},
	"GT": {"S": true,  "T": true,  "P": false, "M": true,  "N": true,  "GS": true,  "GT": false, "GP": false, "GM": false, "GN": true},
	"GP": {"S": false, "T": true,  "P": true,  "M": false, "N": false, "GS": false, "GT": true,  "GP": false, "GM": false, "GN": false},
	"GM": {"S": false, "T": false, "P": true,  "M": false, "N": false, "GS": true,  "GT": true,  "GP": true,  "GM": false, "GN": true},
	"GN": {"S": false, "T": false, "P": true,  "M": true,  "N": true,  "GS": false, "GT": false, "GP": true,  "GM": false, "GN": false}
}

static func does_beat(card_a: String, card_b: String) -> bool:
	if card_a == card_b:
		return false
	if not MATRIX.has(card_a) or not MATRIX[card_a].has(card_b):
		push_error("Ungültige Karten-Paarung: %s vs %s" % [card_a, card_b])
		return false
	return MATRIX[card_a][card_b]

static func is_stone(card_id: String) -> bool:
	return card_id == "T" or card_id == "GT"

static func is_paper(card_id: String) -> bool:
	return card_id == "P" or card_id == "GP"

static func causes_strike(winner_card: String, loser_card: String) -> bool:
	# Strike-Regel: Papier schlägt Stein
	return is_paper(winner_card) and is_stone(loser_card)

static func is_invalid_deal(hand: Array[String]) -> bool:
	# Ungültiges Geben: Spieler hat beide Papiere (P, GP) UND beide Steine (T, GT)
	return hand.has("P") and hand.has("GP") and hand.has("T") and hand.has("GT")
