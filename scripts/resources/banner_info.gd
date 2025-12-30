extends Resource
class_name BannerInfo

enum BannerDrop {AMYRA, JOEY, KMOR, V, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
enum Banner {STANDARD, WILD, SPECIAL, AMYRA, JOEY, KMOR, V}

## BANNER TEXTURES
const SMASH_THE_WORLD_SHELL = preload("uid://dqj0ofh5ppwgb") ## STANDARD
const SUKEKIYO_EROSIO = preload("uid://2g0l1gh8a40n") ## AMYRA
const SUKEKIYO_EROSIO_2023 = preload("uid://cn1icabd2luqw")
const PRAY_FOR_ME_MACHINE = preload("uid://dycgp3ng4crid")

const standard_one: Dictionary = {
	BannerDrop.AMYRA: 3,
	BannerDrop.JOEY: 3,
	BannerDrop.KMOR: 3,
	BannerDrop.V: 3,
	BannerDrop.COMMON: 46.5,
	BannerDrop.UNCOMMON: 28.5,
	BannerDrop.RARE: 8,
	BannerDrop.EPIC: 4.5,
	BannerDrop.LEGENDARY: 0.5
}

const standard_ten: Dictionary = {
	BannerDrop.AMYRA: 4.5,
	BannerDrop.JOEY: 4.5,
	BannerDrop.KMOR: 4.5,
	BannerDrop.V: 4.5,
	BannerDrop.COMMON: 37.5,
	BannerDrop.UNCOMMON: 25.8,
	BannerDrop.RARE: 12.5,
	BannerDrop.EPIC: 5.5,
	BannerDrop.LEGENDARY: 0.7
}

const amyra_one: Dictionary = {
	BannerDrop.AMYRA: 6,
	BannerDrop.JOEY: 3,
	BannerDrop.KMOR: 3,
	BannerDrop.V: 3,
	BannerDrop.COMMON: 45.5,
	BannerDrop.UNCOMMON: 27.5,
	BannerDrop.RARE: 7,
	BannerDrop.EPIC: 4.5,
	BannerDrop.LEGENDARY: 0.5
}

const amyra_ten: Dictionary = {
	BannerDrop.AMYRA: 10,
	BannerDrop.JOEY: 4.5,
	BannerDrop.KMOR: 4.5,
	BannerDrop.V: 4.5,
	BannerDrop.COMMON: 35,
	BannerDrop.UNCOMMON: 24.8,
	BannerDrop.RARE: 11,
	BannerDrop.EPIC: 5,
	BannerDrop.LEGENDARY: 0.7
}

const joey_one: Dictionary = {
	BannerDrop.AMYRA: 3,
	BannerDrop.JOEY: 6,
	BannerDrop.KMOR: 3,
	BannerDrop.V: 3,
	BannerDrop.COMMON: 45.5,
	BannerDrop.UNCOMMON: 27.5,
	BannerDrop.RARE: 7,
	BannerDrop.EPIC: 4.5,
	BannerDrop.LEGENDARY: 0.5
}

const joey_ten: Dictionary = {
	BannerDrop.AMYRA: 4.5,
	BannerDrop.JOEY: 10,
	BannerDrop.KMOR: 4.5,
	BannerDrop.V: 4.5,
	BannerDrop.COMMON: 35,
	BannerDrop.UNCOMMON: 24.8,
	BannerDrop.RARE: 11,
	BannerDrop.EPIC: 5,
	BannerDrop.LEGENDARY: 0.7
}

const kmor_one: Dictionary = {
	BannerDrop.AMYRA: 3,
	BannerDrop.JOEY: 3,
	BannerDrop.KMOR: 6,
	BannerDrop.V: 3,
	BannerDrop.COMMON: 45.5,
	BannerDrop.UNCOMMON: 27.5,
	BannerDrop.RARE: 7,
	BannerDrop.EPIC: 4.5,
	BannerDrop.LEGENDARY: 0.5
}

const kmor_ten: Dictionary = {
	BannerDrop.AMYRA: 4.5,
	BannerDrop.JOEY: 4.5,
	BannerDrop.KMOR: 10,
	BannerDrop.V: 4.5,
	BannerDrop.COMMON: 35,
	BannerDrop.UNCOMMON: 24.8,
	BannerDrop.RARE: 11,
	BannerDrop.EPIC: 5,
	BannerDrop.LEGENDARY: 0.7
}

const v_one: Dictionary = {
	BannerDrop.AMYRA: 3,
	BannerDrop.JOEY: 3,
	BannerDrop.KMOR: 3,
	BannerDrop.V: 6,
	BannerDrop.COMMON: 45.5,
	BannerDrop.UNCOMMON: 27.5,
	BannerDrop.RARE: 7,
	BannerDrop.EPIC: 4.5,
	BannerDrop.LEGENDARY: 0.5
}

const v_ten: Dictionary = {
	BannerDrop.AMYRA: 4.5,
	BannerDrop.JOEY: 4.5,
	BannerDrop.KMOR: 4.5,
	BannerDrop.V: 10,
	BannerDrop.COMMON: 35,
	BannerDrop.UNCOMMON: 24.8,
	BannerDrop.RARE: 11,
	BannerDrop.EPIC: 5,
	BannerDrop.LEGENDARY: 0.7
}

#var wild: Dictionary = {
	#BannerDrop.AMYRA: randf_range(3, 10),
	#BannerDrop.JOEY: randf_range(3, 10),
	#BannerDrop.KMOR: randf_range(3, 10),
	#BannerDrop.V: randf_range(3, 10),
	#BannerDrop.COMMON: randf_range(10, 15.5),
	#BannerDrop.UNCOMMON: randf_range(10, 12),
	#BannerDrop.RARE: randf_range(5, 11.5),
	#BannerDrop.EPIC: randf_range(4, 11),
	#BannerDrop.LEGENDARY: randf_range(0.5, 10)
#}

func get_banner_texture(selected_banner: Banner) -> void:
	var banner_texture: CompressedTexture2D = null
	match selected_banner:
		Banner.STANDARD:
			banner_texture = SMASH_THE_WORLD_SHELL
		Banner.AMYRA:
			banner_texture = SUKEKIYO_EROSIO
		Banner.JOEY:
			banner_texture = PRAY_FOR_ME_MACHINE
	Gacha.selectBanner.emit(selected_banner, banner_texture)
