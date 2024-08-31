extends Node3D

## Draws points in 3D space with given parameters
## Position is required, radius defaults to .05, color defautls to LAWN_GREEN, persistTime defaults to 1
func point(pos: Vector3, radius: float = .05, color: Color = Color.LAWN_GREEN, persistTime: float = 1) -> void:
	# Create mesh objects
	var meshInstance: MeshInstance3D = MeshInstance3D.new()
	var sphereMesh: SphereMesh = SphereMesh.new()
	var material: ORMMaterial3D = ORMMaterial3D.new()
	# Construct mesh objects together
	meshInstance.mesh = sphereMesh
	# Keep mesh from casting shadows and set position
	meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	meshInstance.position = pos
	# Set mesh configurations
	sphereMesh.radius = radius
	sphereMesh.height = radius * 2
	sphereMesh.material = material
	await _finalizeAndClean(meshInstance, material, persistTime, color)

## Draws a line between the two given points with the given parameters
## Pos1 and pos2 ar required, color defaults to AQUA, persistTime defaults to 1
func line(pos1: Vector3, pos2: Vector3, color: Color = Color.AQUA, persistTime: float = 1) -> void:
	# Create mesh objects
	var meshInstance: MeshInstance3D = MeshInstance3D.new()
	var immediateMesh: ImmediateMesh = ImmediateMesh.new()
	var material: ORMMaterial3D = ORMMaterial3D.new()
	# Construct mesh objects together and keep mesh from casting shadows
	meshInstance.mesh = immediateMesh
	meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Set position where material begins and ends
	immediateMesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediateMesh.surface_add_vertex(pos1)
	immediateMesh.surface_add_vertex(pos2)
	immediateMesh.surface_end()
	await _finalizeAndClean(meshInstance, material, persistTime, color)

## Draws a bezier curve between origin and destination
func curve(start: Vector3, startControl: Vector3, endControl: Vector3, end: Vector3, pointCount: int = 20, color: Color = Color.RED, persistTime: float = 1,) -> void:
	# TODO Is there a way to extend this beyond the destination?
	#		If so make extension an optional parameter
	var curvePath: Array = []
	
	for n in pointCount + 1:
		curvePath.append(start.bezier_interpolate(startControl, endControl, end, (n * (1.0/float(pointCount)))))
	for n in (pointCount):
		DrawUtil.line(curvePath[n], curvePath[n + 1], color, persistTime)

func getRandomPoint(minRange: float, maxRange: float) -> Vector3:
	var randOne := randf_range(minRange, maxRange)
	var randTwo := randf_range(minRange, maxRange)
	var randThree := randf_range(minRange, maxRange)
	return Vector3(randOne, randTwo, randThree)

## Adds color and shading to material, adds mesh to scene, 
## and sets mesh to cleanup after given persist time
func _finalizeAndClean(meshInstance: MeshInstance3D, material: ORMMaterial3D, persistTime: float, color: Color) -> void:
	# Configure material color and to not take shadows
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	# Add the mesh instances to the parent root at given position
	get_tree().get_root().add_child(meshInstance)
	if persistTime == 1:
		await get_tree().physics_frame
		meshInstance.queue_free()
	elif persistTime > 0:
		await get_tree().create_timer(persistTime).timeout
		meshInstance.queue_free()
