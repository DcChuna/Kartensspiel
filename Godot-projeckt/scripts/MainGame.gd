extends Control

## Haupt-Controller für Gold Rush Due
## Verbindet die Benutzeroberfläche 1:1 mit der Spiellogik

@onready var game_manager: GameManager = $GameManager

# Obere Leiste
@onready var round_counter_label: Label = $TopBar/RoundCounter
@onready var restart_top_btn: Button = $TopBar/NewGameBtn

# Obere Reihe (Gegner)
@onready var opponent_hort_count: Label = $TopArea/OpponentHort/VBoxContainer/CountLabel
@onready var opponent_hand_container: HBoxContainer = $TopArea/OpponentHand
@onready var opponent_strike_1: Label = $TopArea/OpponentStrikesBox/Strike1
@onready var opponent_strike_2: Label = $TopArea/OpponentStrikesBox/Strike2

# Mittlere Reihe (Duell-Arena)
@onready var opponent_clash_panel: PanelContainer = $CenterArena/ClashSlots/OpponentClashSlot
@onready var opponent_clash_holder: Control = $CenterArena/ClashSlots/OpponentClashSlot/Holder
@onready var opponent_clash_placeholder: Label = $CenterArena/ClashSlots/OpponentClashSlot/PlaceholderLabel

@onready var player_clash_panel: PanelContainer = $CenterArena/ClashSlots/PlayerClashSlot
@onready var player_clash_holder: Control = $CenterArena/ClashSlots/PlayerClashSlot/Holder
@onready var player_clash_placeholder: Label = $CenterArena/ClashSlots/PlayerClashSlot/PlaceholderLabel

@onready var dust_cloud_fx: Control = $CenterArena/ClashSlots/DustCloudFX
@onready var result_banner_panel: PanelContainer = $CenterArena/ResultBanner
@onready var result_title_label: Label = $CenterArena/ResultBanner/VBoxContainer/ResultTitle
@onready var result_desc_label: Label = $CenterArena/ResultBanner/VBoxContainer/ResultDesc
@onready var next_round_btn: Button = $CenterArena/NextRoundBtn

# Untere Reihe (Spieler)
@onready var player_hand_container: HBoxContainer = $BottomArea/PlayerHand
@onready var player_hort_count: Label = $BottomArea/PlayerHort/VBoxContainer/CountLabel
@onready var retrieve_hort_btn: Button = $BottomArea/PlayerHort/VBoxContainer/RetrieveBtn
@onready var player_strike_1: Label = $BottomArea/PlayerStrikesBox/Strike1
@onready var player_strike_2: Label = $BottomArea/PlayerStrikesBox/Strike2

# HUD / Steuerung
@onready var ting_goes_btn: Button = $BottomHUD/TingGoesBtn
@onready var status_label: Label = $BottomHUD/StatusLabel
@onready var play_card_btn: Button = $BottomHUD/PlayCardBtn

# Game Over Dialog
@onready var game_over_modal: Control = $GameOverModal
@onready var game_over_icon: Label = $GameOverModal/Panel/VBox/IconLabel
@onready var game_over_title: Label = $GameOverModal/Panel/VBox/TitleLabel
@onready var game_over_details: Label = $GameOverModal/Panel/VBox/DetailsLabel
@onready var game_over_restart_btn: Button = $GameOverModal/Panel/VBox/RestartBtn

var selected_card_ui: CardUI = null
var is_clashing: bool = false
var opponent_clash_card_instance: CardUI = null
var player_clash_card_instance: CardUI = null

func _ready() -> void:
	game_manager.hands_dealt.connect(_on_hands_dealt)
	game_manager.round_resolved.connect(_on_round_resolved)
	game_manager.court_retrieved.connect(_on_court_retrieved)
	game_manager.game_over.connect(_on_game_over)
	
	play_card_btn.pressed.connect(_on_play_card_pressed)
	ting_goes_btn.pressed.connect(_on_ting_goes_pressed)
	retrieve_hort_btn.pressed.connect(_on_retrieve_hort_pressed)
	next_round_btn.pressed.connect(_on_next_round_pressed)
	restart_top_btn.pressed.connect(_on_restart_pressed)
	game_over_restart_btn.pressed.connect(_on_restart_pressed)
	
	next_round_btn.visible = false
	result_banner_panel.visible = false
	dust_cloud_fx.visible = false
	game_over_modal.visible = false
	
	game_manager.start_new_game()

func _on_restart_pressed() -> void:
	game_over_modal.visible = false
	next_round_btn.visible = false
	result_banner_panel.visible = false
	dust_cloud_fx.visible = false
	is_clashing = false
	selected_card_ui = null
	clear_clash_slots()
	game_manager.start_new_game()

func _on_hands_dealt(p_hand: Array[String], o_hand: Array[String], redeals: int) -> void:
	clear_clash_slots()
	render_hands()
	update_hud()
	if redeals > 0:
		status_label.text = "Ungültiges Geben erkannt - Neu gemischt! Wähle eine Karte."
	else:
		status_label.text = "Runde 1: Wähle eine Karte zum Ausspielen."

func render_hands() -> void:
	# Spieler-Hand leeren und neu befüllen
	for child in player_hand_container.get_children():
		child.queue_free()
		
	for card_id in game_manager.player_hand:
		var card_scene = preload("res://scenes/CardUI.tscn").instantiate() as CardUI
		player_hand_container.add_child(card_scene)
		card_scene.set_card(card_id, false)
		if game_manager.player_ting_goes == card_id:
			card_scene.is_locked_ting_goes = true
			card_scene.update_visuals()
		card_scene.card_clicked.connect(_on_card_selected)
		
	# Gegner-Hand leeren und neu befüllen (verdeckt)
	for child in opponent_hand_container.get_children():
		child.queue_free()
		
	for card_id in game_manager.opponent_hand:
		var card_scene = preload("res://scenes/CardUI.tscn").instantiate() as CardUI
		opponent_hand_container.add_child(card_scene)
		card_scene.set_card(card_id, true)
		card_scene.is_opponent_card = true

	selected_card_ui = null
	play_card_btn.disabled = true
	play_card_btn.text = "⚔ SPIELE KARTE"
	
	# Wenn Ting Goes aktiv ist, automatisch sperren / auswählen
	if game_manager.player_ting_goes != "":
		for child in player_hand_container.get_children():
			var c = child as CardUI
			if c and c.card_id == game_manager.player_ting_goes:
				_on_card_selected(c)
				break

func _on_card_selected(card_ui: CardUI) -> void:
	if is_clashing or not game_manager.is_game_active:
		return
		
	# Wenn Ting Goes ausgerufen wurde, kann nur diese Karte gespielt werden!
	if game_manager.player_ting_goes != "" and card_ui.card_id != game_manager.player_ting_goes:
		status_label.text = "The Ting Goes ist aktiv! Du musst deine gebundene Karte spielen."
		return
		
	if selected_card_ui != null and selected_card_ui != card_ui:
		selected_card_ui.set_selected(false)
		
	selected_card_ui = card_ui
	selected_card_ui.set_selected(true)
	
	var info = CardData.get_card_info(card_ui.card_id)
	play_card_btn.disabled = false
	play_card_btn.text = "⚔ SPIELE: " + info.name_de.to_upper()
	
	if game_manager.player_ting_goes == "":
		ting_goes_btn.disabled = false
		ting_goes_btn.text = "🔥 TING GOES: " + info.name_de
	status_label.text = "%s gewählt: %s" % [info.name_de, info.description_de]

func _on_play_card_pressed() -> void:
	if selected_card_ui == null or is_clashing or not game_manager.is_game_active:
		return
		
	is_clashing = true
	var chosen_card_id = selected_card_ui.card_id
	play_card_btn.disabled = true
	ting_goes_btn.disabled = true
	
	# Runde in GameManager auswerten
	game_manager.play_round(chosen_card_id)

func _on_round_resolved(result: Dictionary) -> void:
	# Karten in die Duell-Arena setzen
	clear_clash_slots()
	
	# Spieler-Karte im Duell-Slot
	player_clash_card_instance = preload("res://scenes/CardUI.tscn").instantiate() as CardUI
	player_clash_holder.add_child(player_clash_card_instance)
	player_clash_card_instance.set_card(result.player_card, false)
	player_clash_placeholder.visible = false
	
	# Gegner-Karte im Duell-Slot (AUFGEDECKT!)
	opponent_clash_card_instance = preload("res://scenes/CardUI.tscn").instantiate() as CardUI
	opponent_clash_holder.add_child(opponent_clash_card_instance)
	opponent_clash_card_instance.set_card(result.opponent_card, false)
	opponent_clash_placeholder.visible = false
	
	# Comic FX anzeigen
	dust_cloud_fx.visible = true
	dust_cloud_fx.scale = Vector2(0.5, 0.5)
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(dust_cloud_fx, "scale", Vector2(1.1, 1.1), 0.25)
	tween.tween_property(dust_cloud_fx, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Banner aufbauen
	var p_name = CardData.get_card_info(result.player_card).name_de
	var o_name = CardData.get_card_info(result.opponent_card).name_de
	var win_name = CardData.get_card_info(result.win_card).name_de
	var lose_name = CardData.get_card_info(result.lose_card).name_de
	
	result_banner_panel.visible = true
	
	if result.winner == "player":
		result_title_label.text = "★ DU GEWINNST DIE RUNDE! ★"
		result_title_label.add_theme_color_override("font_color", Color("#22c55e"))
		if result.is_strike:
			result_desc_label.text = "%s schlägt %s! ⚡ STRIKE FÜR DEN GEGNER! (+1 Strike)" % [win_name, lose_name]
		elif result.sends_to_court:
			result_desc_label.text = "%s gewinnt! Eroberte Karte (%s) wandert in deinen Hort!" % [win_name, lose_name]
		else:
			result_desc_label.text = "%s schlägt %s! Du erhältst %s auf die Hand." % [win_name, lose_name, lose_name]
	else:
		result_title_label.text = "☠ GEGNER GEWINNT DIE RUNDE! ☠"
		result_title_label.add_theme_color_override("font_color", Color("#ef4444"))
		if result.is_strike:
			result_desc_label.text = "%s schlägt %s! ⚡ DU ERHÄLTST EINEN STRIKE! (Strike %d/2)" % [win_name, lose_name, result.player_strikes]
		elif result.sends_to_court:
			result_desc_label.text = "%s gewinnt! Deine Karte (%s) wandert in den Hort des Gegners." % [win_name, lose_name]
		else:
			result_desc_label.text = "%s schlägt %s! Gegner nimmt deine Karte." % [win_name, lose_name]
			
	update_hud()
	
	# Nächste Runde Button aktivieren (oder direkt Game Over Dialog nach Klick)
	next_round_btn.visible = true
	next_round_btn.grab_focus()

func _on_next_round_pressed() -> void:
	next_round_btn.visible = false
	result_banner_panel.visible = false
	dust_cloud_fx.visible = false
	is_clashing = false
	clear_clash_slots()
	
	if not game_manager.is_game_active and game_manager.last_result.get("is_game_over", false):
		_show_game_over_dialog(
			game_manager.last_result.game_over_winner,
			game_manager.last_result.game_over_reason,
			game_manager.last_result.game_over_details
		)
		return
		
	render_hands()
	update_hud()
	status_label.text = "Runde %d: Wähle eine Karte zum Ausspielen." % game_manager.current_round

func clear_clash_slots() -> void:
	if player_clash_card_instance != null:
		player_clash_card_instance.queue_free()
		player_clash_card_instance = null
	if opponent_clash_card_instance != null:
		opponent_clash_card_instance.queue_free()
		opponent_clash_card_instance = null
	player_clash_placeholder.visible = true
	opponent_clash_placeholder.visible = true

func update_hud() -> void:
	round_counter_label.text = "RUNDE %d" % game_manager.current_round
	player_hort_count.text = "Hort: %d" % game_manager.player_court.size()
	opponent_hort_count.text = "Hort: %d" % game_manager.opponent_court.size()
	
	# Strike Indikatoren aktualisieren
	if game_manager.player_strikes >= 1:
		player_strike_1.text = "✕"
		player_strike_1.add_theme_color_override("font_color", Color("#ef4444"))
	else:
		player_strike_1.text = "○"
		player_strike_1.add_theme_color_override("font_color", Color("#475569"))
		
	if game_manager.player_strikes >= 2:
		player_strike_2.text = "☠"
		player_strike_2.add_theme_color_override("font_color", Color("#ef4444"))
	else:
		player_strike_2.text = "○"
		player_strike_2.add_theme_color_override("font_color", Color("#475569"))
		
	if game_manager.opponent_strikes >= 1:
		opponent_strike_1.text = "✕"
		opponent_strike_1.add_theme_color_override("font_color", Color("#ef4444"))
	else:
		opponent_strike_1.text = "○"
		opponent_strike_1.add_theme_color_override("font_color", Color("#475569"))
		
	if game_manager.opponent_strikes >= 2:
		opponent_strike_2.text = "☠"
		opponent_strike_2.add_theme_color_override("font_color", Color("#ef4444"))
	else:
		opponent_strike_2.text = "○"
		opponent_strike_2.add_theme_color_override("font_color", Color("#475569"))
		
	# Hort nehmen Button (nur wenn Hand <= 1 und Hort > 0)
	var can_retrieve = game_manager.player_hand.size() <= 1 and game_manager.player_court.size() > 0
	retrieve_hort_btn.visible = can_retrieve
	if can_retrieve:
		retrieve_hort_btn.text = "HORT NEHMEN (+%d)" % game_manager.player_court.size()

func _on_retrieve_hort_pressed() -> void:
	if game_manager.retrieve_player_court():
		status_label.text = "Hort zurückgeholt! Alle Karten liegen wieder auf deiner Hand."
		render_hands()
		update_hud()

func _on_court_retrieved(player: String, cards: Array[String]) -> void:
	update_hud()

func _on_ting_goes_pressed() -> void:
	if selected_card_ui != null and game_manager.player_ting_goes == "":
		game_manager.declare_ting_goes(selected_card_ui.card_id)
		selected_card_ui.is_locked_ting_goes = true
		selected_card_ui.update_visuals()
		ting_goes_btn.disabled = true
		ting_goes_btn.text = "🔥 TING GOES AKTIV!"
		var card_name = CardData.get_card_info(selected_card_ui.card_id).name_de
		status_label.text = "THE TING GOES auf '%s' ausgerufen! Sieg = Sofortgewinn, Niederlage = Sofortige Niederlage!" % card_name

func _on_game_over(winner: String, reason: String, details: String) -> void:
	if not next_round_btn.visible:
		_show_game_over_dialog(winner, reason, details)

func _show_game_over_dialog(winner: String, reason: String, details: String) -> void:
	game_over_modal.visible = true
	if winner == "player":
		game_over_icon.text = "🏆"
		game_over_title.text = "★ DU HAST GEWONNEN! ★"
		game_over_title.add_theme_color_override("font_color", Color("#facc15"))
	else:
		game_over_icon.text = "☠"
		game_over_title.text = "☠ DU WURDEST BESIEGT! ☠"
		game_over_title.add_theme_color_override("font_color", Color("#ef4444"))
	game_over_details.text = details
