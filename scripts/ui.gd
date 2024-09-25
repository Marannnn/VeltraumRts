extends Control

#budovy
@onready var powerStation_scene = preload("res://scenes/power_station.tscn")

#svět
@onready var game_node = get_tree().get_root().get_node("Game")

#var buildings
var selecting_building:bool = false
var selected_building

func mouse_raycast():
	var camera = $Camera3D # odkazuje na camera3d
	var mouse_pos = get_viewport().get_mouse_position() # vezmu pozici myši ve viewportu
	var ray_length = 100 # nastavim delku raycastu
	var from = camera.project_ray_origin(mouse_pos) # raycast se spawne z kamera na pozici mysi
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length #raycast poleti do pozice mysi na viewportu 100 jednotek
	var space = game_node.get_world_3d().direct_space_state # svet ve kterym se to castne
	var ray_query = PhysicsRayQueryParameters3D.create(from,to,1) # novy paprsek, koliduje s layer 1
	ray_query.from = from
	ray_query.to = to
	
	if selecting_building == false: # pokd neselektuju zadnou budovu
		ray_query.collide_with_areas =true # ray paprsek koliduje s area3d
	
	return space.intersect_ray(ray_query) # vrati s cim ray paprsek colidoval
func _on_power_station_button_pressed() -> void:
	var powerStation = powerStation_scene.instantiate()
	add_child(powerStation)
	selected_building = powerStation
	selecting_building = true
func _input(event: InputEvent) -> void:
	mouse_raycast()
	if Input.is_action_just_pressed("mouse-left_click"):
		mouse_raycast()
		print(mouse_raycast().collider)
		if selecting_building == true: # pokud selectuju budovu
			selecting_building = false # selektovani se da false = budova zustane na miste, prestane nasledovat mys
		if selecting_building == false: # pokud neselektuju budovu
			if mouse_raycast().collider is Area3D: # pokud ray paprsek colidoval s Area3d
				if mouse_raycast().collider.is_in_group("buildings"): # pokud area3d je v groupe buildings
					if selected_building != null:
						selected_building.get_parent().get_node("selected_ring").visible = true
			
func _physics_process(delta: float) -> void:
	if selecting_building == true: # pokud se selektuje budova
		selected_building.global_position = mouse_raycast().position # global pozice budovy se da na raycast pozici mysi
