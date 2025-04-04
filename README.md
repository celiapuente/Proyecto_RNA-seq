# Proyecto_RNA-seq
## Integrantes del equipo:
- Celia Maria Puente Solis  
- Samantha Melissa Pacheco Gomez  
- Miriam Alejandra Jimenez Marmolejo  

**Fecha:** 04 de abril de 2025  
**Materia:** Bioinformática Avanzada  
**Semestre cursado:** 4to semestre  

---

## Resumen del trabajo

----

### Organización general
Los scripts se encuentran en el directorio `/mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts` y están organizados de acuerdo con las etapas principales del análisis de datos de RNA-seq.

1. Descarga de los datos crudos
Los datos fueron descargados de ENA utilizando los IDs de los BioSamples:
**Control8 (w1118)**
Sample GSM5627955: SAMN22321270
Sample GSM5627956: SAMN22321271
Sample GSM5627957: SAMN22321272
Sample GSM5627959: SAMN22321274
Sample GSM5627960: SAMN22321275
Sample GSM5627961: SAMN22321281

**attp2**
Sample GSM5627963: SAMN22321283
Sample GSM5627964: SAMN22321284
Sample GSM5627965: SAMN22321276
Sample GSM5627968: SAMN22321279
Sample GSM5627969: SAMN22321280
Sample GSM5627970: SAMN22321285

**LamCiR:**
Sample GSM5627973: SAMN22321288
Sample GSM5627974: SAMN22321289
Sample GSM5627975: SAMN22321290

Script utilizado: /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/download_all_rawData.sge/

2. Evaluacion de calidad de los datos crudos (fastq y multiqc)
Se ejecutó el job qc1.sge, que esta en el siguiente directorio: /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/qc1.sge para realizar FastQC sobre los archivos descargados.
Luego, se generó un resumen de calidad con MultiQC, dentro del mismo script

3. Trimming
Se realizo trimming utilizando la herramienta trimmomatic. 
Primero se descargaron los adaptadores proporcionados por la profesora, de la siguiente manera:
cd /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025
# Paired-end
wget https://raw.githubusercontent.com/timflutre/trimmomatic/master/adapters/TruSeq3-PE-2.fa

Posteriormente se corrió el script /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/trim_1.sge/ 
Donde este script realiza el preprocesamiento de archivos de secuenciación *paired-end* usando Trimmomatic. Los archivos resultantes se guardan en /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/TRIM_results/.

Al finalizar, se evaluó nuevamente la calidad con FastQC y MultiQC usando el job /mnt/atgc-d1/bioinfoII/rnaseq/BioProject_2025/Equipo3/scripts/qc2.sge/.

4.  Descargamos el genoma de referencia
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



