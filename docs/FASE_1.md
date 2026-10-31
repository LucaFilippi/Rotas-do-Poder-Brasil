# Fase 1 — protótipo municipal

Escopo autorizado: somente a Fase 1 do documento mestre. A Fase 2 exige novo pedido.

## Entrega e arquitetura

Godot 4.5.1 / GDScript, renderizador Compatibility. Primeiro recorte: centro de Campinas,
SP (IBGE 3509502). A seleção oferece Campinas; o catálogo nacional pertence à Fase 3.
O recorte não representa toda a cidade, nem usa demanda real de operadores.

- `scripts/geography.gd`: grafo dirigido, caminhos e distâncias em metros.
- `scripts/simulation.gd`: estado, frota, motoristas, linhas, demanda e fechamento diário.
- `scripts/save_store.gd`: SQLite local, transação, versões e validação antes de carregar.
- `scripts/map_view.gd`: desenho vetorial, seleção, zoom e arraste.
- `scripts/main.gd`: menu, seleção e painéis de gestão.
- `tools/import_osm.py`: preparação em Python 3.11; nenhum acesso à rede durante a partida.
- `tests/`: regressões headless sobre o mesmo motor usado pela interface.

Dados: JSON versionado com nós projetados em metros e arestas dirigidas, origem OSM,
atribuição ODbL, consulta, data de extração e hash do original. Preserva geometrias e
sentidos; exclui vias privadas/incompatíveis. Restrições de conversão por relações OSM
serão aplicadas conservadoramente bloqueando as vias de entrada da restrição neste
protótipo. Não existe conexão automática por cruzamento geométrico.
Pontos sugeridos são nós reais da rede, explicitamente estimados, sem alegar serem pontos oficiais.

## Modelo inicial

Valores financeiros fictícios em centavos inteiros, parâmetros em `data/balance.json`.
Uma jornada simplificada de 8 horas por ônibus/motorista; não há escalas avançadas.
Cada linha é um circuito: ida e volta roteadas separadamente, incluindo pontos intermediários.
Cada ponto gera viagens estimadas; a demanda é dividida entre linhas concorrentes antes
do limite de capacidade, evitando duplicação. Tarifa e tempo influenciam procura.
Sem motorista ou ônibus disponível não há serviço nem receita. Salários e administração
continuam sendo cobrados. Passageiros excedentes são registrados como não atendidos.

Receita = passageiros embarcados × tarifa. Custo operacional = combustível + manutenção
simples por km + salários + administração. Resultado operacional exclui aquisição de frota;
depreciação linear aparece separada no lucro contábil. Compra reduz caixa e aumenta ativo.
Fluxo de caixa diário = receita − desembolsos operacionais. Sem subsídios implícitos.
Execução determinística em passos de um dia, independente da velocidade visual.

Salvamento SQLite por slots, esquema versionado, transação atômica e snapshot completo
validado antes da substituição do estado. Autosave separado ao encerrar cada dia.

## Sequência de commits

1. Plano, fontes, importador e dados reais.
2. Motor econômico, roteamento e persistência.
3. Interface jogável e integração.
4. Regressões, validação e documentação final.

## Critérios de aceite

- Menu → selecionar Campinas → criar empresa → mapa real offline.
- Arrastar, ampliar, selecionar pontos e criar/editar/remover circuito viário válido.
- Comprar ônibus, contratar motorista, alocar frota e alterar tarifa.
- Avançar dias ou escolher pausa/1x/2x/5x/10x; indicadores e histórico refletem decisões.
- Conferir receita, custos, caixa, depreciação, satisfação e viagens não atendidas.
- Salvar/carregar vários slots; rejeitar versão futura/corrupção sem alterar a partida.
- Testes de sentidos, desconexão, alta/baixa tarifa, ausência de motoristas, superlotação,
  custos, compra/depreciação, concorrência, 365 dias e persistência interrompida.
- Importar e executar o projeto headless sem erros; conferir visualmente a interface.

## Riscos e limites

Amostra central pequena para validar a jogabilidade; demanda e pontos são estimativas.
O grafo é carregado uma vez e caminhos calculados apenas em edição; desenho agregado,
sem agentes individuais. Grandes mapas e o catálogo nacional ficam para a Fase 3.
Regras detalhadas de manutenção, escalas, política e cobradores ficam fora desta fase.

## Fontes verificadas

- https://www.openstreetmap.org/copyright — dados ODbL, atribuição visível no mapa.
- https://osmfoundation.org/wiki/Attribution_Guidelines
- https://www.ibge.gov.br/cidades-e-estados/sp/campinas — identidade do município.
- https://docs.godotengine.org/en/stable/classes/class_astar2d.html
- https://github.com/2shady4u/godot-sqlite — integração SQLite MIT, versão 4.6 fixada (compatível com Godot 4.5).
