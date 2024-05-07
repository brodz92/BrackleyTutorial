extends Area2D




func _on_body_entered(body: Node2D) -> void:
	Engine.time_scale = 0.5
	get_tree().change_scene_to_file("res://Scenes/Level2.tscn")
	Engine.time_scale = 1
