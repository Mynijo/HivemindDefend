extends "res://scripts/block.gd"

var mouse_entered = false
var selected = false

func _ready():
    pass

func _input(event):
    if event.is_action_pressed("mouse_click_left"):
        if mouse_entered:
            print("got it")
            toggle_selection(not selected)
    if event.is_action_released("mouse_click_left"):
        Global_controls.selectionMode_flag = false
    if event.is_action_pressed("mouse_click_right"):
        if mouse_entered and self.translation.y *-1 == Global_controls.actual_floor:
            queue_free()
        
func _on_blockDirt_mouse_entered():
    mouse_entered = true
    if Input.is_action_pressed("mouse_click_left"):
        toggle_selection(not selected)
    if Input.is_action_pressed("mouse_click_right"):
        if mouse_entered and self.translation.y *-1 == Global_controls.actual_floor:
            queue_free()


func _on_blockDirt_mouse_exited():
    mouse_entered = false
    if Input.is_action_pressed("mouse_click_left"):
        Global_controls.selectionMode_flag = true
        Global_controls.selectionMode = selected
    
func toggle_selection(var flag):
    if  Global_controls.selectionMode_flag:
        flag = Global_controls.selectionMode
    selected = flag     
    self.get_node("blockDirt(Clone)").visible = not flag
    self.get_node("selected").visible = flag
    print(self.translation.y)
        
        