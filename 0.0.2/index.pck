GDPC                  �                                                                         P   res://.godot/exported/133200997/export-083373b3bdb005034e8f2061a0828860-tile.scn@      �      ��R�X�g;q�(�ƚ    T   res://.godot/exported/133200997/export-a1c6b6a7696cf3187c9d43e2a386d23e-board.scn   P      �      [�`w{�F�Ey�    T   res://.godot/exported/133200997/export-e2cd3ad146e88a9ce40b77a5da0ea9b1-start.scn    	            �n�k����9E*.�\�H    D   res://.godot/imported/icon.svg-56083ea2a1f1a4f1e49773bdc6d7826c.ctex                ��ُ ��	���B~       res://.godot/uid_cache.bin  �-      �       z��*2sl<wlN�'O�       res://assets/icon.svg   P      N      ]��s�9^w/�����       res://assets/icon.svg.import        J      Ot8Xn��G,���I        res://prefabs/board.tscn.remap         b       6bwq�o��^�        res://prefabs/tile.tscn.remap   p      a       ޽Fs�Y��\��"��j       res://project.binary0.      B      ��.എMA0;m l	0        res://scenes/start.tscn.remap   �      b       S��f{Ձœ��f�       res://scripts/board.gd        C      'R�tn��Lo��)f       res://scripts/controller.gd `      f      �c�x��LI�2�Q�,3       res://scripts/network.gd�      (      gu���nK˔��    [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dhtwewtqokrs2"
path="res://.godot/imported/icon.svg-56083ea2a1f1a4f1e49773bdc6d7826c.ctex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://assets/icon.svg"
dest_files=["res://.godot/imported/icon.svg-56083ea2a1f1a4f1e49773bdc6d7826c.ctex"]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/bptc_ldr=0
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
svg/scale=1.0
editor/scale_with_editor_scale=false
editor/convert_colors_with_editor_theme=false
�Cy�X�RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scripts/board.gd ��������      local://PackedScene_kar6w          PackedScene          	         names "         Board    script    Node2D    Texture    polygon 
   Polygon2D    	   variants                 %                 D       D   D       D      node_count             nodes        ��������       ����                            ����                   conn_count              conns               node_paths              editable_instances              version             RSRC�Q�Z	,�ƎaRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_usdlq �          PackedScene          	         names "         Tile    Node2D    Texture    color    polygon 
   Polygon2D    	   variants            �?��H>  �?  �?%                �A      �A  �A      �A      node_count             nodes        ��������       ����                      ����                          conn_count              conns               node_paths              editable_instances              version             RSRCY��XCRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scripts/controller.gd ��������   PackedScene    res://prefabs/board.tscn ��;�r      local://PackedScene_vv8lg H         PackedScene          	         names "         DSGController    script    Node2D    Board 	   position    	   variants                          
     �C  �B      node_count             nodes        ��������       ����                      ���                         conn_count              conns               node_paths              editable_instances              version             RSRC��CVP#^�yextends Node2D

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")

func _ready():
	render_board("oo;;o;xxxxxx;xxxoxx;ooooo;;oooxxxx;xx;ooox;xxo;oxxxxx;;;o;")

func render_board(input: String):
	"""
		input:
			'x': normal tile (habitable)
			'o': empty tile (void - player can fall down) - all board surrounding tiles are implicitly empty tiles
			';': line break
	"""
	var board_grid = get_board_grid(input)	
	var tile_size = get_tile_size(board_grid)
	draw_board(board_grid, tile_size)

func _process(delta):
	pass

func draw_board(board_grid: Array, tile_size: int):
	for row in board_grid.size():
		for col in board_grid[row].size():
			match board_grid[row][col]:
				"x":
					var new_tile = tile_prefab.instantiate()
					new_tile.get_node("Texture").set_polygon(
						[
							Vector2(0, 0),
							Vector2(tile_size, 0),
							Vector2(tile_size, tile_size),
							Vector2(0, tile_size)
						]
					)
					add_child(new_tile)
					new_tile.position = Vector2(col, row) * tile_size
				"o":
					pass

func get_board_grid(input: String) -> Array:
	input = clean_up_input(input)
	var board_grid = []
	for line in input.split(";"):
		var grid_line = []
		for character in line:
			grid_line.append(character)
		board_grid.append(grid_line)
	return board_grid
	

func clean_up_input(input: String) -> String:
	var regex_line_end = RegEx.new()
	regex_line_end.compile("(o*;)")
	
	var regex_top_down = RegEx.new()
	regex_top_down.compile("(^;*)|(;*$)")
	
	input = regex_line_end.sub(input, ";", true)
	input = regex_top_down.sub(input, "", true)
	
	return input

func get_tile_size(board_grid: Array) -> int:
	var max_width = 0
	for line in board_grid:
		if line.size() > max_width:
			max_width = line.size()

	return min(floor(texture.polygon[2].x/max_width), floor(texture.polygon[2].y)/board_grid.size())
�9���b�ӽ�=*extends Node2D

var selected_piece_id: String = "550e8400-e29b-11d4-a716-446655440000"
var next_moves: Array

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}

@onready var network = get_node("/root/DSGNetwork")

func _ready():
	assert(network.connect_websocket())

func _process(_delta):
	pass

func _input(_event):
	if Input.is_action_pressed("MOVE_DOWN"):
		append_move(ACTIONS.MOVE_DOWN)
	elif Input.is_action_pressed("MOVE_LEFT"):
		append_move(ACTIONS.MOVE_LEFT)
	elif Input.is_action_pressed("MOVE_RIGHT"):
		append_move(ACTIONS.MOVE_RIGHT)
	elif Input.is_action_pressed("MOVE_UP"):
		append_move(ACTIONS.MOVE_UP)
	elif Input.is_action_pressed("NOP"):
		append_move(ACTIONS.NO_ACTION)

func append_move(action: ACTIONS):
	next_moves.append({
		"piece_id": selected_piece_id,
		"action": ACTIONS.keys()[action].to_lower()
	})
	if network.is_online():
		network.send(JSON.stringify(
			{
				"type": "player_moves",
				"payload": {
					"moves": next_moves
				}
			}
		).to_utf8_buffer())

class Move:
	func _init(piece_id: String, action: ACTIONS):
		self.piece_id = piece_id
		self.action = action
[����extends Node

var _url: String = "ws://127.0.0.1:8000/lobby/550e8400-e29b-11d4-a716-446655440000/join"
var _client = WebSocketClient.new()

func is_online() -> bool:
	return _client.get_peer(1).is_connected_to_host()

func connect_websocket() -> bool:
	if _client.connect_to_url(_url, []) != OK:
		return false
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	return true

func disconnect_websocket():
	_client.disconnect_from_host()
	
func set_url(new_url: String):
	_url = new_url

func send(payload: PackedByteArray):
	_client.get_peer(1).put_packet(payload)

func _receive():
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _ready():
	_client.connection_closed.connect(_closed)
	_client.connection_error.connect(_closed)
	_client.connection_established.connect(_connected)
	_client.data_received.connect(_on_data)	

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)

func _connected(_proto = ""):
	pass

func _on_data():
	_receive()

func _process(_delta):
	_client.poll()
��NbE[remap]

path="res://.godot/exported/133200997/export-a1c6b6a7696cf3187c9d43e2a386d23e-board.scn"
�#�l	�R}��{�c|[remap]

path="res://.godot/exported/133200997/export-083373b3bdb005034e8f2061a0828860-tile.scn"
#��H"��W�@�"�2[remap]

path="res://.godot/exported/133200997/export-e2cd3ad146e88a9ce40b77a5da0ea9b1-start.scn"
��[CV�fSr��<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><g transform="translate(32 32)"><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99z" fill="#363d52"/><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99zm0 4h96c6.64 0 12 5.35 12 11.99v95.98c0 6.64-5.35 11.99-12 11.99h-96c-6.64 0-12-5.35-12-11.99v-95.98c0-6.64 5.36-11.99 12-11.99z" fill-opacity=".4"/></g><g stroke-width="9.92746" transform="matrix(.10073078 0 0 .10073078 12.425923 2.256365)"><path d="m0 0s-.325 1.994-.515 1.976l-36.182-3.491c-2.879-.278-5.115-2.574-5.317-5.459l-.994-14.247-27.992-1.997-1.904 12.912c-.424 2.872-2.932 5.037-5.835 5.037h-38.188c-2.902 0-5.41-2.165-5.834-5.037l-1.905-12.912-27.992 1.997-.994 14.247c-.202 2.886-2.438 5.182-5.317 5.46l-36.2 3.49c-.187.018-.324-1.978-.511-1.978l-.049-7.83 30.658-4.944 1.004-14.374c.203-2.91 2.551-5.263 5.463-5.472l38.551-2.75c.146-.01.29-.016.434-.016 2.897 0 5.401 2.166 5.825 5.038l1.959 13.286h28.005l1.959-13.286c.423-2.871 2.93-5.037 5.831-5.037.142 0 .284.005.423.015l38.556 2.75c2.911.209 5.26 2.562 5.463 5.472l1.003 14.374 30.645 4.966z" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 919.24059 771.67186)"/><path d="m0 0v-47.514-6.035-5.492c.108-.001.216-.005.323-.015l36.196-3.49c1.896-.183 3.382-1.709 3.514-3.609l1.116-15.978 31.574-2.253 2.175 14.747c.282 1.912 1.922 3.329 3.856 3.329h38.188c1.933 0 3.573-1.417 3.855-3.329l2.175-14.747 31.575 2.253 1.115 15.978c.133 1.9 1.618 3.425 3.514 3.609l36.182 3.49c.107.01.214.014.322.015v4.711l.015.005v54.325c5.09692 6.4164715 9.92323 13.494208 13.621 19.449-5.651 9.62-12.575 18.217-19.976 26.182-6.864-3.455-13.531-7.369-19.828-11.534-3.151 3.132-6.7 5.694-10.186 8.372-3.425 2.751-7.285 4.768-10.946 7.118 1.09 8.117 1.629 16.108 1.846 24.448-9.446 4.754-19.519 7.906-29.708 10.17-4.068-6.837-7.788-14.241-11.028-21.479-3.842.642-7.702.88-11.567.926v.006c-.027 0-.052-.006-.075-.006-.024 0-.049.006-.073.006v-.006c-3.872-.046-7.729-.284-11.572-.926-3.238 7.238-6.956 14.642-11.03 21.479-10.184-2.264-20.258-5.416-29.703-10.17.216-8.34.755-16.331 1.848-24.448-3.668-2.35-7.523-4.367-10.949-7.118-3.481-2.678-7.036-5.24-10.188-8.372-6.297 4.165-12.962 8.079-19.828 11.534-7.401-7.965-14.321-16.562-19.974-26.182 4.4426579-6.973692 9.2079702-13.9828876 13.621-19.449z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 104.69892 525.90697)"/><path d="m0 0-1.121-16.063c-.135-1.936-1.675-3.477-3.611-3.616l-38.555-2.751c-.094-.007-.188-.01-.281-.01-1.916 0-3.569 1.406-3.852 3.33l-2.211 14.994h-31.459l-2.211-14.994c-.297-2.018-2.101-3.469-4.133-3.32l-38.555 2.751c-1.936.139-3.476 1.68-3.611 3.616l-1.121 16.063-32.547 3.138c.015-3.498.06-7.33.06-8.093 0-34.374 43.605-50.896 97.781-51.086h.066.067c54.176.19 97.766 16.712 97.766 51.086 0 .777.047 4.593.063 8.093z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 784.07144 817.24284)"/><path d="m0 0c0-12.052-9.765-21.815-21.813-21.815-12.042 0-21.81 9.763-21.81 21.815 0 12.044 9.768 21.802 21.81 21.802 12.048 0 21.813-9.758 21.813-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 389.21484 625.67104)"/><path d="m0 0c0-7.994-6.479-14.473-14.479-14.473-7.996 0-14.479 6.479-14.479 14.473s6.483 14.479 14.479 14.479c8 0 14.479-6.485 14.479-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 367.36686 631.05679)"/><path d="m0 0c-3.878 0-7.021 2.858-7.021 6.381v20.081c0 3.52 3.143 6.381 7.021 6.381s7.028-2.861 7.028-6.381v-20.081c0-3.523-3.15-6.381-7.028-6.381" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 511.99336 724.73954)"/><path d="m0 0c0-12.052 9.765-21.815 21.815-21.815 12.041 0 21.808 9.763 21.808 21.815 0 12.044-9.767 21.802-21.808 21.802-12.05 0-21.815-9.758-21.815-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 634.78706 625.67104)"/><path d="m0 0c0-7.994 6.477-14.473 14.471-14.473 8.002 0 14.479 6.479 14.479 14.473s-6.477 14.479-14.479 14.479c-7.994 0-14.471-6.485-14.471-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 656.64056 631.05679)"/></g></svg>
y   3�f�Lu�j   res://assets/icon.svg��;�r   res://prefabs/board.tscnK�y�F��   res://prefabs/tile.tscn:�e{�/9   res://scenes/start.tscnECFG
      application/config/name         LD51   application/run/main_scene          res://scenes/start.tscn    application/config/features$   "         4.0    Forward Plus       application/config/icon          res://assets/icon.svg      autoload/DSGNetwork$         *res://scripts/network.gd   	   input/NOP�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode          unicode           echo          script         input/MOVE_UP               deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @    unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W      unicode           echo          script         input/MOVE_DOWN               deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S      unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @    unicode           echo          script         input/MOVE_LEFT               deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @    unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A      unicode           echo          script         input/MOVE_RIGHT               deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @    unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D      unicode           echo          script      ���e�q��5+��