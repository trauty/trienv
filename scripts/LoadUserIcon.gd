extends TextureRect

func _ready():
	UserGlobal.user_fetched.connect(get_icon)
# Called when the node enters the scene tree for the first time.
func get_icon(success):
	$Background/Username.text = UserGlobal.user.username + " #" + UserGlobal.user.tag
	if UserGlobal.user.image:
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(self._http_request_completed)
		var error = http_request.request(UserGlobal.user.image)
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
		push_error("Couldn't load the image.")

	var req_texture = ImageTexture.create_from_image(image)

	texture = req_texture
