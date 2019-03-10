# author: xdgamestudios
# license: MIT
# description: Manages a ResourceSet of resources and delegates Node callbacks to each instance.
#              As a ResourceSet, only one element of any given type is allowed on a single elements node.
# deps:
# - ResourceSet
# - PropertyInfo
# - ClassType
# usage:
# - Creating:
#     elements = elements.new()
# - Adding elements:
#     elements.add_element(MyResource) # Returns a new or pre-existing instance of the element or null if given an invalid element script.
# - Checking elements:
#     elements.has_element(MyResource) # Returns true if the element exists in the collection.
# - Retrieving elements:
#     elements.get_element(MyResource) # Returns the element instance of the given type or null if not in the collection.
# - Removing elements:
#     elements.remove_element(MyResource) # Removes the element from the collection. Returns true if successful. Else, returns false.
# notes:
#     - Public interface of each stored Resource type:
#         - var owner: Node
#         - func get_enabled() -> bool
#     - Initialization Sequence:
#         1. _awake() called during _enter_tree() after CallbackDelegator initializes owner (for Unity familiarity).
#         2. _enter_tree() called immediately after (so they are virtually aliases for each other)
#         3. _ready() called during _ready().
tool
extends Node
class_name CallbackDelegator

##### PROPERTIES #####

var _elements: ResourceSet = ResourceSet.new()

var _callbacks: Dictionary = {
	"_enter_tree" : {},
	"_exit_tree" : {},
	"_ready" : {},
	"_process" : {},
	"_physics_process" : {},
	"_input" : {},
	"_unhandled_input" : {},
	"_unhandled_key_input" : {}
}

var _class_type: = ClassType.new()

##### NOTIFICATIONS #####

func _get_property_list() -> Array:
	return [ PropertyInfo.new_resource("_elements").to_dict() ]

func _ready() -> void:
	if Engine.editor_hint:
		return
	_handle_notification("_ready")

func _enter_tree() -> void:
	if Engine.editor_hint:
		return
	var elements = _elements.get_data().values()
	for an_element in elements:
		if not an_element.owner:
			_initialize_element(an_element)
	_check_for_empty_callbacks()
	
	_handle_notification("_enter_tree")

func _exit_tree() -> void:
	if Engine.editor_hint:
		return
	_handle_notification("_enter_tree")

func _process(delta: float) -> void:
	if Engine.editor_hint:
		return
	_handle_notification("_process", delta)

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	_handle_notification("_physics_process", delta)

func _input(event: InputEvent) -> void:
	if Engine.editor_hint:
		return
	_handle_notification("_input", event)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.editor_hint:
		return
	_handle_notification("_unhandled_input", event)

func _unhandled_key_input(event: InputEventKey) -> void:
	if Engine.editor_hint:
		return
	_handle_notification("_unhandled_key_input", event)

##### VIRTUALS #####

##### PUBLIC METHODS #####

func add_element(p_type: Script) -> Resource:
	var elements = _elements.get_data()
	
	_class_type.res = p_type
	if not _class_type.is_type(_elements.get_base_type()):
		return null
	if has_element(p_type):
		return get_element(p_type)
		
	var element: Resource = p_type.new()
	var element_name: String = _class_type.get_script_class()
	
	elements[element_name] = element
	_initialize_element(element)
	
	return element

func get_element(p_type: Script) -> Resource:
	var elements = _elements.get_data()
	_class_type.res = p_type
	return elements.get(_class_type.get_script_class(), null)

func has_element(p_type: Script) -> bool:
	var elements = _elements.get_data()
	_class_type.res = p_type
	return elements.has(_class_type.get_script_class())

func remove_element(p_type: Script) -> bool:
	var elements = _elements.get_data()
	var element = get_element(p_type)
	if element:
		_remove_from_callbacks(element)
		_class_type.res = p_type
		return elements.erase(_class_type.get_script_class())
	return false

##### PRIVATE METHODS #####

func _handle_notification(p_name: String, p_param = null) -> void:
	if not p_param:
		for an_element in _callbacks[p_name]:
			an_element.call(p_name)
	else:
		for an_element in _callbacks[p_name]:
			an_element.call(p_name, p_param)

func _initialize_element(p_element: Resource) -> void:
	__awake(p_element)
	#warning-ignore:return_value_discarded
	p_element.connect("script_changed", self, "_refresh_callbacks", [p_element])
	_add_to_callbacks(p_element)

func _add_to_callbacks(p_element: Resource) -> void:
	for a_callback in _callbacks:
		if p_element.has_method(a_callback) and p_element.get_enabled():
			_callbacks[a_callback][p_element] = null

func _remove_from_callbacks(p_element: Resource) -> void:
	for a_callback in _callbacks:
		_callbacks[a_callback].erase(p_element)
	_check_for_empty_callbacks()

func _check_for_empty_callbacks() -> void:
	for a_callback in _callbacks:
		match a_callback:
			"_process":
				set_process(not _callbacks[a_callback].empty())
			"_physics_process":
				set_physics_process(not _callbacks[a_callback].empty())
			"_input":
				set_process_input(not _callbacks[a_callback].empty())
			"_unhandled_input":
				set_process_unhandled_input(not _callbacks[a_callback].empty())
			"_unhandled_key_input":
				set_process_unhandled_key_input(not _callbacks[a_callback].empty())

# Sets up the owner instance on the Behavior.
func __awake(p_element: Resource) -> void:
	p_element.owner = self
	if p_element.has_method("_awake"):
		p_element._awake()

##### CONNECTIONS #####

func _on_element_script_change(p_element: Resource) -> void:
	_remove_from_callbacks(p_element)
	_add_to_callbacks(p_element)

##### SETTERS AND GETTERS #####