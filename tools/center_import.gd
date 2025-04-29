@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
	var aabb: AABB = calculate_aabb(scene)
	
	var children = scene.get_children()
	var center: Node3D = Node3D.new()
	center.name = "Pivot"
	
	var center_point = aabb.get_center()
	center_point.y = 0
	center.position = -center_point
	scene.add_child(center)
	center.owner = scene
	
	for child in children:
		if not child is Node3D:
			continue
		child.owner = null
		scene.remove_child(child)
		center.add_child(child)
		child.owner = scene
	
	return scene

func calculate_aabb(scene: Node3D) -> AABB:
	var visual_instances: Array[Node] = scene.find_children("*", "VisualInstance3D")
	
	var current_aabb := AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	var first_aabb := true
	
	for instance: VisualInstance3D in visual_instances:
		var accum_xform := Transform3D()
		var base: Node3D = instance
		while base:
			accum_xform = base.transform * accum_xform
			base = base.get_parent()
		var aabb = accum_xform * instance.get_aabb()
		if first_aabb:
			current_aabb = aabb
			first_aabb = false
		else:
			current_aabb = current_aabb.merge(aabb)
	
	return current_aabb
