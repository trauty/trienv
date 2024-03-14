extends Node3D

var http_request: HTTPRequest

func _ready():
	var token = JavaScriptBridge.eval("""
	function getCookie(cname) {
  let name = cname + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(';');
  for(let i = 0; i <ca.length; i++) {
	let c = ca[i];
	while (c.charAt(0) == ' ') {
	  c = c.substring(1);
	}
	if (c.indexOf(name) == 0) {
	  return c.substring(name.length, c.length);
	}
  }
  return "";
}
	getCookie('trienv_refresh_token');
	"""
	)
	
	UserGlobal.refresh_token = token
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self.refresh_completed)

	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var data = "refresh_token=" + UserGlobal.refresh_token
	var error = http_request.request(UserGlobal.base_url + "/auth/refresh", headers, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error(error)
func refresh_completed(result, _response_code, _headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS):
		UserGlobal.user_fetched.emit(false)
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	UserGlobal.access_token = json.access_token
	
	http_request.request_completed.disconnect(self.refresh_completed)
	http_request.request_completed.connect(self.get_user)
	var headers = ["Authorization: Bearer " + UserGlobal.access_token]
	http_request.request(UserGlobal.base_url + "/user/me", headers)
	
func get_user(result, _response_code, _headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS):
		UserGlobal.user_fetched.emit(false)
		return
	UserGlobal.user = JSON.parse_string(body.get_string_from_utf8())
	UserGlobal.user_fetched.emit(true)
