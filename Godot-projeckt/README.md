# Gold Rush Due — Godot 4.x Projekt

Willkommen zum offiziellen Godot 4 Projekt für **Gold Rush Due**!

## 🚀 Schnellanleitung (In 1 Minute starten):
1. Lade **Godot 4.3 oder 4.4** von [godotengine.org](https://godotengine.org) herunter.
2. Entpacke dieses ZIP-Archiv in einen neuen leeren Ordner auf deinem Computer.
3. Starte Godot und klicke auf **Importieren** (Import).
4. Wähle die Datei `project.godot` in diesem Ordner aus und klicke auf **Importieren & Bearbeiten**.
5. Drücke **F5** (oder den Play-Button oben rechts), um das Spiel sofort zu starten!

## 🃏 Enthaltene Regeln:
- **10 Einzelkarten**: 5 Basis (Schere, Stein, Papier, Mann, Schlange) + 5 Golden.
- **Ungültiges Geben**: Erhält ein Spieler 2x Papier und 2x Stein, wird automatisch neu gemischt.
- **Hort (Vorratsstapel)**: Siege mit Stein schicken Beute in den Hort ("place Holfer"). Sobald du <= 1 Handkarte hast, nimmst du den Hort zurück.
- **Strike-Regel**: Papier schlägt Stein = Strike! 2 Strikes = sofortige Niederlage.
- **The Ting Goes**: Der Alles-oder-nichts-Ruf mit permanenter Kartenbindung.
- **Duell-Matrix**: Exakte 10x10 Matrix inklusive der Sonderregel für den Goldenen Mann.

## 📁 Projekt-Dateien:
- `project.godot`: Vorkonfigurierte Projekteinstellungen (1280x720, Nearest Pixel Texture Filter).
- `scripts/MatchupMatrix.gd`: Vollständige Duell-Matrix und Hilfsfunktionen.
- `scripts/CardData.gd`: Kartendaten, deutsche & englische Namen und Beschreibungen.
- `scripts/CardUI.gd`: Steuerungs-Skript für animierte Karten (Hover, Klick, Auswählen).
- `scripts/GameManager.gd`: Komplette Spielregeln, Mischen, Hort-Verwaltung, KI und Siegbedingungen.
- `scripts/MainGame.gd`: UI-Controller passend zu deinem Screenshot.
- `scenes/MainGame.tscn`: 2D-Szene mit genau deinem Layout aus dem Screenshot.
- `scenes/CardUI.tscn`: Wiederverwendbare Karten-Komponente.
