extends Control

var scene_button = preload("res://scenes/SceneButton.tscn")
var scenes
var scene_instances = []

var crt_search := ""

# Called when the node enters the scene tree for the first time.
func _ready():
	UserGlobal.user_fetched.connect(get_scenes)
	
func get_scenes(success):
	if !success:
		return
		
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self.scene_req)
	var headers = ["Authorization: Bearer " + UserGlobal.access_token]
	
	var query
	
	if crt_search == "":
		query = "sceneId=all"
	else:
		query = "name=" + crt_search
	
	http_request.request(UserGlobal.base_url + "/scenes?" + query, headers)

func scene_req(_result, _response_code, _headers, body):
	scenes = JSON.parse_string(body.get_string_from_utf8()).scenes
	print(scenes)
	for scene in scenes:
		var instance = scene_button.instantiate()
		instance.scene = scene
		scene_instances.append(instance)
		$ColorRect/ScrollContainer/GridContainer.add_child(instance)


func _on_name_input_text_submitted(new_text):
	crt_search = new_text
	for scene in scene_instances:
		scene.queue_free()
	scene_instances.clear()
	get_scenes(true)


func _on_player_menu():
	if is_visible_in_tree():
		hide()
	else:
		show()
