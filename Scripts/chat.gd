extends RichTextLabel

@rpc("any_peer", "call_local")
func add_line(username, message):
	text += "[" + username + "] " + message + "\n"
