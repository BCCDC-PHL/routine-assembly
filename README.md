# Routine Assembly
A generic pipeline for creating routine draft assemblies 

## Analyses

* Read trimming & QC: [fastp](https://github.com/OpenGene/fastp)
* Genome Assembly: [shovill](https://github.com/tseemann/shovill) or [unicycler](https://github.com/rrwick/Unicycler)
* Gene Annotation: [prokka](https://github.com/tseemann/prokka) or [bakta](https://github.com/oschwengers/bakta)
* Assembly QC: [quast](https://github.com/ablab/quast)

## Usage

By default, shovill and prokka will be used:
```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --fastq_input <fastq input directory> \
  --outdir <output directory>
```

Unicycler and/or bakta can be used with the `--unicycler` and `--bakta` flags:
```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --fastq_input <fastq input directory> \
  --unicycler \
  --bakta \
  --outdir <output directory>
```

Any combination of shovill/unicycler and prokka/bakta is supported:
Shovill with bakta:
```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --fastq_input <fastq input directory> \
  --bakta \
  --outdir <output directory>
```

Unicycler with prokka:
```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --fastq_input <fastq input directory> \
  --unicycler \
  --outdir <output directory>
```

## Output
An output directory will be created for each sample under the directory provided with the `--outdir` flag. The directory will be named by sample ID, inferred from
the fastq files (all characters before the first underscore in the fastq filenames).

If we have `sample-01_R{1,2}.fastq.gz`, the output directory will be:

```
sample-01
├── sample-01_20211125165316_provenance.yml
├── sample-01_fastp.csv
├── sample-01_fastp.json
├── sample-01_prokka.gbk
├── sample-01_prokka.gff
├── sample-01_quast.json
├── sample-01_quast.tsv
├── sample-01_shovill.fa
└── sample-01_shovill.log
```

Including the tool name suffixes to output files allows re-analysis of the same sample with multiple tools without conflicting output filenames:

```
sample-01
├── sample-01_20211125165316_provenance.yml
├── sample-01_20211128122118_provenance.yml
├── sample-01_bakta.gbk
├── sample-01_bakta.gff
├── sample-01_bakta.json
├── sample-01_bakta.log
├── sample-01_fastp.csv
├── sample-01_fastp.json
├── sample-01_prokka.gbk
├── sample-01_prokka.gff
├── sample-01_quast.json
├── sample-01_quast.tsv
├── sample-01_shovill.fa
├── sample-01_shovill.log
├── sample-01_unicycler.fa
├── sample-01_unicycler.gfa
└── sample-01_unicycler.log
```

### Provenance files
For each pipeline invocation, each sample will produce a `provenance.yml` file with the following contents:

```yml
- tool_name: fastp
  tool_version: 0.23.1
- tool_name: shovill
  tool_version: 1.1.0
- tool_name: prokka
  tool_version: 1.14.5
- tool_name: quast
  tool_version: v5.0.2
- input_filename: sample-01_R1.fastq.gz
  sha256: 4ac3055ac5f03114a005aff033e7018ea98486cbebdae669880e3f0511ed21bb
- input_filename: sample-01_R2.fastq.gz
  sha256: 8db388f56a51920752319c67b5308c7e99f2a566ca83311037a425f8d6bb1ecc
- pipeline_name: BCCDC-PHL/routine-assembly
  pipeline_version: 0.1.0
- timestamp_analysis_start: 2021-11-25T16:53:10.549863
```

The filename of the provenance file includes a timestamp with format `YYYYMMDDHHMMSS` to ensure that re-analysis of the same sample will create a unique `provenance.yml` file.
