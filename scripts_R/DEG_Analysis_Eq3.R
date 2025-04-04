######
# Script : Análisis de expresión diferencial en Drosophila
# Author: Sofia Salazar y Evelia Coss
# Date: 24/03/2025
# Description: Este script realiza el análisis de expresión diferencial
# a partir de los datos provenientes del alineamiento de STAR a R.
# Primero correr el script "import_txi_inR.R"
# Usage: Correr en un nodo de prueba en el cluster.
# Arguments:
#   - Input: Cargar la variable raw_counts.RData que contiene la matriz de cuentas y la metadata
#   - Output: DEG
#######

# qlogin
# module load r/4.0.2
# R

rm(list = ls())

# --- Load packages ----------
library(DESeq2)
library(ggplot2)
library(tidyverse)
library(cowplot)
library(reshape2)

# --- Load data -----
workdir <- '/Users/celiamp/Documents/SEMESTRE 4/bioinfo/proyecto_eve/'
load(file = paste0(workdir, 'raw_counts.RData'))
outdir <- workdir

metadata <- read.csv(file = paste0(workdir, 'metadata.csv'), header = T)

# Construcción del objeto DESeqDataSet
samples <- metadata$sample_id 
counts <- counts[rowSums(counts) > 10, ]  # Filtrar genes con más de 10 cuentas

counts[10593, ] <- 0  # Reemplaza todos los valores de la fila 10593 por 0

dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = metadata,
                              design = ~ condition)
dim(dds) 
dds <- DESeq(dds)
# Guardar dds
save(dds, file = paste0(outdir, "dds.RData"))


## ---- Normalización de los datos -----
counts <- assays(dds)$counts
vsd <- varianceStabilizingTransformation(counts)

head(vsd)

# Guardar vsd
save(vsd, file = paste0(outdir, "vsd.RData"))

# Remover batch effect
vsd_all <- vst(dds, blind=FALSE)
mat1 <- assay(vsd_all)
mm <- model.matrix(~condition, colData(vsd_all))
mat1 <- limma::removeBatchEffect(mat1, batch=vsd_all$condition, design=mm)
assay(vsd_all) <- mat1
plotPCA(vsd_all)
save(vsd_all, file = paste0(outdir, "vsd_all.RData"))


# ------ Análisis PCA -------
pc <- prcomp(t(mat1))

pca_df <- cbind(pc$x[,1:2], condition = metadata$condition) %>% as.data.frame()

pca_df$sample <- rownames(pca_df)

pca_df$Group <- as.factor(pca_df$condition)
levels(pca_df$Group)

variance_explained <- pc$sdev^2 / sum(pc$sdev^2) * 100

p <- ggplot(pca_df, aes(x = PC1, y = PC2, color = condition)) +
  stat_ellipse() +  
  geom_point( size = 2.5) +  
  scale_shape_manual(values=c(0, 16)) + 
  labs(x = sprintf('PC1 (%.2f%% varianza)', variance_explained[1]),
       y = sprintf('PC2 (%.2f%% varianza)', variance_explained[2]),
       color = "condition") +
  theme_minimal()
p

# Transformación a formato visualizable
melted_norm_counts <-data.frame(melt(assay(vsd_all)))
colnames(melted_norm_counts) <- c("gene", "sample_id", "normalized_counts")
melted_norm_counts <- left_join(melted_norm_counts, metadata, by = "sample_id")

# Cálculo de z-score
var_non_zero <- apply(counts, 1, var) !=0 
filtered_counts <- counts[var_non_zero, ]

zscores <- t(scale(t(filtered_counts)))
dim(zscores)

zscore_mat <- as.matrix(zscores)

save(zscore_mat, file = paste0(outdir, "zscore_mat.RData"))  


##  -- Generar contrastes -----

# 1. Comparación en wild-type flies (w1118)
# Crear una nueva variable basada en la edad
dds_w1118$age <- ifelse(grepl("_1wk", dds_w1118$condition), "1wk", "5wk")
# Convertir a factor y definir el nivel de referencia
dds_w1118$age <- factor(dds_w1118$age, levels = c("1wk", "5wk"))
# Redefinir el diseño del experimento
design(dds_w1118) <- ~ age
dim(dds_w1118)
# Correr DESeq2
dds_w1118 <- DESeq(dds_w1118)

# Obtener resultados del contraste "5wk vs 1wk"
res_w1118_age <- results(dds_w1118, contrast = c("age", "5wk", "1wk"))
save(metadata, dds_w1118, file = paste0(outdir, 'dds_objects/dds_w1118_design1.RData'))
write.csv(res_w1118_age, file = paste0(outdir, 'DE_w1118_1wk_vs_5wk.csv'))





# 2. Comparación en RNAi control background (attp2)

dds_attp2$age <- ifelse(grepl("_1wk", dds_attp2$condition), "1wk", "5wk")
# Convertir a factor y definir el nivel de referencia
dds_attp2$age <- factor(dds_attp2$age, levels = c("1wk", "5wk"))
# Redefinir el diseño del experimento
design(dds_attp2) <- ~ age
dim(dds_attp2)
# Correr DESeq2
dds_attp2 <- DESeq(dds_attp2)
# Obtener resultados del contraste "5wk vs 1wk"
res_attp2_age <- results(dds_attp2, contrast = c("age", "5wk", "1wk"))

# Guardar los resultados
save(metadata, dds_attp2, file = paste0(outdir, 'dds_objects/dds_attp2_design1.RData'))
write.csv(res_attp2_age, file = paste0(outdir, 'DE_attp2_1wk_vs_5wk.csv'))




# 3. LamC KD vs age-matched control (1wk: LamCiR vs attp2)
dds_lamc <- dds[, dds$condition %in% c("LamCiR_1wk", "attp2_1wk")]
dim(dds_lamc)

# Convertir 'condition' a un factor con los niveles especificados (asegurarse de que tenga todas las condiciones necesarias)
dds_lamc$condition <- factor(dds_lamc$condition, levels = c("attp2_1wk", "LamCiR_1wk"))

dds_lamc$condition <- relevel(dds_lamc$condition, ref = "attp2_1wk")
design(dds_lamc) <- ~ condition
dds_lamc <- DESeq(dds_lamc)

res_lamc_vs_ctrl <- results(dds_lamc, contrast = c("condition", "LamCiR_1wk", "attp2_1wk"))
save(metadata, dds_lamc, file = paste0(outdir, 'dds_objects/dds_lamc_design1.RData'))
write.csv(res_lamc_vs_ctrl, file = paste0(outdir, 'DE_LamCiR_vs_attp2_1wk.csv'))







# 4. LamCiR_1wk vs attp2_5wk
dds_comparison <- dds[, dds$condition %in% c("LamCiR_1wk", "attp2_5wk")]
dim(dds_comparison)

dds_comparison$condition <- factor(dds_comparison$condition, levels = c("attp2_5wk", "LamCiR_1wk"))
dds_comparison$condition <- relevel(dds_comparison$condition, ref = "attp2_5wk")
design(dds_comparison) <- ~ condition
dds_comparison <- DESeq(dds_comparison)

res_lamc_vs_attp_old <- results(dds_comparison, contrast = c("condition", "LamCiR_1wk", "attp2_5wk"))
save(metadata, dds_comparison, file = paste0(outdir, 'dds_objects/dds_comparison_design1.RData'))
write.csv(res_lamc_vs_attp_old, file = paste0(outdir, 'DE_LamCiR_1wk_vs_attp2_5wk.csv'))


dev.off()
