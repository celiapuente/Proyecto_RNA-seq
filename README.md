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

Este proyecto consistió en el análisis de datos de RNA-seq desde la descarga de datos crudos hasta la importación a R y la creación de metadatos. A continuación, se describen los pasos realizados, junto con las rutas a los scripts y datos utilizados.

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
Se obtuvo el genoma desde UCSC:
wget https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/dm6.fa.gz
wget https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/genes/dm6.refGene.gtf.gz
Después se descomprimieron los archivos:
gunzip dm6.fa.gz
gunzip dm6.refGene.gtf.gz
Estos archivos estan contenido en : /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/reference/

6. Secreo un indice en STAR
Se creó el índice del genoma utilizando el script: /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/STAR_index.sge/.

7. Alineamiento y conteo de lecturas con STAR.
El alineamiento y conteo se realizaron con STAR.
El script de alineamiento generó archivos BAM, que luego fueron usados para conteo, el script se encuentra en: /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/ali_STAR.sge/

8.Importar datos de STAR a R + creacion de metadata

Se importaron los datos a R con el siguiente script de load_data_inR_Eq3.R:


