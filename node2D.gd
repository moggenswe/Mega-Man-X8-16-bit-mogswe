extends Node2D

export var entered_password: = "1111111111111111"
const even: = "1225977663272912"
const odd: = "1932729259776691"
const zero_all: = "46738766824328"

var password_being_tested: = "0000000000000000"

const A1 = "HermesHead"
const A2 = "HermesBody"
const A3 = "HermesArms"
const A4 = "HermesFeet"
const A5 = "IcarusHead"
const A6 = "IcarusBody"
const A7 = "IcarusArms"
const A8 = "IcarusFeet"

const L1 = "LifeUp1"
const L2 = "LifeUp2"
const L3 = "LifeUp3"
const L4 = "LifeUp4"
const L5 = "LifeUp5"
const L6 = "LifeUp6"
const L7 = "LifeUp7"
const L8 = "LifeUp8"

const S1 = "Subtank1"
const S2 = "Subtank2"
const S3 = "Subtank3"
const S4 = "Subtank4"

const X1 = "Intro"
const X2 = "Vile"
const X3 = "Zero"
const X4 = "Red"
const X5 = "Jacob"
const X6 = "Gateway"
const X7 = "Placeholder"

const B1 = "TroiaBase"
const B2 = "Primrose"
const B3 = "PitchBlack"
const B4 = "Dinasty"
const B5 = "BoosterForest"
const B6 = "CrystalMines"
const B7 = "CentralWhite"
const B8 = "Inferno"

const bosses = [B1, B2, B3, B4, B5, B6, B7, B8]
const key_locations = [[A1, B7, L5, S1, X1], [A2, B3, L4, S2, X2], 
								[A3, B6, L2, X3, X6], [A4, B2, L3, X4, X7], 
								[A5, B5, L1, S3, X5], [A6, B1, L8, L7, S4], 
								[A7, B4, B8, A8, L6]]

const keys = {"00": [], 
"03": [1], 
"05": [2], 
"13": [3], 
"17": [4], 
"31": [5], 
"08": [1, 2], 
"16": [1, 3], 
"20": [1, 4], 
"34": [1, 5], 
"18": [2, 3], 
"22": [2, 4], 
"36": [2, 5], 
"30": [3, 4], 
"44": [3, 5], 
"48": [4, 5], 
"21": [1, 2, 3], 
"25": [1, 2, 4], 
"39": [1, 2, 5], 
"33": [1, 3, 4], 
"47": [1, 3, 5], 
"51": [1, 4, 5], 
"35": [2, 3, 4], 
"49": [2, 3, 5], 
"53": [2, 4, 5], 
"61": [3, 4, 5], 
"38": [1, 2, 3, 4], 
"52": [1, 2, 3, 5], 
"56": [1, 2, 4, 5], 
"64": [1, 3, 4, 5], 
"66": [2, 3, 4, 5], 
"69": [1, 2, 3, 4, 5]}

var show_debug: = true

var no_of_tries = 0
onready var rng = RandomNumberGenerator.new()

var hey: = 0
var somatorio = []

func _ready() -> void :
	is_valid_password()
	pass

func test_random_password(no_of_tries) -> void :
	enter_random_password()

func enter_random_password() -> void :
	rng.randomize()
	var test_password = str(abs(rng.randi_range(111111111111, 999999999999)))
	entered_password = fix_size(test_password)

func crc() -> void :
	pass

func fix_size(test_password) -> String:
	if test_password.length() < 12:
		var times = 12 - test_password.length()
		while times > 0:
			test_password = test_password.insert(0, "0")
			times = times - 1
	return test_password

func is_valid_password() -> bool:
	var even_removed = remove_code(even)
	var odd_removed = remove_code(odd)
	
	debug("Entered: " + entered_password)
	debug("Even: " + even_removed)
	debug("Odd: " + odd_removed)
	
	password_being_tested = even_removed
	is_any_value_invalid(even_removed)
	is_no_of_defeated_bosses_valid("even")
	print_debug("Testing odd...")
	is_any_value_invalid(odd_removed)
	return false

func is_any_value_invalid(password) -> bool:
	var s1 = password.substr(0, 2)
	var s2 = password.substr(2, 2)
	var s3 = password.substr(4, 2)
	var s4 = password.substr(6, 2)
	var s5 = password.substr(8, 2)
	var s6 = password.substr(10, 2)
	var s7 = password.substr(12, 2)
	var s8 = password.substr(14, 2)
	var allkeys = [s1, s2, s3, s4, s5, s6, s7]
	
	
	for key in allkeys:
		if keys.get(key) == null:
			print_debug("Invalid value: " + key)
			return true
	print_debug("no invalid keys found")
	
	return false

func is_no_of_defeated_bosses_valid(param) -> bool:
	var total_bosses_defeated = 0
	
	var boss_locations = []
	for order in key_locations:
		for key in order:
			if key in bosses:
				boss_locations.append(Vector2(key_locations.find(order) * 2, order.find(key, 0) + 1))
	print(boss_locations)
	
	for location in boss_locations:
		var value_being_tested = password_being_tested.substr(location.x, 2)
		print_debug("Checking if value " + str(value_being_tested) + " is in key dictionary")
		if value_being_tested in keys:
			print_debug("Found in dictionary, checking if boss element is in place " + str(location.y))
			if location.y in keys[value_being_tested]:
				print_debug("Bingo!")
				total_bosses_defeated += 1
			else:
				
				pass
	
		
	print("Total bosses defeated: " + str(total_bosses_defeated))
	if total_bosses_defeated == 0 and param != "zero":
		print_debug("Didn't expect zero. Invalid password")
		return false
	
	if total_bosses_defeated % 2 != 0 and param == "even":
		debug("Was expecting even number, failed validation")
		return false
	if total_bosses_defeated % 2 == 0 and not param == "even":
		debug("Was expecting odd number, failed validation")
		return false
	debug("Valid number")
	return true


func remove_code(code) -> String:
	var s = sub_duples(entered_password.substr(0, 2), code.substr(0, 2)) + \
	sub_duples(entered_password.substr(2, 2), code.substr(2, 2)) + \
	sub_duples(entered_password.substr(4, 2), code.substr(4, 2)) + \
	sub_duples(entered_password.substr(6, 2), code.substr(6, 2)) + \
	sub_duples(entered_password.substr(8, 2), code.substr(8, 2)) + \
	sub_duples(entered_password.substr(10, 2), code.substr(10, 2)) + \
	sub_duples(entered_password.substr(12, 2), code.substr(12, 2)) + \
	sub_duples(entered_password.substr(14, 2), code.substr(14, 2))
	
	return s

func debug(message) -> void :
	if show_debug:
		print("Password: " + message)

func add_duples(value1, value2) -> String:
	return add(value1.substr(0, 1), value2.substr(0, 1)) + add(value1.substr(1, 1), value2.substr(1, 1))

func sub_duples(value1, value2) -> String:
	return subtract(value1.substr(0, 1), value2.substr(0, 1)) + subtract(value1.substr(1, 1), value2.substr(1, 1))
	

func add(value1, value2) -> String:
	var result = int(value1) + int(value2)
	
	if result >= 10:
		result = (str(result).substr(1, 1))
		
	return str(result)
	
func subtract(value1, value2) -> String:
	var result = int(value1) - int(value2)
	
	if result <= - 1:
		result = 10 + result
		
	return str(result)

	
	
	
	
	
	
	
	
	
	
