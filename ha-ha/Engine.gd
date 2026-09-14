class_name GameManager
extends Node

signal round_completed(result: RulesEngine.RoundOutcome)
signal game_over(winner_name: String, reason: String)
signal hand_updated(player_hand: Array[int], bot_hand: Array[int])
signal strikes_updated(player_strikes: int, bot_strikes: int)

@export var difficulty: BotAI.Difficulty = BotAI.Difficulty.HARD
@export var use_10_card_deck: bool = true

var player_hand: Array[int] = []
var bot_hand: Array[int] = []
var banished_cards: Array[int] = []
var player_strikes: int = 0
var bot_strikes: int = 0
var round_count: int = 0
var match_history: Array = []

func _ready() -> void:
	start_new_game()

func start_new_game() -> void:
	if use_10_card_deck:
		# Full 10-Card Master Table
		player_hand = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
		bot_hand = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	else:
		# 5-Card Quick Duel
		player_hand = [CardData.CardType.STEIN, CardData.CardType.PAPIER, CardData.CardType.SCHERE, CardData.CardType.MAN, CardData.CardType.SNAKE]
		bot_hand = [CardData.CardType.STEIN, CardData.CardType.PAPIER, CardData.CardType.SCHERE, CardData.CardType.MAN, CardData.CardType.SNAKE]
		
	banished_cards.clear()
	player_strikes = 0
	bot_strikes = 0
	round_count = 0
	match_history.clear()
	
	emit_signal("hand_updated", player_hand, bot_hand)
	emit_signal("strikes_updated", player_strikes, bot_strikes)

func play_round(player_card: int) -> void:
	if not player_hand.has(player_card):
		return
		
	var bot_card = BotAI.pick_card(difficulty, bot_hand, player_hand, bot_strikes, player_strikes, match_history)
	round_count += 1
	
	var result = RulesEngine.resolve_round(player_card, bot_card)
	match_history.append(result)
	
	if result.strike_awarded_to == "player":
		player_strikes += 1
	elif result.strike_awarded_to == "opponent":
		bot_strikes += 1
		
	if result.winner == "player":
		if result.banished_card != -1:
			bot_hand.erase(result.banished_card)
			banished_cards.append(result.banished_card)
		elif result.stolen_card != -1:
			bot_hand.erase(result.stolen_card)
			player_hand.append(result.stolen_card)
	elif result.winner == "opponent":
		if result.banished_card != -1:
			player_hand.erase(result.banished_card)
			banished_cards.append(result.banished_card)
		elif result.stolen_card != -1:
			player_hand.erase(result.stolen_card)
			bot_hand.append(result.stolen_card)
			
	emit_signal("round_completed", result)
	emit_signal("hand_updated", player_hand, bot_hand)
	emit_signal("strikes_updated", player_strikes, bot_strikes)
	
	_check_game_over()

func _check_game_over() -> void:
	if player_strikes >= 2:
		emit_signal("game_over", "Bot", "Player reached 2 Strikes (Paper crushed Stone twice)!")
		return
	if bot_strikes >= 2:
		emit_signal("game_over", "Player", "Bot reached 2 Strikes (Paper crushed Stone twice)!")
		return
		
	if player_hand.is_empty():
		emit_signal("game_over", "Bot", "Player has run out of cards!")
		return
	if bot_hand.is_empty():
		emit_signal("game_over", "Player", "Bot has run out of cards!")
		return
