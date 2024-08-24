extends Node

class_name Draw3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Draws points in 3D space with given parameters
## Position is required, radius defaults to .05, color defautls to LAWN_GREEN
func point(pos: Vector3, radius: float = .05, color: Color = Color.LAWN_GREEN) -> MeshInstance3D:
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
	get_tree().get_root().add_child(meshInstance)
	return meshInstance
