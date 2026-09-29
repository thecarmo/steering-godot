extends Node

func calcular(agente) -> Vector2:
	return para(agente, agente.alvo.global_position)

func para(agente, destino: Vector2) -> Vector2:
	return Vector2.ZERO
