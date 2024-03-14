extends Button

var scene

func _ready():
	$Name.text = scene.name
	
	if scene.banner_url:
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(self._http_request_completed)
		var error = http_request.request(scene.banner_url)
		if error != OK:
			push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")
	var image = Image.new()
	var error
	if headers.has("Content-Type: image/jpeg"):
		error = image.load_jpg_from_buffer(body)
	elif headers.has("Content-Type: image/png"):
		error = image.load_png_from_buffer(body)
	if error != OK:
		print(error)

	var texture = ImageTexture.create_from_image(image)

	$Banner.texture = texture


func _on_button_down():
	var download_request = HTTPRequest.new()
	download_request.request_completed.connect(self._on_download_completed)
	var error = download_request.request(scene.scene_url)

func _on_download_completed(result, body, headers, status):
	if result == HTTPRequest.RESULT_SUCCESS:
		load_pck_data(body)
	else:
		print("Download failed: ", status)

func load_pck_data(data):
	var scene_data = PackedByteArray(data)
	var scene_stream = ResourceLoader.load(scene_data) as PackedScene
	if scene_stream:
		var scene_instance = scene_stream.instance()
		add_child(scene_instance)
	else:
		print("Failed to load .pck data")
