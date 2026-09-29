# Relação com a aula teórica de Steering

Referência local: `Módulo III - Encontro 1 - Steering - Aula Teórica.pptx`, lida em 29/09/2026. O arquivo original foi preservado.

| Teoria | Prática |
|---|---|
| Slides 12–20: vetores, dinâmica e Seek | Etapa A; integração pronta e fórmula de Seek pelo aluno |
| Slides 21–24: Arrive e Pursuit | Etapa B; chegada e previsão limitada |
| Slides 25–27: combinação e cancelamento | Soma ponderada em C e demonstração no cenário 5 |
| Slides 28–31: flocking e vizinhança | Três regras do aluno e grade pronta com 48 boids |
| Slides 36–39: limites locais e camadas | Parede côncava no cenário 6 e separação entre direção e locomoção |
| Slides 40 e 43: padrões e laboratório | Strategy por Node, componentes filhos, Spatial Partition no apoio |

## Escolhas para manter o exercício direto

A prática cabe em 120 minutos. O aluno implementa as fórmulas de direção. Física, entrada, grade e visuais ficam prontos, com trechos de leitura no roteiro. O cenário e o agente seguem a organização dos exercícios anteriores, mas este é um projeto independente para evitar dependências de branches FSM ou BT.

Pursuit usa previsão máxima de 1,5 s. Alinhamento acompanha a média das velocidades, sem normalizá-la para a rapidez máxima. O movimento integra primeiro a velocidade e então move o corpo com `move_and_slide()`.

A prática cobre a soma ponderada. Soma priorizada, Flee, Evade e desvio de obstáculos ficam fora das funções avaliadas. Flee aparece apenas na demonstração pronta de cancelamento. Ordenar uma soma não garante que vetores menores opostos deixem de se cancelar. Também não garante escapar de uma concavidade.

A redução de custo com grade depende da densidade. A comparação mostra candidatos de uma distribuição concreta, sem prometer custo linear para qualquer cena ou desempenho para milhares de agentes.
