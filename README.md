# Proyecto RNA-seq

## 👥 Integrantes del equipo
- Celia Maria Puente Solis  
- Samantha Melissa Pacheco Gomez  
- Miriam Alejandra Jimenez Marmolejo  

📅 **Fecha:** 04 de abril de 2025  
📚 **Materia:** Bioinformática Avanzada  
🎓 **Semestre cursado:** 4to semestre  

---

## Resumen del trabajo

Este análisis evalúa los efectos del envejecimiento sobre la expresión génica en cardiomiocitos de *Drosophila melanogaster* con énfasis en el papel de LamC. Se compararon muestras de RNA-seq de moscas jóvenes (1 semana) y envejecidas (5 semanas) en dos condiciones de control (w1118 y attp2), así como en una línea con knockdown específico de LamC mediante RNAi (LamCiR). Los datos fueron generados con la plataforma Illumina NovaSeq 6000 (paired-end, \~34 millones de lecturas por muestra).

Se utilizaron herramientas bioinformáticas en R incluyendo DESeq2 para la detección de genes diferencialmente expresados (DEGs), gprofiler2 para el análisis de enriquecimiento funcional (términos GO), y ggplot2 para la visualización de resultados. Los criterios de selección de DEGs incluyeron un adjusted p-value \< 0.05 y log2 fold change significativo.

Los resultados revelan una disminución progresiva de LamC con la edad, acompañada por una desregulación de factores de transcripción cardiacos clave (como Hand, tin y H15) y genes del citoesqueleto. Estos cambios se asocian con pérdida de accesibilidad cromatínica y disfunción cardíaca, sugiriendo que la remodelación nuclear inducida por la edad desempeña un rol central en la resistencia cardíaca y otros perfiles de envejecimiento.

---

### 📁 Organización general

Los scripts se encuentran en el directorio:
/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts




Están organizados por etapas del análisis:

---

### 1️⃣ Descarga de los datos crudos

Los datos fueron descargados de ENA usando los BioSample IDs.

**Control8 (w1118):**
- GSM5627955 → SAMN22321270  
- GSM5627956 → SAMN22321271  
- GSM5627957 → SAMN22321272  
- GSM5627959 → SAMN22321274  
- GSM5627960 → SAMN22321275  
- GSM5627961 → SAMN22321281  

**attp2:**
- GSM5627963 → SAMN22321283  
- GSM5627964 → SAMN22321284  
- GSM5627965 → SAMN22321276  
- GSM5627968 → SAMN22321279  
- GSM5627969 → SAMN22321280  
- GSM5627970 → SAMN22321285  

**LamCiR:**
- GSM5627973 → SAMN22321288  
- GSM5627974 → SAMN22321289  
- GSM5627975 → SAMN22321290  

**Script utilizado:**
/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/download_all_rawData.sge


---

### 2️⃣ Evaluación de calidad de los datos crudos (FastQC + MultiQC)

Se ejecutó el script:
/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/qc1.sge

Este realiza el análisis de calidad con **FastQC** y genera un resumen con **MultiQC**.

---

### 3️⃣ Trimming

Se realizó el recorte de adaptadores y bases de baja calidad con **Trimmomatic**.

#### Paso 1: Descarga de adaptadores

```bash
cd /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025
wget https://raw.githubusercontent.com/timflutre/trimmomatic/master/adapters/TruSeq3-PE-2.fa
```

#### Paso 2: Ejecución del trimming
Se ejecutó el script: /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/trim_1.sge

Los archivos resultantes se almacenaron en: /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/TRIM_results/

#### Paso 3: Evaluación de calidad de los datos post-trimming
Se repitió FastQC y MultiQC con el script:/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/qc2.sge

###  4️⃣ Descarga del genoma de referencia

Se descargaron archivos desde UCSC:
```bash
wget https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/dm6.fa.gz
wget https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/genes/dm6.refGene.gtf.gz
gunzip dm6.fa.gz
gunzip dm6.refGene.gtf.gz
```
Archivos almacenados en:
/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/reference/

### 5️⃣ Creación del índice STAR

Se generó el índice del genoma con el script:
/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/STAR_index.sge

Este script genera un índice del genoma de referencia usando STAR a partir de la secuencia fasta (dm6.fa) y el archivo de anotación GTF, para preparar el genoma y así permitir el alineamiento eficiente de lecturas en análisis posteriores.

### 6️⃣ Alineamiento y conteo de lecturas con STAR

Se utilizó el script:
/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/ali_STAR.sge

Este script realiza alineamiento de lecturas *paired-end* previamente recortadas contra un genoma de referencia indexado utilizando STAR, generando archivos BAM ordenados y conteos por gen para cada muestra.

### 7️⃣ Importación a R y creación de metadatos

Los resultados fueron importados a R utilizando el script: [load_data_inR_Eq3.R](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/scripts_R/load_data_inR_Eq3.R)
Posteriormente se generó la metadata necesaria para el análisis diferencial posterior, que se encuentra en: [metadata](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/metadata.csv)

### 8️⃣ Análisis de Expresión Diferencial (DEG)

Se utilizó el script: [DEG_Analysis_Eq3.R](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/scripts_R/DEG_Analysis_Eq3.R)
Este script realiza lo siguiente:
- Se carga [raw_counts.csv](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/raw_counts/raw_counts.csv) y [metadata.csv](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/metadata.csv)
- Creación del objeto dds con DESeq2
- Ejecución del análisis de expresión diferencial
- Normalización de los datos
- Evaluación de batch effects
- Obtención de resultados para distintos contrastes

### 9️⃣ Visualización de los resultados

Se utilizaron los siguientes scripts: [Visualizacion1.R](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/scripts_R/Visualizacion1.R), [Visualizacion2.R](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/scripts_R/Visualizacion2.R), [Visualizacion3.R](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/scripts_R/Visualizacion3.R) y [Visualizacion4.R](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/scripts_R/Visualizacion4.R)
Donde estos scripts incluyen:
Gráficas: PCA, heatmaps, volcano plots

### 🔟 Análisis funcional: GO terms

Se utilizó el script: [GOterms_analysis.R](https://github.com/celiapuente/Proyecto_RNA-seq/blob/main/scripts_R/go_terms.R)
Este script realiza el análisis de enriquecimiento de términos funcionales Gene Ontology (GO) a partir de los genes diferencialmente expresados (DEGs).

Para analizar distintos contrastes, simplemente se modifica la línea del archivo de entrada:
```R
# Seleccionar un archivo CSV con resultados de DEG
files <- "DE_LamCiR_vs_attp2_1wk.csv"
```
De esta manera, el mismo script puede reutilizarse para todos los contrastes, cambiando únicamente el archivo .csv correspondiente a cada comparación.
