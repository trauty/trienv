extends Node

var refresh_token : String
var access_token : String
var base_url : String = "https://trienv-api.trauty.dev"
var user

signal user_fetched(success)
