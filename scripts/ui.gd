extends Control

#svět
@onready var game_node = get_tree().get_root().get_node("Game")

#budovy
@onready var powerStation_scene = preload("res://scenes/power_station.tscn")

#var buildings
var placing_building:bool = false
var selected_building
var can_build:bool = true

#Materials
@onready var cannotBuild_overlay: = preload("res://assets/materials/Power-Station_CANNOTBUILD.material")
@onready var canBuild_overlay = preload("res://assets/materials/Power-Station_CANBUILD.material")

#ui
var ui_panel

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
	
	if placing_building == false: # pokd neselektuju zadnou budovu
		ray_query.collide_with_areas =true # ray paprsek koliduje s area3d
	
	return space.intersect_ray(ray_query) # vrati s cim ray paprsek colidoval
func _on_power_station_button_pressed() -> void:
	var powerStation = powerStation_scene.instantiate()
	add_child(powerStation)
	placing_building = true
	selected_building = powerStation
	selected_building.get_node("MeshInstance3D").set_material_overlay(canBuild_overlay) # zmeni material overlay
	ui_panel = $"Basic_UI/bot-right_panel/buildings/powerStation_panel"
func _input(event: InputEvent) -> void:
	mouse_raycast()
	if Input.is_action_just_pressed("mouse-left_click"):
		mouse_raycast()
		print(mouse_raycast().collider)
		#Place building
		if placing_building == true: # pokud placeuju budovu
			place_building()
		if placing_building == false: # pokud neplaceuju budovu
			if mouse_raycast().collider is Area3D: # pokud ray paprsek colidoval s Area3d
				#Use building
				if mouse_raycast().collider.is_in_group("buildings"): # pokud area3d je v groupe buildings	
					if selected_building == null: # pokud neni selektnuta zadna budova
						selected_building = mouse_raycast().collider.get_parent().get_parent()
						ui_panel.visible = true
						selected_building.get_node("MeshInstance3D/selected_ring").visible = true# zapne viditelnost ringu dane budovy
				#PROVIZORNI BUILD JEDNOTKA 
				if mouse_raycast().collider.is_in_group("test"):
					if selected_building == null:
						selected_building = mouse_raycast().collider.get_parent().get_parent()
						ui_panel = $"Basic_UI/bot-right_panel/units/build-unit_panel"
						ui_panel.visible = true
			#Hide/close building
			if mouse_raycast().collider is StaticBody3D:
				if selected_building != null: #pokud placuju budovu
					if ui_panel != null: 
						ui_panel.visible = false
						selected_building.get_node("MeshInstance3D/selected_ring").visible = false
						selected_building = null # budova se neselektuje 
			#Select building
						
			
func _physics_process(delta: float) -> void:
	if placing_building == true: # pokud se selektuje budova
		selected_building.global_position = mouse_raycast().position # global pozice budovy se da na raycast pozici mysi

func place_building() -> void:
	if can_build == true:
		placing_building = false #budova se da na lokaci mysi
		selected_building.get_node("MeshInstance3D").set_material_overlay(null) # zmeni na normal barvu
		selected_building = null;
func _on_prop_area_3d_area_entered(area: Area3D) -> void: # kdyz budova entrne
	can_build = false
	print(can_build)
	selected_building.get_node("MeshInstance3D").set_material_overlay(cannotBuild_overlay) #zmeni overlay
	

func _on_prop_area_3d_area_exited(area: Area3D) -> void: # kdyz budova exitne
	can_build = true
	print(can_build)
	selected_building.get_node("MeshInstance3D").set_material_overlay(canBuild_overlay) # zmeni overlay 
