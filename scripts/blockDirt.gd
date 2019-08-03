extends StaticBody

var mouse_entered = false
var selected = false

onready var Global_controls = get_node("/root/GlobalControls")
# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _input(event):
    if event.is_action_pressed("mouse_click_left"):
        if mouse_entered:
            print("got it")
            toggle_selection(not selected)
    if event.is_action_released("mouse_click_left"):
        Global_controls.selectionMode_flag = false

func _on_blockDirt_mouse_entered():
    mouse_entered = true
    if Input.is_action_pressed("mouse_click_left"):
        toggle_selection(not selected)


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

        
        
        