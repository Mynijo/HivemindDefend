extends StaticBody

var mouse_entered = false
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _input(event):
    if event.is_action_pressed("mouse_click_left"):
        if mouse_entered:
            print("got it")
            toggle_selection()

func _on_blockDirt_mouse_entered():
    mouse_entered = true


func _on_blockDirt_mouse_exited():
    mouse_entered = false
    
func toggle_selection():
    if selected:
        selected = false        
        self.get_node("blockDirt(Clone)").visible = true
        self.get_node("selected").visible = false
    elif not selected:
        selected = true
        self.get_node("blockDirt(Clone)").visible = false
        self.get_node("selected").visible = true
        
        