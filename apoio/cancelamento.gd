extends Node

func calcular(agente) -> Vector2:
	var buscar = $Seek.para(agente, agente.alvo.global_position)
	var direcao = agente.global_position - agente.alvo.global_position
	var fugir = direcao.normalized() * agente.velocidade_max - agente.velocity
	return buscar + fugir
