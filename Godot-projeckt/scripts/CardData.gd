class_name CardData
extends RefCounted

## Karten-Metadaten für Gold Rush Due

static func get_card_info(card_id: String) -> Dictionary:
	var info: Dictionary = {
		"id": card_id,
		"is_golden": card_id.begins_with("G"),
		"name_de": "",
		"name_en": "",
		"category": "",
		"icon": "★",
		"description_de": ""
	}
	
	match card_id:
		"S":
			info.name_de = "Schere"
			info.name_en = "Scissors"
			info.category = "scissors"
			info.icon = "✂"
			info.description_de = "Klassische Klinge. Schlägt Papier, Mann und Schlange."
		"T":
			info.name_de = "Stein"
			info.name_en = "Stone"
			info.category = "stone"
			info.icon = "🪨"
			info.description_de = "Schwerer Granit. Schickt eroberte Karten in den Hort! Verliert gegen Papier."
		"P":
			info.name_de = "Papier"
			info.name_en = "Paper"
			info.category = "paper"
			info.icon = "📜"
			info.description_de = "Hüllt Stein ein und verpasst dem Verlierer einen STRIKE!"
		"M":
			info.name_de = "Mann"
			info.name_en = "Man"
			info.category = "man"
			info.icon = "🤠"
			info.description_de = "Schlägt Papier und entlarvt den Goldenen Mann!"
		"N":
			info.name_de = "Schlange"
			info.name_en = "Snake"
			info.category = "snake"
			info.icon = "🐍"
			info.description_de = "Giftige Natter. Frisst Mann und Papier."
		"GS":
			info.name_de = "Goldene Schere"
			info.name_en = "Golden Scissors"
			info.category = "scissors"
			info.icon = "✂"
			info.description_de = "Schlägt alles, was Schere schlägt + Basis-Schere!"
		"GT":
			info.name_de = "Goldener Stein"
			info.name_en = "Golden Stone"
			info.category = "stone"
			info.icon = "🪨"
			info.description_de = "Massiver Goldbrocken. Schickt Karten in den Hort! Schlägt Basis-Stein."
		"GP":
			info.name_de = "Goldenes Papier"
			info.name_en = "Golden Paper"
			info.category = "paper"
			info.icon = "📜"
			info.description_de = "Schlägt Stein, Goldener Stein (Strike!) und Basis-Papier."
		"GM":
			info.name_de = "Goldener Mann"
			info.name_en = "Golden Man"
			info.category = "man"
			info.icon = "🤠"
			info.description_de = "Gold-Spezialist! Schlägt alle goldenen Karten + Basis-Papier, verliert aber gegen 4 Basis-Karten."
		"GN":
			info.name_de = "Goldene Schlange"
			info.name_en = "Golden Snake"
			info.category = "snake"
			info.icon = "🐍"
			info.description_de = "Goldschuppige Natter. Schlägt Basis-Schlange, Mann und Papier."
			
	return info
