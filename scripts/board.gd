extends Node2D


const MAX_BOARD_DIMENSIONS = Vector2(1,1)

@onready var tile_prefab = preload("res://prefabs/tile.tscn")

func _ready():
	render_board("xxxxxx;xxxoxx;oooxxx")


func render_board(input: String):
	"""
		input:
			'x': normal tile (habitable)
			'o': empty tile (void - player can fall down) - all board surrounding tiles are implicitly empty tiles
			';': line break
	"""
	var lines = input.split(";")
	print(lines)
	for i in lines.size():
		for j in len(lines[i]):
			match lines[i][j]:
				"x":
					var new_tile = tile_prefab.instantiate()
					add_child(new_tile)
					new_tile.position = Vector2(j, i) * 16
				"o":
					pass
			print(lines[i][j])

func _process(delta):
	pass
