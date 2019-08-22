extends Node


const MAP_SIZE = Vector3(20 + 2, 20 + 2, 20 + 2)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func generate_map(map_generation_file_path : String, mesh_library : MeshLibrary):
    var map_size = MAP_SIZE
    var map_nodes = {}
    var block_id : int
    var block : String
    for x in range(map_size.x):
        for y in range(map_size.y):
            for z in range(map_size.z):
                if z == map_size.z - 1:
                    # Top of the world
                    block = "TopAir"
                elif x == 0 or y == 0 or z == 0 or x == map_size.x - 1 or y == map_size.y - 1:
                    # Border
                    block = "Bedrock"
                else:
                    # Make a dirt qube
                    block = "Dirt"
                #block_id = mesh_library.find_item_by_name(block)
                map_nodes[Vector3(x, y, z)] = {
                    active = False,
                    block = block
                    }