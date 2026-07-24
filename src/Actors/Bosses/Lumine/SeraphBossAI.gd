extends "res://src/Actors/Bosses/BossAI.gd"



const rays: = 0
const dive: = 1
const blast: = 2
const tackle: = 3

func guarantee_all_attacks_on_start():
	order_of_attacks = [
	rays, dive, tackle, blast, blast, dive, 
	rays, dive, blast, tackle, tackle, blast, 
	rays, blast, tackle, dive, dive, tackle, 
	rays, tackle, dive, blast, blast, dive, 
	rays, dive, blast, tackle, tackle, blast, 
	rays, blast, tackle, dive, dive, tackle, 
	rays, tackle, dive, blast, blast, dive, 
	rays, dive, blast, tackle, tackle, blast, 
	rays, blast, tackle, dive, dive, tackle, 
	rays, tackle, dive, blast, blast, dive, 
	rays, dive, blast, tackle, tackle, blast, 
	rays, blast, tackle, dive, dive, tackle, 
	rays, tackle, dive, blast, blast, dive, 
	rays, tackle, tackle, blast, 
	rays, blast, blast, dive]
	
	
	
	
	pass
