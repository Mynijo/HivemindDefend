extends StaticBody


onready var Global_controls = get_node("/root/GlobalControls")
# Called when the node enters the scene tree for the first time.
func _ready():
    #check_floor()
    pass

func check_floor():
    if self.translation.y *-1 == Global_controls.actual_floor or self.translation.y *-1 == Global_controls.actual_floor +1:
        self.visible = true
    else:
        self.visible = false
        
        