# 4. Defina as cores para cada grupo. O número de cores deve ser igual ao número de grupos.
# Exemplo: cores_grupos <- c("Controle" = "#0072B2", "TratamentoA" = "#D55E00", "TratamentoB" = "#009E73")
cores_grupos <- NULL # Deixe como NULL para usar as cores padrão do ggplot2


# --- 1. INSTALAÇÃO E CARREGAMENTO DAS BIBLIOTECAS ---
# Esta função verifica se um pacote está instalado, instala se necessário, e o carrega.
instalar_e_carregar_pacotes <- function(pacotes) {
  for (pacote in pacotes) {
    if (!require(pacote, character.only = TRUE)) {
      # Verifica se o pacote está disponível no CRAN
      if (pacote %in% available.packages()[, "Package"]) {
        install.packages(pacote, dependencies = TRUE)
      } else {
        stop(paste("Erro: O pacote '", pacote, "' não foi encontrado no CRAN. Verifique o nome do pacote."))
      }
      library(pacote, character.only = TRUE)
    }
  }
}

pacotes_necessarios <- c("readxl", "ggplot2", "tidyr", "tibble", "dplyr", "tools", "ggrepel", "writexl")
instalar_e_carregar_pacotes(pacotes_necessarios)


# --- 2. CARREGAMENTO E PREPARAÇÃO DOS DADOS ---
cat("Iniciando o script de PCA...\n")
cat("Passo 1: Carregando e preparando os dados.\n")

# Carregar os dados com base na extensão do arquivo
extensao_arquivo <- tools::file_ext(caminho_do_arquivo)
if (extensao_arquivo == "xlsx") {
  dados_completos <- read_excel(caminho_do_arquivo)
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
dados_completos[[nome_coluna_grupo]] <- as.factor(dados_completos[[nome_coluna_grupo]])
grupos <- dados_completos[[nome_coluna_grupo]]

# Identificar automaticamente as colunas numéricas para a PCA
colunas_numericas_nomes <- dados_completos %>%
  select(where(is.numeric)) %>%
  names()

# Remover a coluna de grupo da lista de colunas numéricas, caso ela seja numérica
colunas_numericas_nomes <- setdiff(colunas_numericas_nomes, nome_coluna_grupo)
dados_numericos <- dados_completos[, colunas_numericas_nomes]

cat("  - Colunas numéricas identificadas para a PCA:", paste(colunas_numericas_nomes, collapse = ", "), "\n")
cat("  - Coluna de grupo identificada:", nome_coluna_grupo, "\n")


# Tratamento de valores ausentes (NA) com a média da coluna.
cat("  - Verificando e tratando valores ausentes (NA)...\n")
for(col in colunas_numericas_nomes) {
  if(any(is.na(dados_numericos[[col]]))) {
    media_coluna <- mean(dados_numericos[[col]], na.rm = TRUE)
    n_ausentes <- sum(is.na(dados_numericos[[col]]))
    dados_numericos[[col]][is.na(dados_numericos[[col]])] <- media_coluna
    cat("    - Na coluna '", col, "', ", n_ausentes, " valores ausentes foram substituídos pela média (", round(media_coluna, 2), ").\n")
  }
}


# Remover linhas com valores ausentes que possam ter restado e filtrar grupos
indices_completos <- complete.cases(dados_numericos)
dados_limpos <- dados_numericos[indices_completos, ]
grupos_limpos <- grupos[indices_completos]

cat("  -", sum(!indices_completos), "linhas com dados ausentes restantes foram removidas.\n")

# Padronizar os dados (Z-score)
dados_padronizados <- scale(dados_limpos)


# --- 3. EXECUÇÃO DA ANÁLISE DE COMPONENTES PRINCIPAIS (PCA) ---
cat("\nPasso 2: Executando a PCA.\n")

pca_result <- prcomp(dados_padronizados, center = TRUE, scale. = TRUE)

cat("  - Resumo da importância dos componentes:\n")
print(summary(pca_result))


# --- 4. PREPARAÇÃO DOS DADOS PARA VISUALIZAÇÃO ---
cat("\nPasso 3: Preparando dados para visualização.\n")

scores_df <- as.data.frame(pca_result$x)
scores_df$Grupo <- grupos_limpos

loadings_df <- as.data.frame(pca_result$rotation) %>%
  rownames_to_column(var = "Variavel")


# --- 5. VISUALIZAÇÃO E SALVAMENTO DOS RESULTADOS ---
cat("\nPasso 4: Gerando e salvando os gráficos.\n")

# Criar a pasta de resultados se ela não existir
caminho_output <- file.path(dirname(caminho_do_arquivo), pasta_output)
if (!dir.exists(caminho_output)) {
  dir.create(caminho_output)
  cat("  - Pasta de resultados '", pasta_output, "' criada com sucesso.\n")
}

# Definir um tema consistente para os gráficos
tema_graficos <- theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    legend.position = "bottom"
  )

# --- 5.1. GRÁFICO DE SCORES (PC1 vs PC2) ---
var_pc1 <- round(summary(pca_result)$importance[2, 1] * 100, 2)
var_pc2 <- round(summary(pca_result)$importance[2, 2] * 100, 2)

pca_plot_scores <- ggplot(scores_df, aes(x = PC1, y = PC2, color = Grupo)) +
  geom_point(size = 3.5, alpha = 0.8) +
  stat_ellipse(level = 0.95, linetype = "dashed", size = 1) +
  labs(
    title = "Scores da PCA",
    x = paste0("PC1 (", var_pc1, "%)"),
    y = paste0("PC2 (", var_pc2, "%)"),
    color = "Grupo"
  ) +
  tema_graficos

if (!is.null(cores_grupos)) {
  pca_plot_scores <- pca_plot_scores + scale_color_manual(values = cores_grupos)
}

print(pca_plot_scores)

ggsave(
  filename = "grafico_pca_scores.png",
  plot = pca_plot_scores,
  path = caminho_output,
  width = 10, height = 8, dpi = 300, units = "in"
)
cat("  - Gráfico de Scores gerado e salvo em '", caminho_output, "'.\n")

# --- 5.2. GRÁFICO DE LOADINGS ---
loadings_long_df <- loadings_df %>%
  pivot_longer(cols = c("PC1", "PC2"),
               names_to = "Componente",
               values_to = "Influencia")

loadings_plot_barras <- ggplot(loadings_long_df, aes(x = reorder(Variavel, Influencia), y = Influencia, fill = Componente)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  facet_wrap(~Componente, scales = "free_x") +
  coord_flip() +
  labs(
    title = "Loadings do PC1 e PC2",
    x = NULL,
    y = "Valor do Loading (Influência)"
  ) +
  scale_fill_manual(values = c("PC1" = "#1f77b4", "PC2" = "#ff7f0e")) +
  tema_graficos +
  theme(legend.position = "none")

print(loadings_plot_barras)

ggsave(
  filename = "grafico_pca_loadings.png",
  plot = loadings_plot_barras,
  path = caminho_output,
  width = 12, height = 10, dpi = 300, units = "in"
)
cat("  - Gráfico de Loadings gerado e salvo.\n")

# --- 5.3. BIPLOT (SCORES + LOADINGS) ---
mult <- max(
  abs(scores_df[, "PC1"]) / max(abs(loadings_df[, "PC1"])),
  abs(scores_df[, "PC2"]) / max(abs(loadings_df[, "PC2"]))
) * 0.7

biplot <- ggplot(scores_df, aes(x = PC1, y = PC2, color = Grupo)) +
  geom_point(size = 3.5, alpha = 0.6) +
  stat_ellipse(level = 0.95, linetype = "dashed", size = 1) +
  geom_segment(data = loadings_df,
               aes(x = 0, y = 0, xend = PC1 * mult, yend = PC2 * mult),
               arrow = arrow(length = unit(0.2, "cm")),
               color = "gray30", inherit.aes = FALSE) +
  ggrepel::geom_text_repel(data = loadings_df,
            aes(x = PC1 * mult, y = PC2 * mult, label = Variavel),
            color = "black", size = 4, inherit.aes = FALSE,
            box.padding = 0.5, max.overlaps = Inf) +
  labs(
    title = "Biplot",
    x = paste0("PC1 (", var_pc1, "%)"),
    y = paste0("PC2 (", var_pc2, "%)"),
    color = "Grupo"
  ) +
  tema_graficos

if (!is.null(cores_grupos)) {
  biplot <- biplot + scale_color_manual(values = cores_grupos)
}

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
