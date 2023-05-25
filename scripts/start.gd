extends Control

@export var _join_code_input: LineEdit
@export var _lobby_networking: LobbyNetworking


func _join_lobby():
	var join_code = _join_code_input.text
	if len(join_code) <= 0:
		return
	self._lobby_networking.join_lobby(join_code)


func _on_create_lobby_button_pressed():
	self._lobby_networking.create_lobby()


func _on_join_button_pressed():
	self._join_lobby()


func _on_paste_button_pressed():
	self._join_code_input.text = DisplayServer.clipboard_get()


func _on_join_code_text_submitted(_new_text):
	self._join_lobby()
