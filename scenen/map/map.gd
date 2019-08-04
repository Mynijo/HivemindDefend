extends StaticBody


var map = []


func _ready():    
    pass
                
func ini_map(map_size : Vector3):
    for x in range(map_size.x):
        map[x].append([])
        for y in range(map_size.y):
            map[x][y].append([])
            for z in range(map_size.z):
                map[x][y][z].append(StaticBody)
                
func get_map_node(position : Vector3) -> StaticBody:
    return map[position.x][position.y][position.z]