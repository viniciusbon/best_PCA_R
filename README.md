# best_PCA_R
The following repository contains an R script to perform professional Principal Component Analysis in RStudio. The code is practical, tested, and includes the PCA analysis, related scores, and beautiful figures for your article. O repositório a seguir contém um script em R para realizar uma Análise de Componentes Principais profissional no RStudio.

Análise de Componentes Principais (PCA) em R 
Este repositório contém um script em R (analise_pca.R) projetado para automatizar e simplificar a Análise de Componentes Principais (PCA). O objetivo é fornecer uma ferramenta robusta e de fácil configuração para pesquisadores e analistas de dados que desejam explorar a estrutura de seus dados, reduzir a dimensionalidade e visualizar os resultados de forma clara e informativa.

Importante: Tem a versão com legenda das figuras em inglês e em portugues.
Importantly: it includes versions with figure captions in both English and Portuguese.

📜 Descrição
A PCA é uma técnica estatística poderosa usada para simplificar a complexidade em dados com muitas variáveis. Este script guia o usuário através de todo o processo: desde o carregamento dos dados, passando pelo tratamento de valores ausentes (imputação pela média), até a execução da PCA e a geração de saídas essenciais para a interpretação dos resultados, como gráficos e tabelas detalhadas.

✨ Funcionalidades
Carregamento Flexível de Dados: Suporta arquivos de dados nos formatos .xlsx (Excel) e .csv.

Configuração Intuitiva: A configuração é feita em uma seção dedicada no topo do script, onde o usuário define o caminho do arquivo, a coluna de grupo e outros parâmetros.

Processamento Automatizado:

Tratamento de Dados Ausentes: Imputa (substitui) valores ausentes (NA) em colunas numéricas pela média da respectiva coluna, preservando o máximo de dados possível.

Detecção de Variáveis: Identifica automaticamente as colunas numéricas para incluir na análise.

Padronização de Dados: Realiza a padronização (Z-score), um passo crucial para uma PCA correta.

Visualização Avançada: Gera e salva automaticamente três gráficos essenciais em alta resolução (300 dpi):

Gráfico de Scores: Mostra a distribuição das amostras, com elipses de confiança de 95% para cada grupo.

Gráfico de Loadings: Exibe a influência de cada variável na construção dos componentes principais.

Biplot Inteligente: Sobrepõe os scores e os loadings, utilizando o pacote ggrepel para garantir que os nomes das variáveis sejam dispostos de forma clara e sem sobreposição.

Relatório Detalhado: Produz uma tabela formatada com os loadings e a contribuição de cada variável para os componentes, salvando-a em formatos .csv e .xlsx para fácil acesso e utilização em outros softwares.

⚙️ Requisitos
R: Versão 4.0 ou superior.

RStudio (Recomendado): Um ambiente de desenvolvimento integrado para R que facilita a execução do script.

Pacotes R: O script foi desenvolvido para verificar e instalar automaticamente os seguintes pacotes, caso eles não estejam presentes no seu ambiente:

readxl, ggplot2, tidyr, tibble, dplyr, tools, writexl e ggrepel.

🚀 Como Usar
Faça o download do arquivo analise_pca.R.

Abra o script no RStudio ou em um editor de texto.

Configure suas variáveis na seção # --- 0. CONFIGURAÇÃO DO USUÁRIO --- no início do arquivo:

R

# 1. Defina o caminho completo para o seu arquivo de dados.
caminho_do_arquivo <- "C:/Users/SeuUsuario/Desktop/meus_dados.xlsx"

# 2. Escreva o nome exato da coluna que identifica os grupos.
nome_coluna_grupo <- "Grupo"

# 3. Fator de escala para os vetores no biplot (ajuste visual).
escala_biplot <- 5

# 4. Nome da pasta onde os gráficos e tabelas serão salvos.
pasta_output <- "Resultados_PCA"
Execute o script. No RStudio, você pode fazer isso clicando no botão "Source" no canto superior direito do editor de código, ou digitando source("analise_pca.R") no console.

📊 Outputs Gerados
Após a execução, o script criará uma nova pasta com o nome que você definiu em pasta_output (o padrão é Resultados_PCA). Dentro desta pasta, você encontrará os seguintes arquivos:

Gráficos (.png)
grafico_pca_scores.png: Ideal para observar se as amostras do mesmo grupo se agrupam e se os diferentes grupos se separam no espaço da PCA.

grafico_pca_loadings.png: Essencial para entender quais variáveis são as mais importantes na definição dos eixos PC1 e PC2.

grafico_pca_biplot.png: Permite a análise conjunta de como as amostras (pontos) se relacionam com as variáveis (vetores). Os rótulos das variáveis são ajustados para evitar sobreposição, garantindo a legibilidade.

Relatório de Dados (.csv e .xlsx)
resultados_influencia_variaveis.xlsx (e .csv): Uma tabela detalhada, pronta para ser usada em relatórios e artigos, que mostra a influência e a contribuição de cada variável para os componentes principais. Exemplo:

Variavel	PC1	Contribuicao_PC1	PC2	Contribuicao_PC2
Glicose	0.4512	0.2036	-0.1021	0.0104
Colesterol	0.4390	0.1927	0.2188	0.0479
Peso	0.3811	0.1452	0.4987	0.2487
Altura	-0.3755	0.1410	-0.4501	0.2026

Exportar para as Planilhas
👤 [Vinicius Mantovam]

Data da última versão: 2025-08-08
