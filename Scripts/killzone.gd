extends Area2D

signal got_hurt

func _on_body_entered(body: Node2D) -> void:
	emit_signal("got_hurt")

