extends MarginContainer

@onready var console_output: RichTextLabel = $MarginContainer/HBoxContainer/Console/Output
@onready var status_line: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/SettingsGrid/StatusLineEdit


func _on_list_inputs_button_pressed() -> void:
	var inputs = await $VulpineLogicOBSWebSocket.get_inputs()
	
	for input in inputs:
		console_output.append_text("%s (%s)\n" % [
			input.input_name,
			input.input_kind
		])


func _on_list_scenes_button_pressed() -> void:
	var scenes = await $VulpineLogicOBSWebSocket.get_scene_list()
	
	for scene in scenes:
		console_output.append_text("%d: %s\n" % [
			scene.scene_index,
			scene.scene_name
		])


func _on_password_line_edit_text_submitted(new_text: String) -> void:
	$VulpineLogicOBSWebSocket.password = new_text


func _on_uri_line_edit_text_submitted(new_text: String) -> void:
	$VulpineLogicOBSWebSocket.host = new_text


func _on_vulpine_logic_obs_web_socket_closed(close_code: int) -> void:
	status_line.text = "Closed"
	$MarginContainer/HBoxContainer/VBoxContainer/ButtonGrid.visible = false

	console_output.append_text("Connection closed: %s (%s)\n" % [
		$VulpineLogicOBSWebSocket.WebSocketCloseCode.code_string(close_code),
		close_code
	])


func _on_vulpine_logic_obs_web_socket_connected() -> void:
	status_line.text = "Negotiating Connection"


func _on_vulpine_logic_obs_web_socket_current_program_scene_changed(
		scene_name: String,
		scene_uuid: String
) -> void:
	console_output.append_text("Scene changed: %s (%s)\n" % [
		scene_name,
		VulpineLogicOBSWebSocketRequest.uuid_to_string(scene_uuid)
	])


func _on_vulpine_logic_obs_web_socket_exit_started() -> void:
	console_output.append_text("OBS is closing\n")


func _on_vulpine_logic_obs_web_socket_identified(event: Dictionary) -> void:
	status_line.text = "Ready"
	
	$MarginContainer/HBoxContainer/VBoxContainer/ButtonGrid.visible = true
	
	console_output.append_text("Negotiated RPC Version %s\n" % event.get("negotiated_rpc_version"))

	var profile = await $VulpineLogicOBSWebSocket.get_current_profile()
	console_output.append_text("Profile: %s\n" % profile)
	
	var scene_collection = await $VulpineLogicOBSWebSocket.get_current_scene_collection()
	console_output.append_text("Scene Collection: %s\n" % scene_collection)

	var scene = await $VulpineLogicOBSWebSocket.get_current_program_scene_name()
	console_output.append_text("Scene: %s\n" % scene)
