class_name BotAI
extends RefCounted

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	NIGHTMARE
}

static func pick_card(
	difficulty: int,
	bot_hand: Array[int],
	player_hand: Array[int],
	bot_strikes: int,
	player_strikes: int,
	round_history: Array
) -> int:
	if bot_hand.is_empty():
		return CardData.CardType.STEIN
	if bot_hand.size() == 1:
		return bot_hand[0]
		
	var unique_cards: Array[int] = []
	for c in bot_hand:
		if not unique_cards.has(c):
			unique_cards.append(c)
			
	match difficulty:
		Difficulty.EASY:
			return unique_cards[randi() % unique_cards.size()]
			
		Difficulty.MEDIUM:
			return _pick_medium(unique_cards, player_hand, bot_strikes)
			
		Difficulty.HARD:
			return _pick_hard(unique_cards, player_hand, bot_strikes, player_strikes)
			
		Difficulty.NIGHTMARE:
			return _pick_hard(unique_cards, player_hand, bot_strikes, player_strikes)
			
	return unique_cards[0]

static func _pick_medium(bot_cards: Array[int], player_hand: Array[int], bot_strikes: int) -> int:
	var pool = bot_cards.duplicate()
	var player_has_paper = player_hand.any(func(c): return CardData.is_paper_type(c))
	
	if bot_strikes >= 1 and player_has_paper and pool.size() > 1:
		pool = pool.filter(func(c): return not CardData.is_stone_type(c))
		if pool.is_empty():
			pool = bot_cards.duplicate()
			
	var best_card = pool[0]
	var best_score = -999.0
	for card in pool:
		var score = 0.0
		for p_card in player_hand:
			var outcome = RulesEngine.evaluate_clash(card, p_card)
			if outcome == RulesEngine.Outcome.WIN:
				score += 2.0
				if CardData.is_paper_type(card) and CardData.is_stone_type(p_card):
					score += 3.0
			elif outcome == RulesEngine.Outcome.DRAW:
				score += 0.5
			else:
				score -= 1.5
		if score > best_score:
			best_score = score
			best_card = card
	return best_card

static func _pick_hard(bot_cards: Array[int], player_hand: Array[int], bot_strikes: int, player_strikes: int) -> int:
	var best_card = bot_cards[0]
	var best_score = -9999.0
	
	for card in bot_cards:
		var score = 0.0
		for p_card in player_hand:
			var outcome = RulesEngine.evaluate_clash(card, p_card)
			if outcome == RulesEngine.Outcome.WIN:
				score += 3.0
				if CardData.is_paper_type(card) and CardData.is_stone_type(p_card):
					score += 9.0 if player_strikes == 1 else 4.5
				if CardData.is_stone_type(card):
					score += 2.0 # Banish incentive
			elif outcome == RulesEngine.Outcome.DRAW:
				score += 0.5
			else:
				score -= 3.0
				if CardData.is_stone_type(card) and CardData.is_paper_type(p_card):
					score -= 16.0 if bot_strikes == 1 else 7.0
					
		score += randf_range(-0.3, 0.3)
		if score > best_score:
			best_score = score
			best_card = card
			
	return best_card
