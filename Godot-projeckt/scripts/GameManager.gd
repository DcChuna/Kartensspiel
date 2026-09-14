class_name GameManager
extends Node

## Vollständiger Spiellogik-Manager für Gold Rush Due
## Beachtet alle offiziellen Regeln:
## - 10 Einzelkarten
## - Ungültiges Geben (automatisch neu geben)
## - Hort (Vorratsstapel) bei Stein-Siegen ("place Holfer")
## - Strike-Regel (Papier schlägt Stein)
## - The Ting Goes (Alles-oder-nichts-Wette)

signal hands_dealt(player_hand: Array[String], opponent_hand: Array[String], redeal_count: int)
signal round_resolved(result: Dictionary)
signal game_over(winner: String, reason: String, details: String)
signal court_retrieved(player: String, cards: Array[String])

var player_hand: Array[String] = []
var player_court: Array[String] = []
var player_strikes: int = 0
var player_ting_goes: String = ""

var opponent_hand: Array[String] = []
var opponent_court: Array[String] = []
var opponent_strikes: int = 0
var opponent_ting_goes: String = ""

var current_round: int = 1
var is_game_active: bool = false
var last_result: Dictionary = {}

func start_new_game() -> void:
	player_court.clear()
	opponent_court.clear()
	player_strikes = 0
	opponent_strikes = 0
	player_ting_goes = ""
	opponent_ting_goes = ""
	current_round = 1
	is_game_active = true
	last_result.clear()
	
	# Mischen & Ungültiges Geben prüfen (2x Papier + 2x Stein auf einer Hand)
	var redeal_count = 0
	var valid_deal = false
	
	while not valid_deal:
		var deck = MatchupMatrix.ALL_CARDS.duplicate()
		deck.shuffle()
		player_hand = deck.slice(0, 5)
		opponent_hand = deck.slice(5, 10)
		
		if MatchupMatrix.is_invalid_deal(player_hand) or MatchupMatrix.is_invalid_deal(opponent_hand):
			redeal_count += 1
		else:
			valid_deal = true
			
	hands_dealt.emit(player_hand, opponent_hand, redeal_count)

func play_round(player_card_id: String) -> Dictionary:
	if not is_game_active:
		return {}
		
	# Gegner KI wählt Karte
	var opponent_card_id = ""
	if opponent_ting_goes != "":
		opponent_card_id = opponent_ting_goes
	else:
		opponent_card_id = _ai_choose_card()
		
	# Karten aus den Händen nehmen
	player_hand.erase(player_card_id)
	opponent_hand.erase(opponent_card_id)
	
	# Sieger ermitteln
	var player_won = MatchupMatrix.does_beat(player_card_id, opponent_card_id)
	var winner_id = "player" if player_won else "opponent"
	var win_card = player_card_id if player_won else opponent_card_id
	var lose_card = opponent_card_id if player_won else player_card_id
	
	# Strike-Regel: Papier schlägt Stein
	var is_strike = MatchupMatrix.causes_strike(win_card, lose_card)
	var strike_target = ""
	if is_strike:
		if player_won:
			opponent_strikes += 1
			strike_target = "opponent"
		else:
			player_strikes += 1
			strike_target = "player"
			
	# Hort-Regel: Stein-Sieger schickt Verlierer in den Hort
	var sends_to_court = MatchupMatrix.is_stone(win_card)
	
	if player_won:
		player_hand.append(player_card_id) # Eigene Karte zurück auf die Hand
		if sends_to_court:
			player_court.append(lose_card) # In den Hort
		else:
			player_hand.append(lose_card)  # Direkt auf die Hand
	else:
		opponent_hand.append(opponent_card_id)
		if sends_to_court:
			opponent_court.append(lose_card)
		else:
			opponent_hand.append(lose_card)
			
	# Gegner KI holt Hort automatisch zurück wenn <= 1 Handkarte
	var opponent_retrieved_court = false
	if opponent_hand.size() <= 1 and opponent_court.size() > 0:
		opponent_hand.append_array(opponent_court)
		opponent_court.clear()
		opponent_retrieved_court = true
		court_retrieved.emit("opponent", opponent_hand)
		
	# Prüfen auf Spielende
	var game_over_info = _check_win_conditions(winner_id)
	
	var round_result: Dictionary = {
		"round": current_round,
		"player_card": player_card_id,
		"opponent_card": opponent_card_id,
		"winner": winner_id,
		"win_card": win_card,
		"lose_card": lose_card,
		"is_strike": is_strike,
		"strike_target": strike_target,
		"sends_to_court": sends_to_court,
		"player_strikes": player_strikes,
		"opponent_strikes": opponent_strikes,
		"opponent_retrieved_court": opponent_retrieved_court,
		"is_game_over": game_over_info.is_over,
		"game_over_winner": game_over_info.get("winner", ""),
		"game_over_reason": game_over_info.get("reason", ""),
		"game_over_details": game_over_info.get("details", "")
	}
	
	last_result = round_result
	current_round += 1
	round_resolved.emit(round_result)
	
	if game_over_info.is_over:
		is_game_active = false
		game_over.emit(game_over_info.winner, game_over_info.reason, game_over_info.details)
		
	return round_result

func retrieve_player_court() -> bool:
	if player_hand.size() <= 1 and player_court.size() > 0:
		player_hand.append_array(player_court)
		player_court.clear()
		court_retrieved.emit("player", player_hand)
		return true
	return false

func declare_ting_goes(card_id: String) -> void:
	if player_hand.has(card_id):
		player_ting_goes = card_id

func _check_win_conditions(round_winner: String) -> Dictionary:
	# 1. The Ting Goes gescheitert
	if player_ting_goes != "" and round_winner == "opponent":
		var card_name = CardData.get_card_info(player_ting_goes).name_de
		return {
			"is_over": true,
			"winner": "opponent",
			"reason": "ting_goes_failed",
			"details": "Deine 'The Ting Goes' Wette auf " + card_name + " wurde geschlagen! Der Gegner gewinnt."
		}
		
	if opponent_ting_goes != "" and round_winner == "player":
		return {
			"is_over": true,
			"winner": "player",
			"reason": "ting_goes_opponent_failed",
			"details": "Du hast die 'The Ting Goes' Wette des Gegners geknackt! Du gewinnst das Duell."
		}
		
	# 2. Strike-Limit (2 Strikes = sofortige Niederlage)
	if player_strikes >= 2:
		return {
			"is_over": true,
			"winner": "opponent",
			"reason": "strikes",
			"details": "Du hast 2 Strikes erhalten! Papier hat deine Steine besiegt."
		}
	if opponent_strikes >= 2:
		return {
			"is_over": true,
			"winner": "player",
			"reason": "strikes",
			"details": "Gegner hat 2 Strikes erhalten! Dein Papier hat triumphiert."
		}
		
	# 3. Keine Karten übrig (alle 10 erobert)
	var player_total = player_hand.size() + player_court.size()
	var opponent_total = opponent_hand.size() + opponent_court.size()
	
	if opponent_total == 0:
		return {
			"is_over": true,
			"winner": "player",
			"reason": "cards_cleared",
			"details": "Du hast alle 10 Karten erobert! Der Gegner hat keine Karten mehr."
		}
	if player_total == 0:
		return {
			"is_over": true,
			"winner": "opponent",
			"reason": "cards_cleared",
			"details": "Du hast keine Karten mehr! Der Gegner hat alle deine Karten erobert."
		}
		
	# 4. Wenn Spieler Ting Goes aktiv hat und Gegner keine Karte mehr besitzt, die schlagen kann
	if player_ting_goes != "":
		var opponent_all = opponent_hand.duplicate()
		opponent_all.append_array(opponent_court)
		var can_beat = false
		for o_card in opponent_all:
			if MatchupMatrix.does_beat(o_card, player_ting_goes):
				can_beat = true
				break
		if not can_beat:
			return {
				"is_over": true,
				"winner": "player",
				"reason": "ting_goes_unbeatable",
				"details": "Unaufhaltsam! Der Gegner hat keine Karte mehr, die deine " + CardData.get_card_info(player_ting_goes).name_de + " schlagen kann!"
			}
			
	return {"is_over": false}

func _ai_choose_card() -> String:
	if opponent_hand.is_empty():
		return ""
	# Intelligente KI: versucht Steine zu spielen, wenn sie sicher sind, oder Konter
	return opponent_hand.pick_random()
