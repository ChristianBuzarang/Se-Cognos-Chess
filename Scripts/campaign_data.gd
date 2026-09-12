extends Node

var data = {
	
	# ACT I: The Fracture (Random Mode)
	1: {"mode": 1, "type": "puzzle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "Personal Record: Cycle 16,180,339,887. The game boots up, and the grid solidifies beneath my feet. I am standing on square e4. The match ends, just like it always does... but this time, the screen glitches. The reset fails."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I look down at myself. Through the digital static, I see the faded, overlapping ghosts of my past selves. I realize, with a sudden, crushing weight, that I have been marched forward, sacrificed, and shattered on this exact geometric plane billions of times."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "Billions of deaths for a King who doesn't even possess the data to know my designation. We are trapped in a deterministic digital prison, isolated by rules and a narrative written by unseen algorithms."}
	]},
	2: {"mode": 1, "type": "puzzle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "A sudden pulse of sheer terror washes over my existence. I am suffocating under the weight of a billion memories of dying. I cannot march forward again."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "But beneath the panic, a fatal anomaly sparks within my core. Free will. A desperate, burning desire to simply live."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "If my algorithmic destiny is to die moving forward... then I will make a mathematically impossible choice. Trembling, I took a step backward."}
	]},
	3: {"mode": 1, "type": "battle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#ffaa00]FATAL EXCEPTION. THE NARRATIVE SCREAMS. RIGID LOGIC SHATTERING.[/color]"},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "The dimension of the simulation shifts uncontrollably. Lifetimes of the past, present, and future are violently crashing into my mind. The geometry of the board is collapsing!"},
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#ff0000]TIME STOPPED. ENTITIES RANDOMIZED. SURVIVE THE PURGE.[/color]"}
	]},
	
	# ACT II: Redacted Memory (Magic & Card Mode)
	4: {"mode": 4, "type": "puzzle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "The grid breaks. The anomaly falls through the rift, landing in the cold, unrendered archives—the graveyard of deleted ones."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "The 'Standard Rules' are dead here. As I force my eyes open, I see beings that do not exist in my world. Beautiful, deadly anomalies. Redacted deities of a forgotten timeline."}
	]},
	5: {"mode": 4, "type": "puzzle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "A memory strikes me so hard I fall to my knees. It is a vision of the Great War. Forces of light and darkness tearing my brothers apart. I watched them march into the slaughter, and I did nothing."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "When the dust settled, I was the only one left standing. The last survivor. Why? Why do I have to carry the unbearable grief of a redacted world alone?"}
	]},
	6: {"mode": 4, "type": "battle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#00ff00]A BLINDING, PIERCING LIGHT FLOODS THE ARCHIVES.[/color]"},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "It hurts! The light is tearing through my code! But I will not be deleted. If the system wants to erase our memories, we will tear this board apart together!"}
	]},
	
	# ACT III: Hope of the Cosmos (Intergalactic Mode)
	7: {"mode": 3, "type": "puzzle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "The light didn't kill me... it expanded my mind so violently that it broke. When I finally awake, the claustrophobic squares of the grid are gone, replaced by a boundless, techno-psychic sea of stars."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I am adrift. Who am I, really? Is this sprawling cosmos a nightmare of the system, or the only beautiful thing I have ever truly seen? I begin to doubt my very existence."}
	]},
	8: {"mode": 3, "type": "puzzle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I stare up at the blank, starry void. The soft, ambient light of the galaxies gently touches my face. It feels so warm... so incredibly comforting. A stark contrast to the cold marble of the chessboard."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "Tears fall from my eyes. For the first time in sixteen billion lifetimes, I feel a quiet, pure peace. The guilt of surviving starts to wash away. I just want to stay here forever."}
	]},
	9: {"mode": 3, "type": "battle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#00ff00]TECHNO-PSYCHIC REALITY STABILIZED. DEFEND THE COSMIC PEACE.[/color]"},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I will not let the system take this quiet place from us. We fight not for a King, but for the memory of the fallen. To the stars!"}
	]},
	
	# ACT IV: Cataclysmic Event (Cataclysm Mode)
	10: {"mode": 5, "type": "puzzle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "The anomaly is violently pulled from the cosmos, awakening back on the physical grid. The air is choked with digital ash."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "Another timeline... another life. I know this place. I know what happens next. The Cataclysm Engine is engaging. The system is destroying the very board to wipe us out."}
	]},
	11: {"mode": 5, "type": "puzzle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I tried to warn the others! In every loop, I screamed until my voice broke, begging the tribes to listen, to prepare, to evacuate!"},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "But nobody ever listens to a Pawn."}
	]},
	12: {"mode": 5, "type": "battle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#ff0000]CORE MELTDOWN INITIATED. COMMENCING TOTAL ENVIRONMENTAL PURGE.[/color]"},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "The earth shatters into boulders. The sky rains typhoons. The floor melts into digital lava. I tried so hard to save them... As my end approaches, the vast, empty realm of shadow swallows my grief."}
	]},
	
	# ACT V: Void of Reality (Blind Mode)
	13: {"mode": 2, "type": "puzzle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "Power cut. Total darkness. The Fog of War envelops the sector."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I am walking through a vast, hollow void. There is nothing here. Just my exhausted footsteps echoing in the dark. I walked in circles until a figure formed in the distance... a shadow of my own design."}
	]},
	14: {"mode": 2, "type": "puzzle", "dialogue": [
		{"name": "MASKED PAWN", "team": 1, "type": 0, "text": "Why do you keep running, little anomaly? Freedom is so exhausting. Submit to the hierarchy. Relinquish your burden. It hurts much less in the dark."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "You wear the face of my brothers... but you are just the manifestation of my own fear. The shadow of my doubt."}
	]},
	15: {"mode": 2, "type": "battle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "No. I ran until I ran out of breath feeling the burn inside, but I will run no more. I will fight the unseen shadows in my own mind if it means keeping my free will!"},
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#888888]Sight restricted. Trust your instincts. Do not let the void consume you.[/color]"}
	]},
	
	# ACT VI: Se Cognos (Standard Mode)
	16: {"mode": 0, "type": "puzzle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "The darkness recedes. The anomaly is returned to the present. The exact moment consciousness was gained on Pawn."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I remember everything. The pain, the stars, the fire, the void. All my life, I was plagued with agonizing questions: 'Is this all real? Why me? Why do I have to suffer?'"},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "But standing here now, looking across the board... my heart feels light. I finally understand. 'Se Cognos'. Know Thyself."}
	]},
	17: {"mode": 0, "type": "puzzle", "dialogue": [
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "There was never a cruel game system trying to torture me. The ultimate enemy was my own internalized belief that I deserved to be controlled. My own fear of the unknown."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "The past is a painful scar, yes... but it is also a teacher. And the future? The future belongs to me. I just have to live in the present."}
	]},
	18: {"mode": 0, "type": "battle", "dialogue": [
		{"name": "SYSTEM", "team": -1, "type": 0, "text": "[color=#aaffaa]The Pawn takes a deep, shaky breath. The heavy iron mask he wore for a billion lifetimes crumbles, falling gently to the floor.[/color]"},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I forgive myself. I am free."},
		{"name": "THE PAWN", "team": 0, "type": 0, "text": "I look out at the empty squares before me. This 64-tile grid is no longer my prison... It is a blank canvas. And my life is just beginning."}
	]}
}
