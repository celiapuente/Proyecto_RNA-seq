# CONTRASTE 4: DE_LamCiR_1wk_vs_attp2_5wk.csv
rm(list = ls())  # Limpiar el espacio de trabajo

# --- Cargar paquetes ----------
library(dplyr)
library(pheatmap)
library(ggplot2)

# --- Cargar datos -----
# Cargar archivos
figdir <- '/Users/celiamp/Documents/SEMESTRE 4/bioinfo/proyecto_eve/figures/'

# Cargar variable "dds", proveniente del script "DEG_analysis.R"
load("/Users/celiamp/Documents/SEMESTRE 4/bioinfo/proyecto_eve/dds.RData")

# Cargar variable "vsdata", proveniente del script "DEG_analysis.R"
load("/Users/celiamp/Documents/SEMESTRE 4/bioinfo/proyecto_eve/vsd.RData")

# Cargar resultados del contraste "LamCiR_1wk_vs_attp2_5wk"
# Asegúrate de tener el archivo correcto para este contraste
res_LamCiR_1wk_vs_5wk <- read.csv("/Users/celiamp/Documents/SEMESTRE 4/bioinfo/proyecto_eve/DE_LamCiR_1wk_vs_attp2_5wk.csv", header = TRUE)

# ---- Volcano Plot ----
df <- as.data.frame(res_LamCiR_1wk_vs_5wk)  # padj 0.05 y log2FoldChange de 2
df <- df %>%
  mutate(Expression = case_when(
    log2FoldChange >= 2 & padj < 0.05 ~ "Up-regulated",
    log2FoldChange <= -(2) & padj < 0.05 ~ "Down-regulated",
    TRUE ~ "Unchanged"
  ))

# Visualización Volcano Plot
png(file = paste0(figdir, "VolcanoPlot_LamCiR_1wk_vs_5wk.png"))
ggplot(df, aes(log2FoldChange, -log(padj, 10))) +
  geom_point(aes(color = Expression), size = 0.7) +
  labs(title = "LamCiR_1wk vs attp2_5wk") +
  xlab(expression("log"[2]*"FC")) +
  ylab(expression("-log"[10]*"p-adj")) +
  scale_color_manual(values = c("dodgerblue3", "gray50", "firebrick3")) +
  guides(colour = guide_legend(override.aes = list(size=1.5))) +
  geom_vline(xintercept = 2, linetype = "dashed", color = "black", alpha = 0.5) +
  geom_vline(xintercept = -(2), linetype = "dashed", color = "black", alpha = 0.5) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "black", alpha = 0.5)
dev.off()

# Contar genes upregulated y downregulated
num_upregulated <- sum(df$Expression == "Up-regulated", na.rm = TRUE)
num_downregulated <- sum(df$Expression == "Down-regulated", na.rm = TRUE)

# Imprimir resultados
cat("Número de genes upregulated:", num_upregulated, "\n")
cat("Número de genes downregulated:", num_downregulated, "\n")


# --- Heatmap (vsd) -----
topGenes <- head(order(res_LamCiR_1wk_vs_5wk$padj), 20)  # Obtener los 20 genes con p valor más significativo

# Visualización Heatmap con los top 20 genes
png(file = paste0(figdir, "Heatmap_vsd_topgenes_LamCiR_1wk_vs_5wk.png"))
pheatmap(vsd[topGenes, ], cluster_rows = FALSE, show_rownames = TRUE, cluster_cols = FALSE)
dev.off()

# --- Heatmap (log2 Fold Change) -----
# Obtener resultados del contraste directamente desde DESeq2
res <- results(dds, contrast = c("condition", "LamCiR_1wk", "attp2_5wk"))

# Seleccionar los genes más significativos
topGenes <- head(order(res$padj), 20)

# Extraer log2FoldChange para esos genes
mat <- as.matrix(res$log2FoldChange[topGenes])
rownames(mat) <- rownames(res)[topGenes]
colnames(mat) <- "condition_LamCiR_vs_attp2_5wk"

# Aplicar umbral visual
thr <- 3
mat[mat < -thr] <- -thr
mat[mat > thr] <- thr

# Visualización del heatmap
png(file = paste0(figdir, "Heatmap_log2FoldChange_topgenes_LamCiR_1wk_vs_5wk.png"))
pheatmap(mat,
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         color = colorRampPalette(c("blue", "white", "red"))(100))
dev.off()

