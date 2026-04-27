class_name State
extends Node

@warning_ignore("unused_signal")
signal transitioned(state_name: String)

var actor: Node2D

func setup() -> void: pass
func enter(_msg := {}) -> void: pass
func exit() -> void: pass
func process(_delta: float) -> void: pass
func physics_process(_delta: float) -> void: pass
