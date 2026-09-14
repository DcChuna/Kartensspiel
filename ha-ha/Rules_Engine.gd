class_name RulesEngine
extends RefCounted

enum Outcome {
	WIN,
	LOSE,
	DRAW
}

class RoundOutcome:
	var winner: String # "player", "opponent", "draw"
	var reason: String
	var strike_awarded_to: String = "" # "player", "opponent", or ""
	var banished_card: int = -1
	var stolen_card: int = -1
	var stolen_by: String = ""

static func evaluate_clash(card_a: int, card_b: int) -> int:
	if card_a == card_b:
		return Outcome.DRAW
	if CardData.BEATS.has(card_a) and CardData.BEATS[card_a].has(card_b):
		return Outcome.WIN
	return Outcome.LOSE

static func resolve_round(player_card: int, opponent_card: int) -> RoundOutcome:
	var result = RoundOutcome.new()
	var p_name = CardData.CARD_NAMES[player_card]
	var o_name = CardData.CARD_NAMES[opponent_card]
	
	var outcome = evaluate_clash(player_card, opponent_card)
	
	if outcome == Outcome.DRAW:
		result.winner = "draw"
		result.reason = "Both played %s! Standoff — cards return to hands." % p_name
		return result
		
	if outcome == Outcome.WIN:
		result.winner = "player"
		
		# 1. STONE BANISH RULE: Defeated cards are destroyed into the void forever!
		if CardData.is_stone_type(player_card):
			result.reason = "%s defeats %s! STONE BANISH: Opponent's %s is destroyed into the void!" % [p_name, o_name, o_name]
			result.banished_card = opponent_card
			return result
			
		# 2. PAPER VS STONE STRIKE RULE: Inflicts strike on opponent
		if CardData.is_paper_type(player_card) and CardData.is_stone_type(opponent_card):
			result.reason = "%s smothers %s! STRIKE INFLICTED! Opponent receives 1 Strike!" % [p_name, o_name]
			result.strike_awarded_to = "opponent"
			result.stolen_card = opponent_card
			result.stolen_by = "player"
			return result
			
		# 3. Standard Card Steal
		result.reason = "%s defeats %s! You captured opponent's %s!" % [p_name, o_name, o_name]
		result.stolen_card = opponent_card
		result.stolen_by = "player"
		return result
	else:
		# Opponent Won
		result.winner = "opponent"
		
		# Opponent Stone Banish
		if CardData.is_stone_type(opponent_card):
			result.reason = "Opponent's %s defeats your %s! STONE BANISH: Your %s was destroyed!" % [o_name, p_name, p_name]
			result.banished_card = player_card
			return result
			
		# Opponent Paper vs Player Stone Strike
		if CardData.is_paper_type(opponent_card) and CardData.is_stone_type(player_card):
			result.reason = "Opponent's %s smothers your %s! YOU RECEIVED A STRIKE! (2 strikes = loss)" % [o_name, p_name]
			result.strike_awarded_to = "player"
			result.stolen_card = player_card
			result.stolen_by = "opponent"
			return result
			
		# Standard Opponent Steal
		result.reason = "Opponent's %s defeats your %s! Opponent stole your %s!" % [o_name, p_name, p_name]
		result.stolen_card = player_card
		result.stolen_by = "opponent"
		return result
