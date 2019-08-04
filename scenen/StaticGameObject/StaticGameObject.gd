extends StaticBody

var selected = false
var life_actual  = 42
var life_max  = 42    
var is_selectable_flag = true


func _ready():
    pass # Replace with function body.

func is_selectable() -> bool:
    return is_selectable_flag
    
func select(flag):
    pass

func get_life_actual() -> int:
    return life_actual
    
func get_life_max()  -> int:
    return life_max
    
func apply_damage(damage : int) -> int:
    life_actual -= damage
    return life_actual
    
func apply_heal(heal : int) -> int:
    life_actual += heal
    if life_actual > life_max:
        life_actual = life_max
    return life_actual
    
func get_position() -> Vector3:
    return self.translation
    
func set_position(position : Vector3):
    self.translation = position     