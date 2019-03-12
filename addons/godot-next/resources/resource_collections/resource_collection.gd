# author: xdgamestudios
# license: MIT
# description: An abstract base class for data structures that store Resource objects.
#              Uses a key-value store, but can also append items.
tool
extends Resource
class_name ResourceCollection

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####

const PREFIX = "_data"
const EMPTY_ENTRY = "[ Empty ]"

##### PROPERTIES #####

var _value_type: Script = null
var _type_readonly: bool = false
#warning-ignore:unused_class_variable
var _class_type: ClassType = ClassType.new()

##### NOTIFICATIONS #####

func _get(p_property: String):
	if p_property == "setup_value_type":
		return _value_type
	return null

func _set(p_property: String, p_value) -> bool:
	if p_property == "setup_value_type":
		if _value_type == p_value:
			return true
		_value_type = p_value
		_refresh_data()
		if Engine.editor_hint:
			property_list_changed_notify()
		return true
	return false

func _get_property_list() -> Array:
	var list := [];
	if not _type_readonly:
		list.append(PropertyInfo.new_group("setup", "setup_").to_dict())
		list.append(PropertyInfo.new_resource("setup_value_type", "Script").to_dict())
	return list

##### OVERRIDES #####

##### VIRTUALS #####

# Append an element to the collection.
#warning-ignore:unused_argument
func _add_element(p_script: Script) -> void:
	assert false

# Refresh the data upon type change.
func _refresh_data() -> void:
	assert false

##### PUBLIC METHODS #####

func clear() -> void:
	assert false

##### PRIVATE METHODS #####

##### PRIVATE METHODS #####

func _generate_dropdown_selector() -> Control:
	var inheritors := _find_inheritors(_value_type)
	return InspectorControls.new_dropdown_selector(inheritors, self, "_on_dropdown_selector_selected")

func _find_inheritors(p_type: Script) -> Dictionary:
	_class_type.res = p_type
	var list = _class_type.get_deep_inheritors_list()
	var type_map = _class_type.get_deep_type_map()
	var inheritors = { }
	for a_name in list:
		inheritors[a_name] = load(type_map[a_name].path)
	return inheritors

func _instantiate_script(p_script: Script) -> Resource:
	var res: Resource = null
	if ClassDB.is_parent_class(p_script.get_instance_base_type(), "Resource"):
		push_warning("Must assign non-Script Resource instances. Auto-instantiating the given Resource script.")
		res = p_script.new()
	else:
		push_error("Must assign non-Script Resource instances. Fallback error: cannot auto-instantiate non-Resource scripts into ResourceCollection.")
	return res

##### CONNECTIONS #####

func _on_dropdown_selector_selected(dropdown_selector):
	var script = dropdown_selector.get_selected_meta()
	_add_element(script)

##### SETTERS AND GETTERS #####

func get_value_type() -> Script:
	return _value_type

func set_value_type(p_type: Script) -> void:
	if _value_type == p_type:
		return
	_value_type = p_type
	if Engine.editor_hint:
		property_list_changed_notify()

func is_type_readonly() -> bool:
	return _type_readonly

func set_type_readonly(p_readonly: bool) -> void:
	if _type_readonly == p_readonly:
		return
	_type_readonly = p_readonly
	if Engine.editor_hint:
		property_list_changed_notify()
