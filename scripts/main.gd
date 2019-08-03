extends Spatial


func _ready():
    generate_floor(10,10,1)
    generate_floor(10,10,2)
    generate_floor(10,10,3)

func generate_floor(var width, var length, var deeps):
    var dirtBlock = load("res://mapTiles/blockDirt.tscn")
    for i in width:
        for n in length:
            var temp_dirtBlock = dirtBlock.instance()
            print(i,deeps * -1, n)
            temp_dirtBlock.translation = Vector3(i,deeps * -1, n)
            self.add_child(temp_dirtBlock)