extends Node

@export var peso_separacao: float = 1.5
@export var peso_alinhamento: float = 1.0
@export var peso_coesao: float = 0.6

func calcular(agente) -> Vector2:
	var forca = $Separacao.calcular(agente) * peso_separacao
	forca += $Alinhamento.calcular(agente) * peso_alinhamento
	forca += $Coesao.calcular(agente) * peso_coesao
	return forca
