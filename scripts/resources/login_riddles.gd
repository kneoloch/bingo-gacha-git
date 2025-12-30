extends Resource
class_name LoginRiddles

var riddles_dict: Dictionary = {
	#password_string: hint
	"stanloona": "stan _ _ _ _ _ (9)",
	"seriousweakness": "amyra WILL finish this book 2026",
	"ed": "the secret third thing: _ _ (2)",
	"taemin": "he's normal now actually, which is a shame, get worse pls!",
	"loveme": "_ _ _ _  _ _ _ (6) for 10000 years",
	"areyouchinese": "pov: you're dming kastel for the toxic yuri game jam",
	"normie": "a slur and/or a positional operant to refer to the masses (6)",
	"[real]": "peep TV show REALity in brackets (6)",
	"scorpio": "zodiac for 2/4 of the eunuchs",
	"femcel": "'the menocide could not come sooner,' said the _ _ _ _ _ _ (6)",
	"kyirth": "a wretched woman giving birth (6)",
	"9/11": "the year is 2001 in ny: _ / _ _ (4)",
	"dmv": "the eunuchs' spawn area (3)",
	"myshitisass": "when you look back at your work and it sucks so bad (11)",
	"womb": "return to the _ _ _ _ (4)",
	"thepurpleline": "construction project pending til 20XX (13)",
	"wasians": "there's an enclosure in the westoid zoo marked just for them (7)",
	"bandislife": "let's all go quit our jobs and start a band! how does the slogan go? (10)",
}

func pick_random() -> Variant:
  var random_riddle = riddles_dict.keys().pick_random()
  return random_riddle
