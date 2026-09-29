extends Node

func calcular(agente) -> Vector2:
	return para(agente, agente.alvo.global_position)

func para(agente, destino: Vector2) -> Vector2:
	var direcao = destino - agente.global_position
	var desejada = direcao.normalized() * agente.velocidade_max
	return desejada - agente.velocity
