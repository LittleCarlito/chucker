extends Node3D

# TODO See about having this run in low priority thread

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
	_finalizeAndClean(meshInstance, material, persistTime, color)

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
	_finalizeAndClean(meshInstance, material, 1, color)

## Draws a bezier curve between origin and destination
## origin, originOut, destination, and destinationIn are required, color defaults to RED, persist time defaults to 1
func curve(origin: Vector3, originOut: Vector3, destination: Vector3, destinationIn: Vector3, color: Color = Color.RED, persistTime: float = 1) -> void:
	var meshInstance: MeshInstance3D = MeshInstance3D.new()
	var immediateMesh: ImmediateMesh = ImmediateMesh.new()
	var material: ORMMaterial3D = ORMMaterial3D.new()
	# Construct mesh objects together and keep mesh from casting shadows
	meshInstance.mesh = immediateMesh
	meshInstance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Create curve object
	var curve: Curve3D = Curve3D.new()
	# Set origin and destination as well as their approaches
	curve.add_point(origin)
	curve.set_point_out(0, originOut)
	curve.add_point(destination)
	curve.set_point_in(1, destinationIn)
	# Bake and tessellate to make curve generation manageable
	#curve.bake_interval = .5
	curve.tessellate()
	# Retrieve points of the curve at the baked interval
	var curvePoints: PackedVector3Array = curve.get_baked_points()
	# Draw the curve using the retrieved points
	var pointCount = curvePoints.size()
	for n in (pointCount - 1):
		line(curvePoints[n], curvePoints[n + 1])

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
