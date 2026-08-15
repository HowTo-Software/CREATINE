# Auditoria tecnica - CREATINE! 1.1.0

## Escopo

Revisao do mod principal `CREATINE` e do modulo opcional `CREATINE_JunkiezCompatibility` para Project Zomboid 42.20.2, usando a Umbrella 42.20 e a descompilacao local da engine.

## Falhas encontradas

### Receita registrada no modulo errado

`CreatineSmoothie` era declarada em `module Base`, mas os ingredientes procuravam `CREATINE.CreatineSmoothie`. Na 42.20.2, `ScriptManager.getEvolvedRecipe()` resolve o nome completo do modulo. Essa divergencia podia deixar o menu visivel sem uma receita valida para os ingredientes.

Correcao: a receita agora pertence ao modulo `CREATINE`, e as referencias usam seu nome completo `CREATINE.CreatineSmoothie`. Isso e necessario porque a busca sem modulo feita por `ScriptManager` usa `Base` como padrao.

### Itens vanilla eram redefinidos

`grocerylist.txt` reabria 92 itens de `module Base` somente para adicionar `EvolvedRecipe`. O carregador da 42.20.2 aplica a flag `ResetExisting` a scripts do tipo `item`; portanto, um segundo bloco para o mesmo item reseta sua definicao anterior antes de carregar o novo corpo.

Correcao: o arquivo foi removido. Os ingredientes agora sao registrados em `EvolvedRecipe.itemsList` com `ItemRecipe.new()`, APIs expostas pela Umbrella, sem modificar os scripts dos alimentos.

### Compatibilidade sobrescrevia itens Junkiez

`JunkiezSupport.txt` repetia as definicoes de quatro suplementos externos. Isso podia apagar propriedades que pertenciam ao mod Junkiez.

Correcao: a integracao foi movida para Lua compartilhado e altera somente as listas das receitas encontradas.

### Depurador executava em producao

`ContextDebug.lua` interceptava toda abertura de menu de inventario, percorria selecoes e imprimia repetidamente opcoes e receitas. Mesmo protegido por `pcall`, ele adicionava trabalho e muito ruido ao console.

Correcao: o arquivo temporario foi removido do carregamento do mod.

### Distribuicoes podiam duplicar entradas

A injecao de loot ocorria imediatamente no carregamento do arquivo e nao verificava repeticao.

Correcao: o registro agora usa `Events.OnPreDistributionMerge` e impede pares duplicados de item/peso.

### Varredura global de zumbis

Bulldoze percorria `getCell():getZombieList()` a cada atualizacao de cada jogador correndo com o trait.

Correcao: a busca foi limitada aos quadrados proximos e a dez verificacoes por segundo por jogador elegivel.

### Outros ajustes

- A avaliacao de marcos passou de cada minuto do jogo para cada dez minutos; uma dose ainda forca avaliacao imediata.
- O nome global generico `MilestoneSystem` foi substituido por `CREATINE_MilestoneSystem` para reduzir conflitos entre mods.
- A garrafa vazia agora usa o parametro vanilla `ReplaceOnUse`, evitando criacao manual e possivel duplicacao em MP.
- A descricao de Segundo Folego foi alinhada ao cooldown real de sete dias.
- Foram adicionadas traducoes EN e PTBR para receita, contexto, itens e traits.
- Os dois modulos agora declaram `versionMin=42.20.2` e `modversion=1.1.0`.

## Validacao realizada

- Sintaxe de todos os arquivos Lua com `luac -p`.
- Parse de todos os JSONs de traducao.
- Conferencia das APIs `ScriptManager.getEvolvedRecipe`, `EvolvedRecipe.getItemsList`, `ItemRecipe.new`, `IsoGridSquare.getMovingObjects`, `getTimestampMs`, `Events.OnGameBoot` e `Events.OnPreDistributionMerge` na Umbrella 42.20.
- Confirmacao, na descompilacao, de `ResetExisting` para scripts `item` e do fluxo de resolucao de `EvolvedRecipe`.

## Teste recomendado no jogo

1. Ativar somente `CREATINE` em um save novo.
2. Gerar `CREATINE.Creatine`, `Base.Sportsbottle` e dois alimentos vanilla pelo modo Debug.
3. Colocar pelo menos 0,5 L de agua na garrafa e confirmar o menu de Vitamina de Creatina.
4. Preparar e consumir a vitamina; confirmar a devolucao de uma garrafa vazia.
5. Avancar sete dias consumindo uma dose por dia e validar os marcos.
6. Repetir em Host ou dedicado e conferir que nao existem erros de callback ou receita.
7. Ativar o modulo Junkiez apenas junto das duas dependencias e testar as receitas cruzadas.
