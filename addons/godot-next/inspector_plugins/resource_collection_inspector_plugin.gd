# author: xdgamestudios
# license: MIT
# description: This script is injected into the editor upon loading the plugin.
#              Generates a custom toolbar for ResourceCollection property lists.
# deps:
# - ClassType
tool
extends EditorInspectorPlugin

##### CONSTANTS #####

const ADD_ICON = preload("res://addons/godot-next/icons/icon_add.svg")

##### PROPERTIES #####

##### NOTIFICATIONS #####

##### VIRTUALS #####

func can_handle(p_object) -> bool:
	return p_object is Object

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func parse_property(p_object, p_type: int, p_path: String, p_hint: int, p_hint_text: String, p_usage: int) -> bool:
	if not p_hint_text.begins_with("$"):
		return false
	var property_data = p_hint_text.lstrip("$").split("$")
	match p_type:
		TYPE_OBJECT:
			match property_data[0]:
				"button":
					var label = property_data[1]
					var callback = property_data[2]
					var control = InspectorControls.new_button(label, p_object, callback)
					add_custom_control(control)
				"dropdown_selector":
					var elements_callback = property_data[1]
					var selected_callback = property_data[2]
					var elements = p_object.call(elements_callback)
					var control = InspectorControls.new_dropdown_selector(elements, p_object, selected_callback)
					add_custom_control(control)
				"custom_control":
					var gui_builder = property_data[1];
					var control = p_object.call(gui_builder)
					add_custom_control(control)
	return true

##### PRIVATE METHODS #####

##### CONNECTIONS #####
