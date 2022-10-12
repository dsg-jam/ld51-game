extends Node2D

@export var _tile_texture: Sprite2D

func scale_texture(max_size: float):
	var width = max_size/self._tile_texture.texture.get_width()
	var height = max_size/self._tile_texture.texture.get_height()
	self._tile_texture.apply_scale(Vector2(width, height))
