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
					var callback = property_data[1]
					var group = property_data[2]
					var name = p_path.lstrip(group)
					var button = _generate_button(p_object, name, callback)
					add_custom_control(button)
				"dropdown_res":
					var type = property_data[1]
					var callback = property_data[2]
					var group = property_data[3]
					var dropdown = _generate_dropdown_res(p_object, type, callback)
					add_custom_control(dropdown)
				"dropdown_sub":
					var type = property_data[1]
					var callback = property_data[2]
					var group = property_data[3]
					var dropdown = _generate_dropdown_sub(p_object, type, callback)
					add_custom_control(dropdown)
	return true

##### PRIVATE METHODS #####

func _generate_button(p_object, p_name: String, p_callback: String) -> Control:
	var button = Button.new()
	button.text = p_name
	button.connect("pressed", p_object, p_callback)
	return button

func _generate_dropdown_res(p_object, p_type: String, p_callback: String) -> Control:
	var hbox := HBoxContainer.new()
	
	var dropdown := OptionButton.new()
	var class_type := ClassType.new()
	var inheritors := _find_inheritors(p_type)
	for an_index in inheritors.size():
		class_type.res = inheritors[an_index]
		dropdown.add_item(class_type.get_name(), an_index)
		dropdown.set_item_metadata(an_index, inheritors[an_index])
	dropdown.size_flags_horizontal = HBoxContainer.SIZE_EXPAND_FILL
	
	var button = ToolButton.new()
	button.icon = ADD_ICON
	button.connect("pressed", p_object, p_callback)
	
	hbox.add_child(dropdown)
	hbox.add_child(button)
	
	return hbox

func _generate_dropdown_sub(p_object, p_type: String, p_callback: String) -> Control:
	var hbox := HBoxContainer.new()
	
	var dropdown := OptionButton.new()
	var class_type := ClassType.new()
	var inheritors := _find_inheritors(p_type)
	for an_index in inheritors.size():
		class_type.res = inheritors[an_index]
		dropdown.add_item(class_type.get_name(), an_index)
		dropdown.set_item_metadata(an_index, inheritors[an_index])
	dropdown.size_flags_horizontal = HBoxContainer.SIZE_EXPAND_FILL
	
	
	var button = ToolButton.new()
	button.icon = ADD_ICON
	button.connect("pressed", p_object, p_callback, [dropdown])
	
	hbox.add_child(dropdown)
	hbox.add_child(button)
	
	return hbox

func _find_inheritors(p_type_path: String) -> Array:
	var ct = ClassType.new(p_type_path, true)
	var list = ct.get_deep_inheritors_list()
	var type_map = ct.get_deep_type_map()
	var scripts = []
	for a_name in list:
		scripts.append(load(type_map[a_name].path))
	return scripts

##### CONNECTIONS #####
