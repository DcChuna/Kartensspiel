class_name CardUI
extends Control

signal card_clicked(card_ui: CardUI)

@export var card_id: String = "S"
@export var is_face_down: bool = false
@export var is_locked_ting_goes: bool = false
@export var is_opponent_card: bool = false

@onready var card_panel: Panel = $CardPanel
@onready var label_tier: Label = $CardPanel/MarginContainer/VBoxContainer/CardTier
@onready var label_symbol: Label = $CardPanel/MarginContainer/VBoxContainer/CardSymbol
@onready var label_name: Label = $CardPanel/MarginContainer/VBoxContainer/CardName

var is_selected: bool = false
var original_pos_y: float = 0.0

func _ready() -> void:
	original_pos_y = position.y
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	update_visuals()

func set_card(id: String, face_down: bool = false) -> void:
	card_id = id
	is_face_down = face_down
	update_visuals()

func update_visuals() -> void:
	if not is_inside_tree() or card_panel == null:
		return
		
	var is_gold = card_id.begins_with("G")
	var info = CardData.get_card_info(card_id)
	
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.set_border_width_all(3)
	style.shadow_size = 4
	style.shadow_color = Color(0, 0, 0, 0.5)
	
	if is_face_down:
		# Rückseite passend zu deinem Saloon Pokertisch (Tiefrot mit Goldrand)
		style.bg_color = Color("#6b1414")
		style.border_color = Color("#f59e0b")
		card_panel.add_theme_stylebox_override("panel", style)
		
		label_tier.text = "★ ★ ★"
		label_tier.add_theme_color_override("font_color", Color("#fbbf24"))
		label_symbol.text = "♦"
		label_symbol.add_theme_color_override("font_color", Color("#fbbf24"))
		label_name.text = "GOLD RUSH"
		label_name.add_theme_color_override("font_color", Color("#fef08a"))
	else:
		if is_selected:
			style.set_border_width_all(4)
			style.border_color = Color("#eab308") if is_gold else Color("#38bdf8")
			style.shadow_size = 8
			style.shadow_color = Color(0.9, 0.7, 0.1, 0.8)
		elif is_locked_ting_goes:
			style.set_border_width_all(4)
			style.border_color = Color("#ef4444")
			style.shadow_size = 8
			style.shadow_color = Color(1.0, 0.2, 0.2, 0.8)
		else:
			style.border_color = Color("#d97706") if is_gold else Color("#475569")
			
		if is_gold:
			style.bg_color = Color("#fef08a") # Kräftiges Gold
			card_panel.add_theme_stylebox_override("panel", style)
			
			label_tier.text = "★ GOLDEN ★"
			label_tier.add_theme_color_override("font_color", Color("#92400e"))
			label_symbol.text = info.icon
			label_symbol.add_theme_color_override("font_color", Color("#78350f"))
			label_name.text = info.name_de
			label_name.add_theme_color_override("font_color", Color("#451a03")) # Dunkelbraun, 100% lesbar!
		else:
			style.bg_color = Color("#f8fafc") # Sauberes Pergament
			card_panel.add_theme_stylebox_override("panel", style)
			
			label_tier.text = "BASIS"
			label_tier.add_theme_color_override("font_color", Color("#475569"))
			label_symbol.text = info.icon
			label_symbol.add_theme_color_override("font_color", Color("#1e293b"))
			label_name.text = info.name_de
			label_name.add_theme_color_override("font_color", Color("#0f172a")) # Dunkles Anthrazit, 100% lesbar!

func set_selected(selected: bool) -> void:
	is_selected = selected
	update_visuals()
	var target_y = original_pos_y - 24.0 if is_selected else original_pos_y
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", target_y, 0.15)

func _on_mouse_entered() -> void:
	if not is_face_down and not is_opponent_card:
		var target_y = original_pos_y - (28.0 if is_selected else 10.0)
		create_tween().tween_property(self, "position:y", target_y, 0.1)

func _on_mouse_exited() -> void:
	if not is_face_down and not is_opponent_card:
		var target_y = original_pos_y - 24.0 if is_selected else original_pos_y
		create_tween().tween_property(self, "position:y", target_y, 0.1)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_clicked.emit(self)
