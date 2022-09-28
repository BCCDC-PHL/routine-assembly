# Routine Assembly
A generic pipeline for creating routine draft assemblies 

## Analyses

* Read trimming & QC: [fastp](https://github.com/OpenGene/fastp) and [filtlong](https://github.com/rrwick/Filtlong)
* Genome Assembly: [shovill](https://github.com/tseemann/shovill), [unicycler](https://github.com/rrwick/Unicycler) or [dragonflye](https://github.com/rpetit3/dragonflye)
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

The pipeline also supports a 'samplesheet input' mode. Pass a `samplesheet.csv` file with the headers `ID`, `R1`, `R2`:
```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --samplesheet_input <samplesheet.csv> \
  --outdir <output directory>
```

Eg:
```
ID,R1,R2
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz
sample-02,/path/to/sample-02_R1.fastq.gz,/path/to/sample-02_R2.fastq.gz
sample-03,/path/to/sample-03_R1.fastq.gz,/path/to/sample-03_R2.fastq.gz
```

### Hybrid Assembly Mode
If long (Oxford Nanopore) and short (illumina) reads are both available, hybrid assemblies can be performed with `unicycler`. Note that `shovill` does not support hybrid assemblies.
Add the `--hybrid` flag to perform hybrid assembly, and supply long reads using the `--long_reads` flag. Sample IDs for both long and short reads are taken from all characters of the
fastq files up to the first underscore `_`. Sample IDs for short and long reads must match in order for the pipeline to match them up for hybrid assembly.

```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --fastq_input <fastq input directory> \
  --long_reads <long reads input directory> \
  --unicycler \
  --hybrid \
  --outdir <output directory>
```

Hybrid assembly mode is compatible with samplesheet input mode. When using a samplesheet for hybrid assemblies, an additional field with header `LONG` is required.
Note that in this mode, because the sample IDs are explicitly provided in the samplesheet, it isn't strictly necessary that the short and long read filenames have matching sample IDs
(though it's still probably good practice to do so).

Eg:
```
ID,R1,R2,LONG
sample-01,/path/to/sample-01_R1.fastq.gz,/path/to/sample-01_R2.fastq.gz,/path/to/sample-01_L.fastq.gz
sample-02,/path/to/sample-02_R1.fastq.gz,/path/to/sample-02_R2.fastq.gz,/path/to/sample-02_L.fastq.gz
sample-03,/path/to/sample-03_R1.fastq.gz,/path/to/sample-03_R2.fastq.gz,/path/to/sample-03_L.fastq.gz
```

All samples in the samplesheet should have both short and long reads when running in hybrid assembly mode.

Run the pipeline as follows:

```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --samplesheet /path/to/samplesheet.csv \
  --unicycler \
  --hybrid \
  --outdir <output directory>
```

### Long-read-only Assembly Mode
If only long (Oxford Nanopore) reads are available, a long-read-only assembly mode is supported using the [dragonflye](https://github.com/rpetit3/dragonflye) assembler.

```
nextflow run BCCDC-PHL/routine-assembly-nf \
  --long_reads <long reads input directory> \
  --dragonflye \
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
├── sample-01_shovill_prokka.gbk
├── sample-01_shovill_prokka.gff
├── sample-01_shovill_quast.csv
├── sample-01_shovill.fa
└── sample-01_shovill.log
```

Including the tool name suffixes to output files allows re-analysis of the same sample with multiple tools without conflicting output filenames:

```
sample-01
├── sample-01_20211125165316_provenance.yml
├── sample-01_20211128122118_provenance.yml
├── sample-01_unicycler_bakta.gbk
├── sample-01_unicycler_bakta.gff
├── sample-01_unicycler_bakta.json
├── sample-01_unicycler_bakta.log
├── sample-01_fastp.csv
├── sample-01_fastp.json
├── sample-01_shovill_prokka.gbk
├── sample-01_shovill_prokka.gff
├── sample-01_shovill_quast.csv
├── sample-01_unicycler_quast.csv
├── sample-01_shovill.fa
├── sample-01_shovill.log
├── sample-01_unicycler.fa
├── sample-01_unicycler.gfa
└── sample-01_unicycler.log
```

If the `--versioned_outdir` flag is used, then a sub-directory will be created below each sample, named with the pipeline name and minor version:

```
sample-01
    └── routine-assembly-v0.2-output
        ├── sample-01_20220216172238_provenance.yml
        ├── sample-01_fastp.csv
        ├── sample-01_fastp.json
        ├── sample-01_shovill.fa
        ├── sample-01_shovill.log
        ├── sample-01_shovill_prokka.gbk
        ├── sample-01_shovill_prokka.gff
        └── sample-01_shovill_quast.csv
```

This is provided as a way of combining outputs of several different pipelines or re-analysis with future versions of this pipeline:

```
sample-01
    └── routine-assembly-v0.2-output
    │   ├── sample-01_20220216172238_provenance.yml
    │   ├── sample-01_fastp.csv
    │   ├── sample-01_fastp.json
    │   ├── sample-01_shovill.fa
    │   ├── sample-01_shovill.log
    │   ├── sample-01_shovill_prokka.gbk
    │   ├── sample-01_shovill_prokka.gff
    │   └── sample-01_shovill_quast.csv
    └── routine-assembly-v0.3-output
        ├── sample-01_20220612091224_provenance.yml
        ├── sample-01_fastp.csv
        ├── sample-01_fastp.json
        ├── sample-01_shovill.fa
        ├── sample-01_shovill.log
        ├── sample-01_shovill_prokka.gbk
        ├── sample-01_shovill_prokka.gff
        └── sample-01_shovill_quast.csv
```

### Provenance files
For each pipeline invocation, each sample will produce a `provenance.yml` file with the following contents:

```yml
- process_name: fastp
  tool_name: fastp
  tool_version: 0.23.1
- process_name: shovill
  tool_name: shovill
  tool_version: 1.1.0
- process_name: prokka
  tool_name: prokka
  tool_version: 1.14.5
- process_name: quast
  tool_name: quast
  tool_version: 5.0.2
- input_filename: sample-01_R1.fastq.gz
  sha256: 4ac3055ac5f03114a005aff033e7018ea98486cbebdae669880e3f0511ed21bb
- input_filename: sample-01_R2.fastq.gz
  sha256: 8db388f56a51920752319c67b5308c7e99f2a566ca83311037a425f8d6bb1ecc
- pipeline_name: BCCDC-PHL/routine-assembly
  pipeline_version: 0.1.0
- timestamp_analysis_start: 2021-11-25T16:53:10.549863
```

The filename of the provenance file includes a timestamp with format `YYYYMMDDHHMMSS` to ensure that re-analysis of the same sample will create a unique `provenance.yml` file.
