extends Node3D

class_name Draw3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Draws a line between the two given points with the given parameters
## Pos1 and pos2 ar required, color defaults to AQUA, persist time (ms) defaults to 0
func line(pos1: Vector3, pos2: Vector3, color: Color = Color.AQUA, persistTime: float = 0):
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
	# Configure material color and to not take shadows
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	# Add the mesh instances to the parent root at given position
	# TODO Get to asset management dictionary
	get_node("root/FirstHole/DrawUtil").add_child(meshInstance)


## Draws points in 3D space with given parameters
## Position is required, radius defaults to .05, color defautls to LAWN_GREEN
func point(pos: Vector3, radius: float = .05, color: Color = Color.LAWN_GREEN):
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
	# Set material color and keep it from having shadows cast on it
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	# Add the mesh instances to the parent root at given position
	# TODO Get to asset management dictionary
	get_node("root/FirstHole/DrawUtil").add_child(meshInstance)

## Adds the 
func finalizeAndClean(meshInstance: MeshInstance3D, persistTime: float):
	pass

func getRandomPoint(minRange: float, maxRange: float) -> Vector3:
	var randOne := randf_range(minRange, maxRange)
	var randTwo := randf_range(minRange, maxRange)
	var randThree := randf_range(minRange, maxRange)
	return Vector3(randOne, randTwo, randThree)
