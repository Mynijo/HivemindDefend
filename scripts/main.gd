extends Spatial

onready var Global_controls = get_node("/root/GlobalControls")

func _ready():
    for i in range(Global_controls.floor_max_deeps):
        generate_floor(10,10,i)
        
    generate_floor(50,50,Global_controls.floor_max_deeps,Vector2(0,0),true)
    

func generate_floor(var width, var length, var deeps, var offset = Vector2(0,0), var bottom_flag = false):
    var dirtBlock = load("res://mapTiles/blockDirt.tscn")
    var Bedrock = load("res://mapTiles/Bedrock.tscn")
    for i in width:
        for n in length:
            var temp_Block
            if i == 0 or n == 0 or i == width -1 or n == length -1 or bottom_flag:
                temp_Block = Bedrock.instance()
            else:
                temp_Block = dirtBlock.instance()
            temp_Block.translation = Vector3(i + offset.x,deeps * -1, n + offset.y)
            self.add_child(temp_Block)