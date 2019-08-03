extends Node

var selectionMode = true
var selectionMode_flag = false

var actual_floor = 0
var floor_max_deeps = 5

onready var cam = get_node("/root/Map/CamBase")

func _ready():
    pass
    
func _input(event):    
    if event.is_action_pressed("floor_up") and actual_floor -1 >= 0:
        actual_floor -= 1
        print(actual_floor," max:",floor_max_deeps)
        get_tree().call_group("block", "check_floor")
    if event.is_action_pressed("floor_down") and actual_floor +1 < floor_max_deeps:
        actual_floor += 1
        print(actual_floor," max:",floor_max_deeps)
        get_tree().call_group("block", "check_floor")