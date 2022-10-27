extends Node2D

@export var _tile_texture: Sprite2D

func _ready():
	self._tile_texture.material.set_shader_parameter("offset", randf_range(0.0, PI))

func scale_texture(max_size: float):
	if self._tile_texture.texture == null:
		return
	var width = max_size/self._tile_texture.texture.get_width()
	var height = max_size/self._tile_texture.texture.get_height()
	self._tile_texture.apply_scale(Vector2(width, height))

func set_void_texture():
	# TODO: Set a texture instead of deleting it
	self._tile_texture.texture = null
