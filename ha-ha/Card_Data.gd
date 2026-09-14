class_name CardData
extends RefCounted

enum CardType {
	SCHERE,
	STEIN,
	PAPIER,
	MAN,
	SNAKE,
	G_SNAKE,
	G_SCHERE,
	G_STEIN,
	G_PAPIER,
	G_MAN
}

const CARD_NAMES = {
	CardType.SCHERE: "Schere",
	CardType.STEIN: "Stein",
	CardType.PAPIER: "Papier",
	CardType.MAN: "Man",
	CardType.SNAKE: "Snake",
	CardType.G_SNAKE: "G Snake",
	CardType.G_SCHERE: "GSchere",
	CardType.G_STEIN: "GStein",
	CardType.G_PAPIER: "GPaper",
	CardType.G_MAN: "GMan"
}

# The complete 10-node circular matchup graph
const BEATS = {
	CardType.SCHERE: [CardType.PAPIER, CardType.SNAKE, CardType.G_MAN, CardType.G_SNAKE, CardType.G_PAPIER],
	CardType.STEIN: [CardType.SCHERE, CardType.SNAKE, CardType.G_SCHERE, CardType.G_MAN, CardType.G_SNAKE],
	CardType.PAPIER: [CardType.STEIN, CardType.MAN, CardType.G_STEIN, CardType.G_SNAKE, CardType.G_MAN],
	CardType.MAN: [CardType.SCHERE, CardType.STEIN, CardType.G_SCHERE, CardType.G_PAPIER, CardType.G_STEIN],
	CardType.SNAKE: [CardType.PAPIER, CardType.MAN, CardType.G_PAPIER, CardType.G_STEIN, CardType.G_MAN],
	CardType.G_SNAKE: [CardType.SNAKE, CardType.PAPIER, CardType.MAN, CardType.G_SCHERE, CardType.G_STEIN],
	CardType.G_SCHERE: [CardType.SCHERE, CardType.SNAKE, CardType.G_PAPIER, CardType.G_MAN, CardType.PAPIER],
	CardType.G_STEIN: [CardType.STEIN, CardType.SCHERE, CardType.G_SCHERE, CardType.G_SNAKE, CardType.MAN],
	CardType.G_PAPIER: [CardType.PAPIER, CardType.STEIN, CardType.G_STEIN, CardType.G_MAN, CardType.G_SNAKE],
	CardType.G_MAN: [CardType.MAN, CardType.STEIN, CardType.G_STEIN, CardType.G_SCHERE, CardType.SNAKE]
}

static func is_stone_type(card: int) -> bool:
	return card == CardType.STEIN or card == CardType.G_STEIN

static func is_paper_type(card: int) -> bool:
	return card == CardType.PAPIER or card == CardType.G_PAPIER
