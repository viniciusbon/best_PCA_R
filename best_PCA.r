# ===================================================================
# SCRIPT PARA ANÁLISE DE COMPONENTES PRINCIPAIS (PCA)
#
# DESCRIÇÃO: Este script carrega um conjunto de dados, trata valores
# ausentes, realiza uma PCA, gera e salva visualizações e relatórios.
# Se gostou e lhe foi funcional, me siga no linkedin:
#[www.linkedin.com/in/vinicius-mantovam]
# AUTOR: [Vinicius Mantovam]
# DATA: 2025-08-08 
# ===================================================================


# --- 0. CONFIGURAÇÃO DO USUÁRIO ---
# Altere AS QUATRO VARIÁVEIS abaixo para corresponder aos seus dados.

# 1. Defina o caminho completo para o seu arquivo de dados (Excel ou CSV).
caminho_do_arquivo <- "SEU/CAMINHO/PARA/O/ARQUIVO.xlsx"

# 2. Escreva o nome exato da coluna que identifica os diferentes grupos do seu estudo.
[cite_start]nome_coluna_grupo <- "Grupo" 

# 3. Fator de escala para os vetores no biplot (opcional).
escala_biplot <- 5

# 4. Nome da pasta onde os gráficos e tabelas serão salvos.
pasta_output <- "Resultados_PCA"


# --- 1. INSTALAÇÃO E CARREGAMENTO DAS BIBLIOTECAS ---
# ## ALTERAÇÃO ##: Adicionado 'ggrepel' e 'writexl'.
[cite_start]pacotes_necessarios <- c("readxl", "ggplot2", "tidyr", "tibble", "dplyr", "tools", "ggrepel", "writexl") # [cite: 2, 3, 4, 5]

for (pacote in pacotes_necessarios) {
  if (!require(pacote, character.only = TRUE)) {
    install.packages(pacote, dependencies = TRUE)
    library(pacote, character.only = TRUE)
  }
}


# --- 2. CARREGAMENTO E PREPARAÇÃO DOS DADOS ---
cat("Iniciando o script de PCA...\n")
cat("Passo 1: Carregando e preparando os dados.\n")

# Carregar os dados com base na extensão do arquivo
extensao_arquivo <- tools::file_ext(caminho_do_arquivo)
if (extensao_arquivo == "xlsx") {
  [cite_start]dados_completos <- read_excel(caminho_do_arquivo) 
} else if (extensao_arquivo == "csv") {
  dados_completos <- read.csv(caminho_do_arquivo)
} else {
  stop("Erro: Formato de arquivo não suportado. Use .xlsx ou .csv.")
}

# Verificar se a coluna de grupo especificada existe no dataframe
if (!nome_coluna_grupo %in% names(dados_completos)) {
  stop(paste("Erro: A coluna '", nome_coluna_grupo, "' não foi encontrada no seu arquivo. Verifique o nome da coluna na seção de configuração."))
}

# Guardar a coluna de grupos em uma variável separada.
[cite_start]grupos <- dados_completos[[nome_coluna_grupo]] 

# Identificar automaticamente as colunas numéricas para a PCA
colunas_numericas_nomes <- dados_completos %>%
  select(where(is.numeric)) %>%
  names()

# Remover a coluna de grupo da lista de colunas numéricas, caso ela seja numérica
colunas_numericas_nomes <- setdiff(colunas_numericas_nomes, nome_coluna_grupo)
[cite_start]dados_numericos <- dados_completos[, colunas_numericas_nomes] 

cat("  - Colunas numéricas identificadas para a PCA:", paste(colunas_numericas_nomes, collapse = ", "), "\n")
cat("  - Coluna de grupo identificada:", nome_coluna_grupo, "\n")


# ## ALTERAÇÃO ##: Tratamento de valores ausentes (NA) com a média da coluna.
cat("  - Verificando e tratando valores ausentes (NA)...\n")
for(col in colunas_numericas_nomes) {
  if(any(is.na(dados_numericos[[col]]))) {
    # Calcular a média da coluna, ignorando os NAs existentes
    media_coluna <- mean(dados_numericos[[col]], na.rm = TRUE)
    
    # Contar quantos NAs existem antes de substituir
    n_ausentes <- sum(is.na(dados_numericos[[col]]))
    
    # Substituir NAs pela média
    dados_numericos[[col]][is.na(dados_numericos[[col]])] <- media_coluna
    
    cat("    - Na coluna '", col, "', ", n_ausentes, " valores ausentes foram substituídos pela média (", round(media_coluna, 2), ").\n")
  }
}


# Remover linhas com valores ausentes que possam ter restado (ex: em colunas não-numéricas)
# E filtrar o vetor 'grupos' para manter a correspondência.
[cite_start]indices_completos <- complete.cases(dados_numericos) 
[cite_start]dados_limpos <- dados_numericos[indices_completos, ] 
[cite_start]grupos_limpos <- grupos[indices_completos] 

cat("  -", sum(!indices_completos), "linhas com dados ausentes restantes foram removidas.\n")

# Padronizar os dados (Z-score) para que todas as variáveis tenham a mesma escala.
[cite_start]dados_padronizados <- scale(dados_limpos) 


# --- 3. EXECUÇÃO DA ANÁLISE DE COMPONENTES PRINCIPAIS (PCA) ---
cat("\nPasso 2: Executando a PCA.\n")

[cite_start]pca_result <- prcomp(dados_padronizados, center = TRUE, scale. = TRUE) 
cat("  - Resumo da importância dos componentes:\n")
[cite_start]print(summary(pca_result)) # 

# --- 4. PREPARAÇÃO DOS DADOS PARA VISUALIZAÇÃO ---
cat("\nPasso 3: Preparando dados para visualização.\n")

[cite_start]scores_df <- as.data.frame(pca_result$x) 
[cite_start]scores_df$Grupo <- grupos_limpos 

[cite_start]loadings_df <- as.data.frame(pca_result$rotation) %>% 
  [cite_start]rownames_to_column(var = "Variavel") 


# --- 5. VISUALIZAÇÃO E SALVAMENTO DOS RESULTADOS ---
cat("\nPasso 4: Gerando e salvando os gráficos.\n")

# Criar a pasta de resultados se ela não existir
caminho_output <- file.path(dirname(caminho_do_arquivo), pasta_output)
if (!dir.exists(caminho_output)) {
  dir.create(caminho_output)
  cat("  - Pasta de resultados '", pasta_output, "' criada com sucesso.\n")
}

# --- 5.1. GRÁFICO DE SCORES (PC1 vs PC2) ---
var_pc1 <- round(summary(pca_result)$importance[2, 1] * 100, 2)
var_pc2 <- round(summary(pca_result)$importance[2, 2] * 100, 2)

[cite_start]pca_plot_scores <- ggplot(scores_df, aes(x = PC1, y = PC2, color = Grupo)) + 
  [cite_start]stat_ellipse(level = 0.95, linetype = "dashed", size = 1) + 
  [cite_start]theme_minimal(base_size = 14) + 
    [cite_start]title = "Gráfico de Scores da PCA", 
    subtitle = "Distribuição das amostras e agrupamentos",
    [cite_start]x = paste0("PC1 (", var_pc1, "%)"), 
    [cite_start]y = paste0("PC2 (", var_pc2, "%)"), 
    color = "Grupo"
  ) +
  theme(legend.position = "bottom")

[cite_start]print(pca_plot_scores) 

ggsave(
  filename = "grafico_pca_scores.png",
  plot = pca_plot_scores,
  path = caminho_output,
  width = 10, height = 8, dpi = 300, units = "in"
)
cat("  - Gráfico de Scores gerado e salvo em '", caminho_output, "'.\n")

# --- 5.2. GRÁFICO DE LOADINGS ---
loadings_long_df <- loadings_df %>%
  [cite_start]pivot_longer(cols = c("PC1", "PC2"), 
               [cite_start]names_to = "Componente", 
               [cite_start]values_to = "Influencia") 

[cite_start]loadings_plot_barras <- ggplot(loadings_long_df, aes(x = reorder(Variavel, Influencia), y = Influencia, fill = Componente)) + # [cite: 57]
  [cite_start]geom_bar(stat = "identity", alpha = 0.8) + # [cite: 58]
  facet_wrap(~Componente, scales = "free_x") +
  coord_flip() +
  labs(
    [cite_start]title = "Influência das Variáveis (Loadings) em PC1 e PC2", 
    [cite_start]x = "Variáveis", # [cite: 62]
    [cite_start]y = "Valor do Loading (Influência)" 
  ) +
  [cite_start]scale_fill_manual(values = c("PC1" = "#1f77b4", "PC2" = "#ff7f0e")) + 
  [cite_start]theme_minimal(base_size = 14) +
  theme(legend.position = "none")

[cite_start]print(loadings_plot_barras) 

ggsave(
  filename = "grafico_pca_loadings.png",
  plot = loadings_plot_barras,
  path = caminho_output,
  width = 12, height = 10, dpi = 300, units = "in"
)
cat("  - Gráfico de Loadings gerado e salvo.\n")

# --- 5.3. BIPLOT (SCORES + LOADINGS) ---
# ## ALTERAÇÃO ##: Usando ggrepel::geom_text_repel para evitar sobreposição de rótulos.
[cite_start]biplot <- ggplot(scores_df, aes(x = PC1, y = PC2, color = Grupo)) + 
  [cite_start]geom_point(size = 3, alpha = 0.6) + 
  [cite_start]stat_ellipse(level = 0.95, linetype = "dashed", size = 1) + 
  geom_segment(data = loadings_df,
               [cite_start]aes(x = 0, y = 0, xend = PC1 * escala_biplot, yend = PC2 * escala_biplot), 
               [cite_start]arrow = arrow(length = unit(0.2, "cm")), 
               color = "gray30", inherit.aes = FALSE) +
  ggrepel::geom_text_repel(data = loadings_df,
            [cite_start]aes(x = PC1 * escala_biplot, y = PC2 * escala_biplot, label = Variavel), 
            color = "black", size = 3.5, inherit.aes = FALSE,
            box.padding = 0.5, max.overlaps = Inf) +
  [cite_start]theme_minimal(base_size = 14) + 
  labs(
    [cite_start]title = "Biplot da PCA",
    subtitle = "Scores das amostras com vetores de influência das variáveis (sem sobreposição)",
    x = paste0("PC1 (", var_pc1, "%)"),
    y = paste0("PC2 (", var_pc2, "%)"),
    color = "Grupo"
  ) +
  theme(legend.position = "bottom")

print(biplot)

ggsave(
  filename = "grafico_pca_biplot.png",
  plot = biplot,
  path = caminho_output,
  width = 11, height = 9, dpi = 300, units = "in"
)
cat("  - Biplot gerado e salvo.\n")


# --- 6. OUTPUT DETALHADO DA INFLUÊNCIA DAS VARIÁVEIS (LOADINGS) ---
cat("\nPasso 5: Gerando output detalhado da influência das variáveis.\n")

tabela_influencia <- as_tibble(pca_result$rotation, rownames = "Variavel")

tabela_influencia <- tabela_influencia %>%
  mutate(
    Contribuicao_PC1 = PC1^2,
    Contribuicao_PC2 = PC2^2
  )

tabela_influencia_ordenada <- tabela_influencia %>%
  arrange(desc(Contribuicao_PC1)) %>%
  mutate(across(where(is.numeric), ~ round(.x, 4))) %>%
  select(Variavel, PC1, Contribuicao_PC1, PC2, Contribuicao_PC2, everything())

cat("  - Tabela de Influência e Contribuição das Variáveis (ordenada por PC1):\n")
print(tabela_influencia_ordenada, n = nrow(tabela_influencia_ordenada))

# Salvando a tabela em arquivos CSV e Excel
caminho_csv <- file.path(caminho_output, "resultados_influencia_variaveis.csv")
write.csv(tabela_influencia_ordenada, caminho_csv, row.names = FALSE)
cat("  - Tabela de resultados salva como CSV em '", caminho_csv, "'.\n")

caminho_excel <- file.path(caminho_output, "resultados_influencia_variaveis.xlsx")
writexl::write_xlsx(tabela_influencia_ordenada, caminho_excel)
cat("  - Tabela de resultados salva como Excel em '", caminho_excel, "'.\n")


cat("\nAnálise finalizada! Outputs de dados e gráficos foram salvos na pasta '", pasta_output, "'.\n")