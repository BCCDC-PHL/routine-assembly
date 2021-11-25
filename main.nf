#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { hash_files } from './modules/hash_files.nf'
include { fastp } from './modules/fastp.nf'
include { fastp_json_to_csv } from './modules/fastp.nf'
include { shovill } from './modules/shovill.nf'
include { unicycler } from './modules/unicycler.nf'
include { prokka } from './modules/prokka.nf'
include { bakta } from './modules/bakta.nf'
include { quast } from './modules/quast.nf'
include { parse_quast_report } from './modules/quast.nf'


workflow {
  if (params.samplesheet_input != 'NO_FILE') {
    ch_fastq = Channel.fromPath(params.samplesheet_input).splitCsv(header: true).map{ it -> [it['ID'], it['R1'], it['R2']] }
  } else {
    ch_fastq = Channel.fromFilePairs( params.fastq_search_path, flat: true ).map{ it -> [it[0].split('_')[0], it[1], it[2]] }.unique{ it -> it[0] }
  }
  run_shovill = params.unicycler ? false : true
  run_unicycler = run_shovill ? false : true
  run_prokka = params.bakta ? false : true
  run_bakta = run_prokka ? false : true

  main:
    hash_files(ch_fastq.map{ it -> [it[0], [it[1], it[2]]] }.combine(Channel.of("fastq-input")).view())
    fastp(ch_fastq)
    fastp_json_to_csv(fastp.out.json)
    if (run_shovill) {
      ch_assembly = shovill(fastp.out.trimmed_reads).assembly
    } else {
      ch_assembly = unicycler(fastp.out.trimmed_reads).assembly
    }
    if (run_prokka) {
      prokka(ch_assembly)
    } else if (run_bakta) {
      bakta(ch_assembly)
    }
    quast(ch_assembly)
    parse_quast_report(quast.out)
}
