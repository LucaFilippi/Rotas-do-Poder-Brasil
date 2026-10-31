# ROTAS DO PODER: BRASIL
## Documento mestre de desenvolvimento — Simulador brasileiro de gestão pública de transportes

### 1. IDENTIDADE DO PROJETO

**Nome:** Rotas do Poder: Brasil

**Gênero:** Simulação econômica, gestão pública, estratégia e transportes.

**Plataforma:** Windows, inicialmente.

**Motor:** Godot 4.x, utilizando GDScript.

**Visual:** 2D, com mapas interativos, veículos animados, painéis administrativos e gráficos econômicos.

**Idioma:** Português brasileiro.

**Modo:** Single-player, offline após instalação dos dados necessários.

**Licença do código:** MIT.

**Objetivo:** Desenvolver um jogo completo, progressivo e expansível em que o jogador assume responsabilidades crescentes na administração dos transportes públicos brasileiros.

O jogo deve equilibrar três objetivos fundamentais:

1. Sustentabilidade financeira das operações.
2. Satisfação da população e dos trabalhadores.
3. Cobertura e eficiência da rede de transportes.

O jogador deve lidar com decisões econômicas, administrativas, técnicas e políticas, sem que o jogo favoreça automaticamente uma ideologia ou estratégia.

Todas as decisões precisam produzir consequências mensuráveis.

---

# 2. CONCEITO E PROGRESSÃO

O jogo terá três grandes etapas de carreira.

## ETAPA 1 — SECRETÁRIO MUNICIPAL DE TRANSPORTES

O jogador começa administrando o sistema municipal de ônibus de uma cidade brasileira.

Suas responsabilidades incluem:

- Gerenciar a empresa municipal de ônibus.
- Criar, remover e modificar linhas.
- Definir tarifas.
- Comprar ônibus.
- Contratar e demitir funcionários.
- Administrar garagens.
- Gerenciar a manutenção da frota.
- Controlar salários.
- Implantar bilhetagem eletrônica.
- Definir pontos e terminais.
- Ajustar horários e frequências.
- Analisar demanda por bairros.
- Controlar superlotação.
- Reduzir congestionamentos operacionais.
- Gerenciar reclamações e satisfação popular.
- Negociar com sindicatos.
- Cumprir metas orçamentárias.
- Administrar contratos e fornecedores.

O jogador não poderá construir novas ruas, avenidas ou rodovias nesse estágio.

O mapa urbano deve usar a malha viária real da cidade selecionada, permitindo desenhar rotas sobre ruas existentes.

## ETAPA 2 — SECRETÁRIO ESTADUAL DE TRANSPORTES

Após demonstrar competência na administração municipal, o jogador poderá receber uma promoção para administrar o transporte público estadual.

A promoção sempre ocorrerá dentro do mesmo estado da cidade inicial.

Exemplo:

Começar em Campinas → tornar-se secretário estadual de São Paulo.

Começar em Londrina → tornar-se secretário estadual do Paraná.

Começar em Uberlândia → tornar-se secretário estadual de Minas Gerais.

O jogador passa a controlar:

- Transporte rodoviário intermunicipal.
- Transporte rodoviário interestadual apenas quando autorizado pelo estágio nacional ou por acordos simulados.
- Transporte ferroviário regional.
- Terminais rodoviários.
- Estações ferroviárias.
- Garagens.
- Depósitos ferroviários.
- Construção de novas ferrovias.
- Compra de locomotivas e vagões.
- Compra de ônibus rodoviários.
- Tarifas de passageiros.
- Contratos de transporte de cargas.
- Manutenção de veículos e infraestrutura.
- Expansão das redes estaduais.
- Rentabilidade individual de ônibus e trens.

Neste estágio, ônibus e ferrovias deverão apresentar resultados financeiros sustentáveis separadamente.

## ETAPA 3 — MINISTRO NACIONAL DOS TRANSPORTES

O jogador recebe uma nomeação fictícia para administrar o sistema nacional de transportes do Brasil.

Neste universo alternativo, o Ministério também controla a aviação pública nacional.

O jogador terá acesso a:

- Transporte rodoviário nacional.
- Transporte ferroviário nacional.
- Transporte aéreo nacional.
- Rotas entre estados.
- Aeroportos.
- Terminais rodoviários nacionais.
- Ferrovias de passageiros e cargas.
- Compra de aeronaves.
- Compra de locomotivas.
- Compra de ônibus.
- Manutenção das três modalidades.
- Planejamento de rotas nacionais.
- Expansão de infraestrutura.
- Contratos logísticos.
- Políticas tarifárias.
- Gestão de empresas públicas.
- Concorrência com operadores privados simulados.

O objetivo financeiro será manter as três modalidades sustentáveis individualmente.

Os resultados das três operações não podem ser misturados para esconder prejuízos de uma modalidade.

---

# 3. SELEÇÃO DA CIDADE INICIAL

O jogador poderá começar em uma das dez cidades mais populosas de cada unidade federativa brasileira.

Para cada um dos 26 estados, selecionar dez municípios, utilizando dados oficiais do IBGE e registrando o ano de referência.

A classificação deverá ser gerada a partir dos dados oficiais, nunca de uma lista inventada.

O Distrito Federal precisa de tratamento especial, porque não possui municípios como os estados. Para permitir dez opções iniciais, usar regiões administrativas do DF, identificadas corretamente como regiões administrativas, não como municípios.

A tela de seleção deverá mostrar:

- Estado.
- Cidade ou região administrativa.
- População.
- Área.
- Densidade demográfica.
- Estimativa inicial de demanda por transporte.
- Complexidade operacional.
- Quantidade inicial de ônibus.
- Quantidade de linhas disponíveis.
- Dificuldade estimada.

O jogador deve poder navegar por um mapa brasileiro, selecionar um estado e visualizar as dez opções disponíveis.

A cidade inicial determinará o estado da futura promoção.

Na etapa nacional, o território será sempre o Brasil inteiro.

O sistema deverá carregar somente os dados geográficos necessários à cidade selecionada.

---

# 4. SISTEMA DE MAPAS

## 4.1. Mapa municipal

Utilizar OpenStreetMap como fonte principal de ruas.

Usar dados do IBGE para limites administrativos.

Preparar os dados com Python antes de disponibilizá-los ao Godot.

Não depender de Google Maps nem de serviços pagos.

O mapa deverá representar:

- Ruas e avenidas.
- Sentidos de circulação.
- Vias com restrição de acesso.
- Pontes.
- Túneis.
- Cruzamentos.
- Rodovias urbanas.
- Bairros, quando disponíveis.
- Terminais.
- Pontos de ônibus.
- Garagens.
- Áreas de maior demanda.
- Áreas residenciais.
- Áreas comerciais.
- Áreas industriais.

A geometria viária deverá preservar os dados reais disponíveis, sem redesenhar arbitrariamente as ruas.

A representação visual poderá ser estilizada para manter o desempenho.

Não é necessário exibir cada edifício.

Criar zoom, movimentação por arraste e seleção de objetos.

O jogo deve permitir visualizar camadas:

1. Mapa normal.
2. Demanda de passageiros.
3. Congestionamento.
4. Cobertura do transporte.
5. Satisfação da população.
6. Rentabilidade das linhas.
7. Localização dos ônibus.
8. Problemas operacionais.

Quando pontos de ônibus reais estiverem disponíveis, utilizá-los como preset inicial.

Quando não estiverem, gerar pontos sugeridos com algoritmos espaciais e identificá-los como estimados.

Não gerar rotas que atravessem edifícios, rios ou ruas incompatíveis com o sentido de circulação.

## 4.2. Mapa estadual

Exibir os municípios e as conexões rodoviárias e ferroviárias relevantes.

O mapa não precisa representar cada rua urbana.

Representar:

- Municípios.
- Rodovias.
- Ferrovias existentes.
- Terminais.
- Estações.
- Centros industriais.
- Centros agrícolas.
- Polos comerciais.
- Centros logísticos.
- Regiões metropolitanas.

A rede ferroviária existente deve ser diferenciada das ferrovias construídas pelo jogador.

As rotas precisam respeitar conexões geográficas válidas.

## 4.3. Mapa nacional

Exibir o Brasil inteiro, incluindo:

- Estados.
- Capitais.
- Principais cidades.
- Rodovias estruturantes.
- Ferrovias.
- Aeroportos.
- Centros logísticos.
- Rotas aéreas.
- Regiões econômicas.

As rotas aéreas deverão ser desenhadas entre aeroportos reais, com animação de aeronaves no mapa.

Os dados geográficos precisam ser versionados e acompanhados de atribuição de fonte e licença.

---

# 5. SIMULAÇÃO ECONÔMICA

Criar um motor econômico determinístico e verificável.

A economia deve ser baseada em:

- Receitas tarifárias.
- Receitas de transporte de cargas.
- Custos de combustível.
- Energia elétrica.
- Salários.
- Encargos.
- Manutenção.
- Seguros.
- Aquisição de veículos.
- Depreciação.
- Infraestrutura.
- Administração.
- Financiamentos.
- Subsídios públicos, quando autorizados.
- Investimentos.
- Inflação simulada.
- Variações de demanda.

Cada modalidade terá seu próprio demonstrativo financeiro.

O jogador poderá consultar:

- Receita diária.
- Receita mensal.
- Custos operacionais.
- Lucro ou prejuízo operacional.
- Fluxo de caixa.
- Dívida.
- Custo por passageiro.
- Receita por passageiro.
- Custo por quilômetro.
- Receita por quilômetro.
- Taxa de ocupação.
- Ponto de equilíbrio.
- Retorno sobre investimentos.

Distinguir lucro contábil, resultado operacional e fluxo de caixa.

Os veículos comprados não devem ser tratados integralmente como despesa operacional do dia.

Criar relatórios financeiros detalhados e gráficos históricos.

Os valores iniciais serão parâmetros fictícios calibráveis, não afirmações sobre custos reais de operadores brasileiros.

---

# 6. GESTÃO MUNICIPAL DE ÔNIBUS

Esta será a primeira modalidade implementada e deverá ser a base do desenvolvimento.

## 6.1. Compra de ônibus

Criar um catálogo de ônibus fictícios, com especificações inspiradas em categorias reais.

Categorias:

- Micro-ônibus.
- Midiônibus.
- Ônibus convencional.
- Ônibus padron.
- Ônibus articulado.
- Ônibus biarticulado.
- Ônibus elétrico.

Cada modelo terá:

- Preço.
- Capacidade sentada.
- Capacidade total.
- Consumo energético.
- Velocidade operacional.
- Custo de manutenção.
- Vida útil estimada.
- Conforto.
- Acessibilidade.
- Presença de ar-condicionado.
- Idade.
- Quilometragem.
- Confiabilidade.
- Estado de conservação.

Permitir comprar veículos novos e usados.

Veículos usados serão mais baratos, mas poderão exigir mais manutenção.

Permitir vender ou retirar veículos da frota.

## 6.2. Gestão de motoristas

Cada motorista terá:

- Nome fictício.
- Idade fictícia.
- Salário.
- Experiência.
- Habilidade.
- Satisfação profissional.
- Jornada de trabalho.
- Histórico de incidentes.
- Horas extras.
- Ausências.
- Fadiga.

O jogador definirá:

- Quantidade de motoristas.
- Salário-base.
- Escalas.
- Jornada.
- Treinamentos.
- Benefícios.
- Contratações.
- Demissões.

Não permitir que um ônibus opere sem motorista disponível.

Respeitar regras de descanso e limites de jornada definidos pelo modelo do jogo.

Motoristas sobrecarregados terão maior risco de ausência, erros operacionais e insatisfação.

## 6.3. Cobradores e bilhetagem

O jogador começará com um sistema tradicional de cobrança.

Poderá:

- Contratar cobradores.
- Definir salários.
- Alterar escalas.
- Comprar equipamentos de bilhetagem.
- Implantar cartões.
- Instalar validadores.
- Implantar pagamento digital.
- Automatizar a cobrança.
- Reorganizar ou reduzir postos de cobrador.

A automação deverá exigir investimento inicial.

Poderá reduzir custos recorrentes, mas também produzir:

- Custos de manutenção dos validadores.
- Necessidade de suporte.
- Resistência de funcionários.
- Negociações sindicais.
- Custos de transição.
- Problemas técnicos.
- Reações da população.

Não presumir que automatizar seja sempre vantajoso.

## 6.4. Definição das tarifas

O jogador poderá definir:

- Tarifa comum.
- Tarifa estudantil.
- Integração.
- Passes mensais.
- Descontos.
- Gratuidade para categorias previstas no cenário.
- Tarifas diferenciadas quando permitidas pelas regras fictícias.

O preço afetará:

- Receita.
- Demanda.
- Acessibilidade econômica.
- Evasão.
- Satisfação.
- Reputação.
- Pressão política.

Aumentos excessivos poderão provocar protestos.

Tarifas muito baixas poderão elevar a demanda e produzir prejuízos.

O jogo deverá permitir comparar cenários antes de aplicar mudanças.

## 6.5. Criação de linhas

O jogador selecionará pontos no mapa para desenhar uma linha.

O sistema calculará automaticamente um caminho viário válido.

O jogador poderá:

- Definir origem.
- Definir destino.
- Adicionar pontos intermediários.
- Definir percurso de ida.
- Definir percurso de volta.
- Nomear a linha.
- Definir número da linha.
- Escolher veículos.
- Definir horários.
- Definir frequência.
- Definir número de ônibus.
- Definir tarifa aplicável.
- Criar linhas expressas.
- Criar linhas circulares.
- Criar linhas alimentadoras.
- Criar linhas noturnas.

O sistema deverá calcular:

- Distância.
- Tempo estimado.
- Demanda.
- Quantidade recomendada de veículos.
- Quantidade de motoristas.
- Custo diário.
- Receita esperada.
- Cobertura populacional.
- Superposição com outras linhas.

O jogador poderá editar ou remover linhas.

Antes de remover uma linha, mostrar quantos passageiros poderão ficar sem atendimento.

## 6.6. Pontos de ônibus

Criar um preset inicial de pontos para cada cidade.

Permitir:

- Criar pontos.
- Remover pontos.
- Mover pontos.
- Criar terminais.
- Criar pontos de integração.
- Instalar abrigos.
- Melhorar iluminação.
- Adicionar informações de horários.
- Adicionar acessibilidade.

Cada ponto terá uma área de cobertura configurável.

A distância até o ponto influenciará a decisão do cidadão de usar o ônibus.

## 6.7. Trânsito

Criar um sistema de congestionamento baseado na malha viária.

Cada segmento terá:

- Comprimento.
- Velocidade permitida.
- Capacidade estimada.
- Fluxo de veículos.
- Nível de congestionamento.
- Velocidade operacional.
- Ocorrências temporárias.

O congestionamento deverá variar por horário.

Simular:

- Horário de pico da manhã.
- Horário de pico da tarde.
- Horários intermediários.
- Madrugada.
- Finais de semana.

O jogador deverá poder alterar rotas para evitar congestionamentos.

Também poderá modificar frequências e horários.

A simulação não precisa representar todos os carros individualmente.

Usar fluxos agregados para preservar desempenho.

## 6.8. Manutenção

Cada ônibus terá componentes e condições próprias.

Componentes principais:

- Motor.
- Transmissão.
- Freios.
- Pneus.
- Suspensão.
- Sistema elétrico.
- Portas.
- Ar-condicionado.
- Sistema de bilhetagem.

Cada veículo terá um índice de conservação.

As inspeções apresentarão dois resultados principais:

**AINDA RODA**

O veículo apresenta desgaste ou problemas não críticos.

Mostrar:

- Defeitos encontrados.
- Custo estimado.
- Prazo recomendado.
- Consequências de adiar o reparo.

**NECESSITA CONSERTO**

O veículo apresenta falha relevante.

Mostrar:

- Defeito.
- Gravidade.
- Orçamento.
- Tempo estimado de oficina.
- Peças necessárias.

O jogador poderá aprovar ou rejeitar reparos não críticos.

Falhas críticas de segurança deverão impedir a operação do veículo.

Permitir ao jogador alterar intervalos de manutenção preventiva, respeitando os limites mínimos de segurança estabelecidos pelo jogo.

Adiar manutenção deverá elevar a probabilidade de falhas e custos futuros.

Não usar acidentes graves como eventos puramente aleatórios sem relação com as condições operacionais.

## 6.9. Corte de custos

Permitir decisões como:

- Retirar ar-condicionado de determinados serviços.
- Reduzir frequência.
- Substituir ônibus grandes por menores.
- Comprar veículos usados.
- Automatizar bilhetagem.
- Reduzir gastos administrativos.
- Renegociar fornecedores.
- Reduzir serviços de conforto.
- Adiar manutenção não crítica.
- Reorganizar escalas.
- Encerrar linhas deficitárias.

Cada medida terá impacto financeiro e social.

Mostrar uma previsão antes da decisão.

Exemplo:

"Desativar ar-condicionado em 30 ônibus"

Economia mensal estimada: R$ 18.000.

Possíveis efeitos:

- Menor consumo de combustível.
- Redução de conforto.
- Aumento de reclamações.
- Menor atratividade em dias quentes.
- Potencial redução de passageiros.

Os números deverão vir dos parâmetros da simulação, não de valores fixos aplicados a todas as cidades.

---

# 7. SIMULAÇÃO DA POPULAÇÃO

Criar um modelo populacional por zonas e perfis.

Não simular individualmente todos os habitantes de São Paulo.

Usar agentes estatísticos e grupos representativos.

Perfis:

- Trabalhadores.
- Estudantes.
- Aposentados.
- Turistas.
- Pessoas com mobilidade reduzida.
- Passageiros ocasionais.
- Passageiros de baixa renda.
- Passageiros de renda média.
- Passageiros de renda alta.

Cada grupo terá preferências diferentes.

A demanda dependerá de:

- População.
- Empregos.
- Escolas.
- Hospitais.
- Comércio.
- Distância até pontos.
- Tarifa.
- Frequência.
- Tempo de viagem.
- Conforto.
- Segurança.
- Lotação.
- Disponibilidade de alternativas.

Criar uma matriz origem-destino estimada entre zonas.

Permitir que os cidadãos escolham não utilizar ônibus quando o serviço for ruim ou caro.

## 7.1. Passageiros não atendidos

Criar um sistema que identifique:

- Bairros sem cobertura.
- Pontos sobrecarregados.
- Demanda reprimida.
- Regiões com poucos horários.
- Linhas superlotadas.
- Regiões com viagens excessivamente longas.
- Conexões deficientes.

O sistema deverá gerar alertas como:

"Região norte: aproximadamente 1.800 viagens diárias sem atendimento adequado."

"Nova linha recomendada entre Bairro A e Terminal B."

"Demanda elevada após as 18h."

Os cálculos devem ser reproduzíveis e baseados nos dados da simulação.

---

# 8. INTELIGÊNCIA ARTIFICIAL

Criar dois sistemas distintos.

## 8.1. IA de simulação

Esta IA será responsável por comportamentos econômicos e sociais.

Preferir inicialmente algoritmos determinísticos, modelos estatísticos, regras de decisão e agentes simulados.

Não exigir APIs externas.

Responsabilidades:

- Estimar demanda.
- Escolher viagens.
- Calcular satisfação.
- Avaliar reações às tarifas.
- Simular decisões dos trabalhadores.
- Estimar risco de greve.
- Identificar passageiros não atendidos.
- Simular concorrentes.
- Identificar rotas ineficientes.
- Gerar propostas de melhoria.

A IA deve utilizar variáveis reais do jogo.

Não gerar decisões completamente aleatórias sem explicação.

## 8.2. IA conselheira

Criar um assessor virtual dentro do jogo.

O assessor poderá informar:

- Problemas operacionais.
- Riscos financeiros.
- Oportunidades.
- Previsões.
- Recomendações.
- Consequências prováveis.

Exemplo:

"Secretário, a Linha 204 opera com ocupação média de 94% no horário de pico. Recomendo adicionar dois ônibus."

Outro exemplo:

"O reajuste tarifário proposto poderá melhorar a receita por passageiro, mas reduzir a demanda e aumentar a insatisfação."

Inicialmente, usar um motor de recomendações baseado em regras e templates.

Arquitetar uma interface opcional para modelos de linguagem no futuro, mas não tornar o jogo dependente de internet ou de API paga.

---

# 9. SATISFAÇÃO POPULAR E REPUTAÇÃO

Criar indicadores separados:

- Satisfação dos passageiros.
- Satisfação dos trabalhadores.
- Reputação do secretário.
- Qualidade do serviço.
- Cobertura.
- Pontualidade.
- Segurança.
- Conforto.
- Acessibilidade.
- Sustentabilidade financeira.

A satisfação não poderá ser determinada somente pelo preço.

Um serviço barato, mas lotado e atrasado, também deverá gerar reclamações.

Criar um sistema de notícias fictícias.

Exemplos:

"Moradores reclamam da ausência de ônibus após as 22h."

"Nova linha reduz tempo de deslocamento entre bairros."

"Motoristas ameaçam paralisação após negociação salarial."

"Empresa municipal registra primeiro superávit anual."

Os eventos devem refletir o estado real da simulação.

---

# 10. GREVES, PROTESTOS E EVENTOS

Criar um sistema de eventos dinâmicos.

Possíveis eventos:

- Greve de motoristas.
- Paralisação de cobradores.
- Protesto contra tarifas.
- Aumento do diesel.
- Escassez de peças.
- Chuvas intensas.
- Alagamentos.
- Obras em avenidas.
- Acidentes de trânsito.
- Falhas mecânicas.
- Crescimento populacional.
- Abertura de centros comerciais.
- Fechamento de fábricas.
- Novas universidades.
- Grandes eventos esportivos.
- Períodos de férias.
- Crises econômicas.
- Mudanças de governo.

Os eventos devem ter duração, intensidade e consequências.

Permitir ao jogador responder por meio de decisões.

Exemplo de greve:

- Aceitar reajuste salarial.
- Negociar reajuste parcial.
- Oferecer benefícios.
- Reorganizar escalas.
- Manter a proposta atual e enfrentar a paralisação.

Cada opção terá custos, riscos e consequências.

---

# 11. PROGRESSÃO POLÍTICA

O jogador não será automaticamente promovido por ganhar dinheiro.

A progressão deverá depender de desempenho.

Indicadores:

- Rentabilidade.
- Cobertura.
- Satisfação popular.
- Eficiência.
- Segurança.
- Reputação.
- Cumprimento de metas.
- Capacidade administrativa.

Criar avaliações periódicas de governo.

O jogador deverá administrar sua relação com um prefeito fictício.

O prefeito terá objetivos e prioridades.

Exemplos:

- Reduzir gastos.
- Aumentar cobertura.
- Melhorar satisfação.
- Modernizar a frota.
- Reduzir emissões.
- Expandir transporte noturno.

As prioridades poderão variar entre governos fictícios.

Evitar utilizar políticos reais como personagens obrigatórios.

## 11.1. Promoção municipal

Após atingir metas mínimas por determinado período, o jogador poderá receber convite para o governo estadual.

A promoção deverá considerar desempenho consistente, e não apenas um mês de resultados positivos.

## 11.2. Promoção estadual

Após administrar satisfatoriamente ônibus e ferrovias, o jogador poderá receber convite para o governo federal.

A promoção será sempre para o Brasil.

## 11.3. Demissão e fracasso

O jogador poderá perder o cargo por:

- Crises financeiras persistentes.
- Baixa satisfação.
- Falhas administrativas graves.
- Descumprimento de metas.
- Colapso operacional.

Criar opções de dificuldade e recuperação, evitando que qualquer erro pequeno encerre a partida.

---

# 12. ETAPA ESTADUAL — TRANSPORTE RODOVIÁRIO

Criar uma nova interface de gestão de linhas intermunicipais.

O jogador poderá:

- Comprar ônibus rodoviários.
- Criar rotas entre municípios.
- Definir paradas.
- Escolher terminais.
- Definir horários.
- Definir tarifas.
- Definir serviços convencionais e executivos.
- Comprar garagens.
- Contratar motoristas.
- Controlar manutenção.
- Monitorar ocupação.
- Avaliar lucro por rota.

A demanda dependerá de:

- População das cidades.
- Distância.
- Atividade econômica.
- Turismo.
- Preço.
- Tempo de viagem.
- Concorrência.
- Frequência.

As rotas deverão usar conexões rodoviárias válidas.

O sistema deverá calcular distância e tempo de viagem a partir da rede viária simplificada.

---

# 13. ETAPA ESTADUAL — FERROVIAS

O jogador poderá administrar ferrovias existentes e construir novas linhas dentro das regras do cenário fictício.

## 13.1. Construção ferroviária

Permitir:

- Selecionar origem.
- Selecionar destino.
- Desenhar traçado aproximado.
- Construir estações.
- Construir terminais de carga.
- Construir depósitos.
- Escolher tipo de ferrovia.
- Eletrificar trechos.
- Duplicar vias.
- Modernizar infraestrutura.

O custo dependerá de:

- Distância.
- Relevo.
- Pontes.
- Túneis.
- Terrenos.
- Tipo de via.
- Capacidade.
- Tecnologia.

A construção levará tempo no calendário do jogo.

Não permitir que uma ferrovia seja construída instantaneamente.

## 13.2. Compra de trens

Categorias:

- Trem regional.
- Trem metropolitano.
- Trem de longa distância.
- Locomotiva diesel.
- Locomotiva elétrica.
- Vagão de passageiros.
- Vagão de carga geral.
- Vagão graneleiro.
- Vagão-tanque.
- Vagão de contêineres.

Cada unidade terá:

- Preço.
- Capacidade.
- Velocidade.
- Consumo.
- Manutenção.
- Confiabilidade.
- Vida útil.
- Compatibilidade de bitola.
- Compatibilidade com a infraestrutura.

## 13.3. Operação ferroviária

Permitir:

- Criar serviços.
- Definir horários.
- Definir tarifas.
- Definir composição dos trens.
- Contratar maquinistas.
- Contratar equipes de manutenção.
- Administrar estações.
- Transportar passageiros.
- Transportar mercadorias.
- Assinar contratos de cargas.

Criar demandas de cargas como:

- Soja.
- Milho.
- Minério.
- Combustível.
- Contêineres.
- Produtos industriais.

A localização de produtores e consumidores deverá influenciar a demanda.

As ferrovias poderão competir com o transporte rodoviário.

Uma ferrovia poderá reduzir custos logísticos, mas exigir investimentos iniciais elevados.

---

# 14. ETAPA NACIONAL — AVIAÇÃO

No cenário fictício, o governo federal poderá operar uma empresa pública nacional de aviação.

O jogador será responsável por torná-la financeiramente sustentável.

## 14.1. Aeroportos

Usar aeroportos brasileiros reais como referência geográfica.

Dados deverão vir de fontes públicas, como ANAC e bases aeronáuticas oficiais apropriadas.

Representar:

- Localização.
- Capacidade.
- Infraestrutura.
- Limitações operacionais.
- Custos.
- Demanda estimada.
- Conectividade.
- Disponibilidade de slots simulados.

Permitir negociar utilização e investir em infraestrutura dentro das regras fictícias.

## 14.2. Aeronaves

Criar categorias de aeronaves fictícias inspiradas em tipos reais:

- Turboélice regional.
- Jato regional.
- Jato de corredor único.
- Aeronave de grande capacidade.
- Aeronave cargueira.

Cada aeronave terá:

- Preço.
- Capacidade.
- Alcance.
- Consumo de combustível.
- Velocidade.
- Custos de manutenção.
- Confiabilidade.
- Vida útil.
- Necessidade de tripulação.
- Restrições aeroportuárias.

Permitir comprar, vender e arrendar aeronaves.

## 14.3. Rotas aéreas

O jogador poderá:

- Selecionar aeroporto de origem.
- Selecionar aeroporto de destino.
- Definir frequência.
- Definir horários.
- Definir preço.
- Alocar aeronaves.
- Configurar capacidade.
- Definir serviços.
- Administrar tripulações.
- Monitorar rentabilidade.

A demanda dependerá de:

- População.
- Distância.
- Turismo.
- Economia regional.
- Preço.
- Concorrência.
- Tempo total de viagem.
- Frequência.
- Conexões.

O sistema deverá simular:

- Ocupação.
- Custos por voo.
- Receita por voo.
- Consumo de combustível.
- Atrasos.
- Cancelamentos.
- Manutenção.
- Sazonalidade.
- Reputação.

Permitir conexões entre voos, respeitando tempos mínimos de transferência.

Criar concorrentes privados fictícios.

Não utilizar marcas ou identidades comerciais reais sem necessidade.

---

# 15. CONCORRÊNCIA ENTRE MODAIS

As modalidades não deverão funcionar isoladamente.

Exemplo:

O jogador constrói uma ferrovia rápida entre duas cidades.

Consequências possíveis:

- Redução da demanda rodoviária.
- Aumento da demanda ferroviária.
- Redução do tempo de viagem.
- Alteração da rentabilidade das linhas.
- Maior satisfação.
- Mudança na demanda por outros serviços.

Outro exemplo:

Uma nova rota aérea pode competir com viagens rodoviárias muito longas.

Criar um sistema de escolha modal baseado em:

- Preço.
- Tempo.
- Conforto.
- Frequência.
- Confiabilidade.
- Distância.
- Acessibilidade.

A população deverá escolher entre alternativas disponíveis.

Não duplicar passageiros artificialmente entre modais.

---

# 16. REGRAS DE RENTABILIDADE

O jogo deverá acompanhar os resultados de cada modalidade.

## Municipal

A empresa municipal de ônibus deverá alcançar sustentabilidade financeira.

## Estadual

O transporte rodoviário e ferroviário deverão alcançar sustentabilidade financeira separadamente.

## Nacional

Rodoviário, ferroviário e aéreo deverão alcançar sustentabilidade financeira separadamente.

Criar duas condições financeiras distintas:

1. Resultado operacional não negativo.
2. Fluxo de caixa suficiente para manter a operação.

O jogador poderá receber subsídios transparentes em dificuldades que permitam essa mecânica.

Os subsídios deverão aparecer separadamente das receitas comerciais.

Uma operação não poderá ser declarada lucrativa apenas por receber transferências governamentais.

O modo padrão deverá permitir investimentos públicos em infraestrutura, mas exigir rentabilidade operacional das empresas.

Criar também um modo de dificuldade avançada em que os investimentos de capital precisam ser recuperados ao longo do tempo.

---

# 17. ORÇAMENTO PÚBLICO

Criar um orçamento governamental separado das empresas operadoras.

O orçamento poderá financiar:

- Infraestrutura.
- Modernização.
- Novos terminais.
- Ferrovias.
- Equipamentos.
- Programas de acessibilidade.
- Projetos de expansão.

Os recursos públicos não deverão ser infinitos.

O jogador deverá justificar investimentos por indicadores de retorno econômico e social.

Criar relatórios de:

- Orçamento aprovado.
- Orçamento utilizado.
- Investimentos em andamento.
- Custo projetado.
- Prazo de conclusão.
- Benefícios esperados.
- Desvios de custo.

A liberação de verbas poderá depender de desempenho e eventos políticos fictícios.

---

# 18. INTERFACE DO JOGO

Criar uma interface moderna, limpa e funcional.

Estética:

- Mapa 2D como elemento principal.
- Painéis laterais.
- Indicadores no topo.
- Ícones simples.
- Cores consistentes.
- Gráficos econômicos.
- Menus acessíveis.
- Animações discretas.

## 18.1. Tela principal municipal

Topo:

- Cidade.
- Data.
- Saldo.
- Receita.
- Despesa.
- Resultado operacional.
- Satisfação.
- Reputação.
- Velocidade da simulação.

Lateral esquerda:

- Mapa.
- Linhas.
- Frota.
- Funcionários.
- Garagens.
- Pontos.
- Tarifas.
- Manutenção.
- Finanças.
- População.
- Notícias.
- Governo.

Lateral direita contextual:

Exibir detalhes do elemento selecionado.

## 18.2. Tela de frota

Tabela com:

- Prefixo.
- Modelo.
- Idade.
- Quilometragem.
- Condição.
- Linha atribuída.
- Motorista.
- Custo.
- Disponibilidade.

Permitir filtros e ordenação.

## 18.3. Tela de linhas

Mostrar:

- Nome.
- Número.
- Percurso.
- Passageiros.
- Ocupação.
- Receita.
- Despesa.
- Resultado.
- Pontualidade.
- Satisfação.

Permitir clicar em uma linha para destacá-la no mapa.

## 18.4. Tela financeira

Mostrar:

- Demonstrativo mensal.
- Receitas.
- Despesas.
- Resultado.
- Fluxo de caixa.
- Custos por categoria.
- Evolução histórica.
- Previsões.

## 18.5. Tela política

Mostrar:

- Prefeito, governador ou presidente fictício.
- Metas do governo.
- Reputação.
- Aprovação.
- Desempenho.
- Eventos.
- Condições de promoção.

---

# 19. TEMPO E SIMULAÇÃO

Criar calendário interno.

Velocidades:

- Pausado.
- 1x.
- 2x.
- 5x.
- 10x.

Permitir simulação contínua e avanço por dias.

A economia deverá consolidar resultados diários e mensais.

A movimentação visual dos veículos poderá ser simplificada quando o jogador acelerar o tempo.

Não exigir que todos os ônibus, trens e aviões sejam simulados individualmente a cada segundo.

Usar simulação agregada quando necessário.

O sistema deverá manter resultados coerentes independentemente da velocidade escolhida.

---

# 20. DIFICULDADES

Criar três dificuldades.

## Fácil

- Capital inicial maior.
- Menor pressão política.
- Demanda mais previsível.
- Custos moderados.
- Mais tempo para corrigir problemas.

## Normal

- Economia equilibrada.
- Eventos regulares.
- Concorrência.
- Pressão por resultados.
- Risco de demissão.

## Difícil

- Capital limitado.
- Concorrência mais forte.
- Crises econômicas.
- Pressão sindical.
- Maior exigência de rentabilidade.
- Menor tolerância política a resultados ruins.

Não modificar arbitrariamente as regras fundamentais da contabilidade entre dificuldades.

---

# 21. SISTEMA DE SALVAMENTO

Implementar:

- Novo jogo.
- Carregar jogo.
- Salvar jogo.
- Salvamento automático.
- Múltiplas partidas.
- Histórico de decisões.
- Versão do arquivo de salvamento.

Salvar:

- Cidade inicial.
- Estado.
- Cargo atual.
- Data.
- Dinheiro.
- Frota.
- Linhas.
- Funcionários.
- Infraestrutura.
- Indicadores.
- Eventos.
- Histórico financeiro.
- Condições de promoção.

Utilizar SQLite para os dados estruturados e uma camada de persistência versionada.

Evitar corrupção dos arquivos durante salvamento.

---

# 22. ARQUITETURA TÉCNICA

Utilizar Godot 4.x e GDScript.

Separar os sistemas em módulos:

- GameManager
- TimeManager
- EconomyManager
- GeographyManager
- PopulationManager
- DemandManager
- RouteManager
- FleetManager
- EmployeeManager
- MaintenanceManager
- SatisfactionManager
- PoliticalManager
- EventManager
- AIAdvisor
- SaveManager
- UIManager

Criar módulos específicos para:

- BusSimulation
- RailwaySimulation
- AviationSimulation

A lógica econômica não deverá depender diretamente da interface gráfica.

A simulação deverá ser testável sem abrir o mapa.

Utilizar Python 3.11 para preparar dados geográficos.

Criar ferramentas de importação para:

- OpenStreetMap.
- IBGE.
- Dados ferroviários públicos.
- Dados aeroportuários públicos.
- Dados demográficos.

Não depender de requisições online durante uma partida.

Usar arquivos geográficos preparados e cacheados.

Escolher um formato espacial eficiente para distribuição.

Não incorporar dados de terceiros sem verificar suas licenças e condições de redistribuição.

Para SQLite no Godot, escolher uma integração compatível, documentada e mantida, ou implementar uma camada local equivalente que não exija serviços externos.

---

# 23. OTIMIZAÇÃO

O jogo deverá funcionar em computadores modestos.

Referência inicial:

- Windows 10/11.
- 8 GB de RAM como meta mínima de projeto.
- 16 GB recomendados.
- Sem necessidade de GPU dedicada.

Implementar:

- Carregamento sob demanda.
- Simplificação visual conforme zoom.
- Renderização apenas de objetos visíveis.
- Atualizações de simulação em intervalos.
- Agrupamento de passageiros.
- Cache de rotas.
- Grafos de ruas otimizados.
- Simulação econômica desacoplada da renderização.

Grandes cidades, como São Paulo, não poderão exigir simulação individual de milhões de pessoas.

---

# 24. TUTORIAL

Criar um tutorial interativo.

O jogador deverá aprender a:

1. Navegar pelo mapa.
2. Selecionar linhas.
3. Comprar um ônibus.
4. Contratar motorista.
5. Criar uma rota.
6. Definir horários.
7. Ajustar tarifas.
8. Consultar a demanda.
9. Realizar manutenção.
10. Consultar finanças.
11. Resolver reclamações.
12. Cumprir metas do governo.

O tutorial deverá usar situações reais da simulação.

Não criar um tutorial baseado apenas em textos extensos.

---

# 25. DESENVOLVIMENTO POR FASES

Não tentar implementar todas as modalidades simultaneamente.

## FASE 1 — Protótipo municipal

Entregar uma versão jogável com:

- Menu inicial.
- Seleção de cidade.
- Carregamento de um mapa urbano real.
- Pan e zoom.
- Pontos de ônibus.
- Criação de linhas.
- Frota básica.
- Compra de ônibus.
- Contratação de motoristas.
- Tarifas.
- Demanda simplificada.
- Receita e despesa.
- Simulação diária.
- Satisfação básica.
- Salvamento.

A primeira cidade de desenvolvimento será Campinas, São Paulo.

Campinas será somente a cidade usada para validar o protótipo, não a única opção planejada.

O protótipo deverá permitir criar uma empresa municipal, operar linhas e acompanhar seu resultado financeiro.

## FASE 2 — Gestão municipal avançada

Adicionar:

- Manutenção detalhada.
- Cobradores.
- Bilhetagem eletrônica.
- Salários.
- Escalas.
- Congestionamento.
- Demanda por horários.
- Eventos.
- Greves.
- Protestos.
- Satisfação detalhada.
- Assessoria inteligente.
- Garagens.
- Relatórios financeiros.
- Sistema de reputação.

## FASE 3 — Expansão geográfica

Adicionar:

- Catálogo de dez cidades por estado.
- Tratamento especial do Distrito Federal.
- Importação de mapas.
- Presets por cidade.
- Seleção no mapa brasileiro.
- Otimização para cidades grandes.

## FASE 4 — Carreira municipal

Adicionar:

- Metas políticas.
- Avaliações.
- Risco de demissão.
- Sistema de promoção.
- Histórico da carreira.

## FASE 5 — Governo estadual

Adicionar:

- Mapa estadual.
- Transporte rodoviário intermunicipal.
- Terminais.
- Ônibus rodoviários.
- Demanda entre municípios.
- Sistema ferroviário.
- Construção de ferrovias.
- Compra de locomotivas.
- Passageiros e cargas.
- Gestão financeira independente por modalidade.

## FASE 6 — Governo federal

Adicionar:

- Mapa nacional.
- Integração entre estados.
- Aeroportos.
- Compra de aeronaves.
- Rotas aéreas.
- Gestão de tripulações.
- Concorrência aérea.
- Demanda nacional.
- Gestão simultânea dos três modais.

## FASE 7 — Polimento e lançamento

Adicionar:

- Balanceamento econômico.
- Melhorias visuais.
- Animações.
- Sons.
- Tutoriais completos.
- Estatísticas.
- Conquistas.
- Otimizações.
- Correção de bugs.
- Testes de partidas longas.
- Empacotamento para Windows.

---

# 26. TESTES OBRIGATÓRIOS

Criar testes para:

- Cálculo de tarifas.
- Receitas.
- Custos.
- Depreciação.
- Fluxo de caixa.
- Demanda.
- Satisfação.
- Funcionamento das linhas.
- Disponibilidade de motoristas.
- Manutenção.
- Consumo.
- Promoção.
- Salvamento.
- Carregamento.
- Roteamento.
- Evolução temporal.

Testar cenários como:

- Tarifa muito alta.
- Tarifa muito baixa.
- Ausência de motoristas.
- Falta de manutenção.
- Linha superlotada.
- Linha sem passageiros.
- Greve.
- Aumento do combustível.
- Empresa com caixa negativo.
- Cidade sem dados completos.
- Falha na importação de mapas.
- Salvamento interrompido.
- Grande quantidade de linhas.

O sistema não poderá gerar dinheiro do nada nem duplicar passageiros por erro de cálculo.

Criar testes de regressão e partidas simuladas de longa duração.

---

# 27. PRINCÍPIOS DE DESIGN

O jogo deverá ser divertido antes de ser excessivamente complexo.

A profundidade deverá surgir progressivamente.

Evitar:

- Menus excessivamente confusos.
- Microgerenciamento desnecessário.
- Eventos completamente arbitrários.
- Dificuldade baseada em números injustos.
- Simulações que travam em cidades grandes.
- Dependência de APIs pagas.
- Decisões sem consequências.
- Mecânicas econômicas inconsistentes.

Priorizar:

- Clareza.
- Estratégia.
- Progressão.
- Decisões difíceis.
- Feedback visual.
- Dados geográficos reais.
- Economia coerente.
- Boa performance.
- Possibilidade de expansão.

---

# 28. INSTRUÇÕES PARA O AGENTE DESENVOLVEDOR

Você atuará como arquiteto de software, programador Godot, designer de sistemas econômicos e desenvolvedor de jogos de simulação.

Este documento representa a visão completa do produto.

Não interprete todas as funcionalidades como uma ordem para implementá-las simultaneamente.

Primeiro:

1. Analise os requisitos.
2. Identifique dependências técnicas.
3. Valide as fontes de dados geográficos.
4. Proponha a arquitetura do repositório.
5. Defina o esquema de dados.
6. Defina os modelos econômicos iniciais.
7. Crie um plano técnico da Fase 1.
8. Estabeleça critérios de aceite verificáveis.
9. Identifique riscos de desempenho.
10. Prepare a implementação incremental.

Não comece pela etapa nacional.

Não crie sistemas fictícios complexos antes de validar a jogabilidade municipal.

Não use imagens de mapas como substitutas de um grafo viário navegável.

Não invente dados oficiais ausentes.

Não misture resultados operacionais com subsídios públicos.

Não implemente uma IA baseada em API externa como requisito para jogar.

O primeiro objetivo será entregar um protótipo municipal de Campinas com mapa real, linhas editáveis, ônibus, demanda, tarifas, custos e resultados financeiros.

Após validar esse protótipo, evoluir para a simulação municipal completa.

Somente depois implementar a progressão estadual e nacional.

**Visão final:** permitir que o jogador comece administrando algumas linhas de ônibus em uma cidade brasileira e termine comandando uma enorme rede nacional de transportes rodoviários, ferroviários e aéreos, enfrentando desafios financeiros, operacionais, sociais e políticos.

O jogo deverá demonstrar que administrar transportes públicos exige equilibrar eficiência econômica, qualidade do serviço e necessidades da população.