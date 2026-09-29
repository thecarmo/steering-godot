# Roteiro de Steering Behaviour

32 passos / 120 minutos. Mesmo conteúdo do PPTX e do guia HTML.


## 1. Sua cópia de trabalho

Local: Terminal, dentro de steering-godot. Tempo: 3 minutos.

A starter abre o laboratório com as funções do exercício por completar.

- Crie sua branch com os comandos abaixo.

```
git switch starter
git switch -c minha-steering
```

Confira: Você está em minha-steering, criada a partir da starter.

Distribua a pasta completa, incluindo .git, ou um clone. Se minha-steering existir, escolha outro nome. Este laboratório é independente dos repositórios FSM e BT.


## 2. Importação do projeto

Local: Godot, gerenciador de projetos. Tempo: 3 minutos.

A cena, os controles e a física já estão preparados.

- Clique em Import e selecione project.godot.

- Abra o projeto e aguarde a importação.

Confira: As pastas aluno/, apoio/, cenas/ e verificacao/ aparecem.

Versão de validação: Godot 4.7.2. Use a edição padrão com GDScript. Não são necessários plugins ou arquivos dos outros projetos.


## 3. O laboratório inicial

Local: Editor da Godot e janela do jogo. Tempo: 3 minutos.

O agente azul ainda não recebe força de direção.

- Execute com F5.

- Clique em outro ponto dentro da arena.

Confira: O alvo verde muda de lugar; o agente azul continua parado.

F5 executa cenas/laboratorio.tscn. 1–6 selecionam cenários, R reinicia o cenário e Espaço pausa. Os modos de comportamento ganham suas fórmulas durante o exercício. Feche o jogo antes de editar.


## 4. Os arquivos do aluno

Local: Painel FileSystem. Tempo: 3 minutos.

Você implementará sete funções curtas de direção.

- Abra aluno/.

- Localize apoio/ e verificacao/.

Confira: aluno/ contém Seek, Arrive, Pursuit e as quatro partes do flocking.

Edite apenas o corpo das funções indicadas. Preserve extends Node e as variáveis já declaradas. apoio/ contém movimento, entrada, grade e apresentação. As estratégias são scripts da aula, não recursos prontos de steering da Godot.


## 5. Strategy com nós nativos

Local: cenas/agente.tscn, nó Direcoes. Tempo: 4 minutos.

Cada filho oferece calcular(agente) e devolve um Vector2.

- Abra agente.tscn.

- Expanda Direcoes e selecione Seek.

Confira: Seek usa aluno/seek.gd; Arrive e Pursuit têm a mesma entrada e saída.

A troca da estratégia muda o cálculo da força. O apoio chama agente.estrategia.calcular(agente) sem conhecer a fórmula escolhida. Flocking reúne componentes filhos sob a mesma interface. Não há fábrica, registro global ou hierarquia de classes.


## 6. A integração pronta

Local: apoio/agente.gd, função mover. Tempo: 4 minutos.

A força muda a velocidade aos poucos; a Godot move o corpo.

- Leia estas linhas; mantenha o arquivo pronto.

```
var aceleracao = forca.limit_length(forca_max)
velocity = (velocity + aceleracao * delta).limit_length(velocidade_max)
move_and_slide()
```

Confira: Há um limite para a força e outro para a rapidez.

Trecho de mover, sem a atualização visual. Massa 1 e ganho de resposta 1 por segundo: a diferença de velocidades é usada numericamente como aceleração. move_and_slide já usa o passo de física, portanto velocity não recebe delta novamente. O integrador usa a velocidade atualizada. https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html


## 7. Seek

Local: aluno/seek.gd, função para. Tempo: 6 minutos.

Seek deseja a rapidez máxima na direção do destino.

- Substitua somente para pelo trecho abaixo e salve.

```
func para(agente, destino: Vector2) -> Vector2:
    var direcao = destino - agente.global_position
    var desejada = direcao.normalized() * agente.velocidade_max
    return desejada - agente.velocity
```

Confira: calcular já chama para com a posição do alvo.

para recebe um destino explícito para permitir reutilização em Pursuit e Coesao. calcular já está pronto na starter. O retorno é desejada menos atual. A normalização de Vector2.ZERO retorna zero. Modelo: aula teórica, slides 17 e 20; https://www.red3d.com/cwr/steer/gdc99/


## 8. Seek em movimento

Local: Editor da Godot e janela do jogo. Tempo: 3 minutos.

A seta laranja mostra a força; a azul mostra a velocidade.

- Execute com F5.

- Clique acima do agente enquanto ele se move.

Confira: O agente faz uma curva ao mudar de destino.

Pressione 1 para voltar ao cenário Seek. Cada linha mede 0,35 vezes a magnitude do vetor correspondente. A captura mostra o projeto completo em execução.


## 9. A passagem pelo alvo

Local: Jogo, cenário 1. Tempo: 3 minutos.

Seek mantém rapidez desejada alta perto do alvo.

- Pressione R e aguarde cerca de 10 segundos.

Confira: O agente ultrapassa o alvo e tenta voltar.

A aceleração limitada impede uma parada instantânea. Este resultado prepara a comparação com Arrive. A posição inicial é x=200 e o alvo x=880, com y=350.


## 10. Verificação da etapa A

Local: verificacao/etapa_a.tscn. Tempo: 4 minutos.

A cena de verificação testa Seek e a base pronta.

- Abra etapa_a.tscn e pressione F6.

Confira: A janela termina com 22/22 verificações passaram.

F6 executa a cena aberta. Aguarde aproximadamente 15 segundos em execução normal. Em caso de falha, veja a linha FALHA no painel Output e confira a função para. F5 continua abrindo o laboratório.


## 11. Registro da etapa A

Local: Terminal, dentro de steering-godot. Tempo: 2 minutos.

Salve sua tentativa antes de implementar a chegada.

- Execute os comandos abaixo.

```
git add aluno/seek.gd
git commit -m "Etapa A: Seek"
```

Confira: Sua implementação de Seek fica salva na branch de trabalho.

Recuperação opcional: pare o jogo, use git stash push -u e crie uma nova branch com git switch -c retomada-a etapa-a-seek. Sua tentativa permanece no stash. Não use reset --hard.


## 12. Arrive

Local: aluno/arrive.gd, função calcular. Tempo: 6 minutos.

Dentro do raio, a rapidez desejada cai com a distância.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(agente) -> Vector2:
    var direcao = agente.alvo.global_position - agente.global_position
    var rapidez = agente.velocidade_max
    rapidez *= minf(direcao.length() / agente.raio_chegada, 1.0)
    var desejada = direcao.normalized() * rapidez
    return desejada - agente.velocity
```

Confira: No alvo, a velocidade desejada vale zero.

minf limita a proporção a 1. raio_chegada vale 260 px e deve permanecer positivo. A rampa chega a zero sem dividir pelo comprimento do vetor. Aula teórica, slide 22.


## 13. A chegada suave

Local: Jogo, cenário 2. Tempo: 4 minutos.

Arrive começa a frear antes de chegar ao destino.

- Execute com F5 e pressione 2.

- Aguarde cerca de 20 segundos.

Confira: O agente fica próximo do alvo com rapidez próxima de zero.

Compare com o cenário 1, reiniciando com R. O movimento é amortecido e pode ter um pequeno overshoot. O critério do verificador é distância menor que 2 px e rapidez menor que 1 px/s após 20 segundos.


## 14. O raio de chegada

Local: cenas/agente.tscn, nó Agente, Inspector. Tempo: 4 minutos.

Um raio maior faz Arrive reduzir a rapidez mais cedo.

- Mude Raio Chegada para 400, salve e teste o cenário 2.

- Pare o jogo e restaure 260; salve.

Confira: Com 400, o agente começa a frear mais longe.

Selecione a raiz Agente, não Direcoes/Arrive. O valor pertence ao corpo e fica disponível para a estratégia. Mantenha Velocidade Max=180 e Forca Max=280. Salve a cena antes de executar.


## 15. Pursuit

Local: aluno/pursuit.gd, função calcular. Tempo: 5 minutos.

Pursuit usa Seek para mirar uma posição futura do alvo.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(agente) -> Vector2:
    var direcao = agente.alvo.global_position - agente.global_position
    var tempo = minf(direcao.length() / agente.velocidade_max, 1.5)
    var futuro = agente.alvo.global_position + agente.alvo.velocity * tempo
    return $Seek.para(agente, futuro)
```

Confira: A previsão considera a velocidade atual do alvo.

O filho Seek já está pronto na cena. A previsão é limitada a 1,5 segundo para reduzir extrapolações muito longas. O alvo muda de direção nas extremidades, então a previsão é corrigida a cada passo. Aula teórica, slide 24.


## 16. Perseguição com previsão

Local: Jogo, cenário 3. Tempo: 4 minutos.

O alvo verde se move automaticamente neste cenário.

- Execute com F5 e pressione 3.

Confira: O agente mira adiante do alvo e se aproxima dele.

A velocidade do alvo é 100 px/s e a rapidez máxima do agente é 180 px/s. O cenário não aplica dano nem remove os corpos ao se encontrarem. Pursuit não equivale a uma solução analítica de interceptação.


## 17. Verificação da etapa B

Local: verificacao/etapa_b.tscn. Tempo: 4 minutos.

A verificação inclui chegada, previsão e colisão real com a parede.

- Abra etapa_b.tscn e pressione F6.

Confira: A janela termina com 33/33 verificações passaram.

A execução normal leva cerca de um minuto. O teste de Parede demonstra a limitação de steering sem busca de rota. Abra Output para localizar uma eventual falha.


## 18. Registro da etapa B

Local: Terminal, dentro de steering-godot. Tempo: 2 minutos.

Seek, Arrive e Pursuit agora compartilham o mesmo movimento.

- Execute os comandos abaixo.

```
git add aluno/arrive.gd aluno/pursuit.gd
git commit -m "Etapa B: Arrive e Pursuit"
```

Confira: As duas novas estratégias ficam salvas.

Para retomar da solução, preserve a tentativa com git stash push -u e use git switch -c retomada-b etapa-b-arrive-pursuit. Continue nessa nova branch.


## 19. Os componentes do bando

Local: cenas/agente.tscn, Direcoes/Flocking. Tempo: 3 minutos.

Flocking combina separação, alinhamento e coesão.

- Expanda Flocking.

- Confira seus três filhos e o filho Seek de Coesao.

Confira: Cada regra fica em um script separado de aluno/.

Separacao, Alinhamento e Coesao já existem como Node. Não adicione novos nós. O apoio instancia a mesma cena 48 vezes no cenário 4. Referência do modelo: https://www.red3d.com/cwr/boids/


## 20. A vizinhança pronta

Local: apoio/grade.gd, funções reconstruir e consultar. Tempo: 4 minutos.

A grade entrega apenas vizinhos a menos de 100 px.

- Leia os dois métodos; mantenha o arquivo pronto.

Confira: Cada consulta percorre a célula do agente e as oito células próximas.

Células de 100 px permitem examinar uma região 3 por 3. Dictionary e Vector2i são nativos, mas o algoritmo de grade é um script da aula. A consulta exclui o próprio agente e filtra pela distância exata. Todos calculam suas forças antes de qualquer corpo se mover. https://www.red3d.com/cwr/boids/


## 21. Separação

Local: aluno/separacao.gd, função calcular. Tempo: 6 minutos.

Vizinhos muito próximos provocam repulsão.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(agente) -> Vector2:
    var direcao = Vector2.ZERO
    for vizinho in agente.vizinhos:
        var longe = agente.global_position - vizinho.global_position
        if longe.length_squared() > 0 and longe.length() < 36.0:
            direcao += longe / longe.length_squared()
    if direcao.is_zero_approx():
        return Vector2.ZERO
    return direcao.normalized() * agente.velocidade_max - agente.velocity
```

Confira: Até 36 px, um vizinho mais próximo tem maior influência.

longe / comprimento² tem magnitude 1/distância. Ao final, a soma vira uma velocidade desejada. A condição positiva evita divisão por zero em posições coincidentes. Essa situação devolve contribuição zero, não uma direção aleatória. Os boids não têm colisão física entre si.


## 22. Alinhamento

Local: aluno/alinhamento.gd, função calcular. Tempo: 5 minutos.

A velocidade média dos vizinhos vira a velocidade desejada.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(agente) -> Vector2:
    if agente.vizinhos.is_empty():
        return Vector2.ZERO
    var media = Vector2.ZERO
    for vizinho in agente.vizinhos:
        media += vizinho.velocity
    media /= agente.vizinhos.size()
    return media - agente.velocity
```

Confira: Um agente tende a acompanhar o movimento dos vizinhos.

Esta variante acompanha direção e rapidez médias. Ela não normaliza a média para forçar a rapidez máxima, diferentemente do pseudocódigo do slide 30 da teoria. A escolha deixa a fórmula direta e permite ao grupo desacelerar.


## 23. Coesão

Local: aluno/coesao.gd, função calcular. Tempo: 5 minutos.

O centro dos vizinhos funciona como destino de Seek.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(agente) -> Vector2:
    if agente.vizinhos.is_empty():
        return Vector2.ZERO
    var centro = Vector2.ZERO
    for vizinho in agente.vizinhos:
        centro += vizinho.global_position
    centro /= agente.vizinhos.size()
    return $Seek.para(agente, centro)
```

Confira: O agente recebe uma força em direção ao grupo próximo.

A média das posições considera apenas os vizinhos locais entregues pela grade. Sem vizinhos, retorna zero. O filho Seek é uma reutilização do mesmo script escrito na etapa A.


## 24. A soma ponderada

Local: aluno/flocking.gd, função calcular. Tempo: 4 minutos.

Os pesos regulam a influência de cada regra.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(agente) -> Vector2:
    var forca = $Separacao.calcular(agente) * peso_separacao
    forca += $Alinhamento.calcular(agente) * peso_alinhamento
    forca += $Coesao.calcular(agente) * peso_coesao
    return forca
```

Confira: A força final reúne os três componentes.

Preserve os @export acima da função. Pesos iniciais: separação 1,5; alinhamento 1,0; coesão 0,6. O apoio limita a magnitude da soma antes de integrar. Esta é soma ponderada, sem garantia de prioridade.


## 25. Flocking em execução

Local: Jogo, cenário 4. Tempo: 4 minutos.

O apoio instancia 48 cópias da cena do agente.

- Execute com F5 e pressione 4.

Confira: Os agentes mudam de direção conforme os vizinhos próximos.

Observe por alguns segundos. As bordas fazem reaparecer o agente do outro lado, sem espelhar vizinhos na grade. Portanto o mundo não usa distância toroidal. A formação depende dos pesos e pode produzir vários grupos ou movimentos locais. Não há líder ou trajetória desenhada para o bando.


## 26. O peso da separação

Local: cenas/agente.tscn, Direcoes/Flocking, Inspector. Tempo: 4 minutos.

O peso zero retira uma regra da soma.

- Mude Peso Separacao para 0, salve e teste o cenário 4.

- Pare, restaure 1.5 e salve a cena.

Confira: Com peso zero, o grupo tende a ficar mais concentrado.

Use o Inspector da cena local, não o Remote, para que todas as instâncias usem o novo valor. Reinicie o cenário para comparar a mesma distribuição inicial. A separação reduz aglomeração, mas não garante ausência de sobreposição.


## 27. O custo dos vizinhos

Local: Jogo, cenário 4, linha Candidatos. Tempo: 3 minutos.

O contador mede agentes examinados nas células consultadas.

- Pressione R e leia Candidatos.

- Compare com os 2.256 pares possíveis sem a grade.

Confira: No início distribuído, a grade examina menos candidatos.

48 × 47 = 2.256 pares ordenados, excluindo o próprio agente. O contador mede candidatos antes do filtro de distância, não vizinhos aceitos nem tempo de CPU. Com densidade limitada, a grade reduz o trabalho; com todos na mesma região, o pior caso continua quadrático. Não interprete esta demonstração como benchmark de milhares de agentes.


## 28. O cancelamento de forças

Local: Jogo, cenário 5. Tempo: 3 minutos.

Buscar e fugir do mesmo alvo produzem forças opostas em repouso.

- Pressione 5 e observe a rapidez.

Confira: O agente permanece parado, embora o alvo esteja distante.

apoio/cancelamento.gd fornece a demonstração pronta. A soma de Seek e Flee cancela em velocidade zero. Priorizar uma ação pode resolver esse conflito específico, mas apenas ordenar somas não elimina todo cancelamento nem garante chegar ao destino. Aula teórica, slides 25–27.


## 29. A parede e a rota ausente

Local: Jogo, cenário 6. Tempo: 3 minutos.

Arrive aponta para o alvo, mas a colisão impede seguir em linha reta.

- Pressione 6 e aguarde alguns segundos.

Confira: O agente fica junto à parede, sem contornar a concavidade.

StaticBody2D e CollisionShape2D bloqueiam a passagem. Esta atividade não implementa desvio nem busca de caminhos. A cena demonstra a insuficiência de apontar ao alvo quando a rota exige afastar-se dele. O próximo encontro trata da rota. https://www.red3d.com/cwr/steer/gdc99/


## 30. Verificação final

Local: verificacao/etapa_c.tscn. Tempo: 4 minutos.

A cena testa as fórmulas, a grade e a simulação com 48 agentes.

- Abra etapa_c.tscn e pressione F6.

Confira: A janela termina com 46/46 verificações passaram.

A execução normal pode levar cerca de 70 segundos. A verificação cobre limites físicos e casos numéricos, mas a leitura visual e a comparação dos pesos continuam sendo parte da atividade.


## 31. Registro da etapa C

Local: Terminal, dentro de steering-godot. Tempo: 2 minutos.

Registre as regras e a composição do bando.

- Execute os comandos abaixo.

```
git add aluno/
git commit -m "Etapa C: Flocking"
```

Confira: O exercício completo fica salvo na sua branch.

Para consultar a solução final em outra branch, preserve a tentativa com git stash push -u e use git switch -c consulta-final etapa-c-flocking. Os três checkpoints são tags locais.


## 32. Entrega do exercício

Local: Sua branch e respostas da atividade. Tempo: 3 minutos.

A entrega reúne código e observações do movimento.

- Registre as respostas pedidas em docs/ENTREGA.md.

- Entregue sua branch e as respostas pelo canal da turma.

Confira: Explique chegada, previsão, pesos, custo da grade e limite da parede.

A avaliação considera as sete funções, os três verificadores e cinco respostas curtas. Faça a entrega conforme orientação do professor. Nenhum comando dos slides publica o repositório automaticamente.
