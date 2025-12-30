extends Control
class_name CardSlot

var middle_position: Vector2 = self.global_position + scale * size / 2.0

func _ready() -> void:
	if !is_in_group("card_slots"):
		add_to_group("card_slots")

func _draw() -> void:
	draw_circle(middle_position, 2.0, Color.WHITE, true)

## TODO: Still a bit weird clicking wise in player's hands.
## TODO: Optimize code with adding and removing from arrays.
func snap_drag() -> void:
	## If slot is occupied, do nothing:
	if self.get_child_count() == 2:
		return
	## If slot is empty, snap to slot and change to occupied:
	if self.get_child_count() == 1:
		#for card: CardItem in all_cards:
		for card: CardItem in get_tree().get_nodes_in_group("card_drawn"):
			# Cards not in slot
			if !self.get_global_rect().has_point(card.global_position + scale * size / 2.0):
				if Gacha.player_deck.has(card):
					Gacha.player_deck.erase(card)
				if !Gacha.unclaimed_hand.has(card):
					Gacha.unclaimed_hand.append(card)
					#print("not in slot: %s" % str(Gacha.unclaimed_hand))
			# Card in slot
			if self.get_global_rect().has_point(card.global_position + scale * size / 2.0):
				card.reparent(self)
				card.following_mouse = false
				card.global_position = self.global_position
				#card.selected = false
				if !Gacha.player_deck.has(card):
					Gacha.player_deck.append(card)
				if Gacha.unclaimed_hand.has(card):
					Gacha.unclaimed_hand.erase(card)
					#print("card in slot: %s" % str(Gacha.unclaimed_hand))

func clear() -> void:
	while get_child_count() == 2:
		var child: Control = get_child(1) 
		remove_child(child)
		child.queue_free()







			#print(card)
			## Cards not in slot
			#if !self.get_global_rect().has_point(card.global_position):
				#if Gacha.player_deck.has(card):
					#Gacha.player_deck.erase(card)
				#if !Gacha.unclaimed_hand.has(card):
					#Gacha.unclaimed_hand.append(card)
					#print("not in slot: %s" % str(Gacha.unclaimed_hand))
			## Card in slot
			#if self.get_global_rect().has_point(card.global_position):
				#card.reparent(self)
				#card.following_mouse = false
				#card.global_position = self.global_position
				##card.selected = false
				#if !Gacha.player_deck.has(card):
					#Gacha.player_deck.append(card)
				#if Gacha.unclaimed_hand.has(card):
					#Gacha.unclaimed_hand.erase(card)
					#print("card in slot: %s" % str(Gacha.unclaimed_hand))
