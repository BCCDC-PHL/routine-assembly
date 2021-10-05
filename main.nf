#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { shovill } from './modules/shovill.nf'
include { prokka } from './modules/prokka.nf'
include { bakta } from './modules/bakta.nf'
include { quast } from './modules/quast.nf'
include { parse_quast_report } from './modules/quast.nf'


workflow {
  ch_fastq = Channel.fromFilePairs( params.fastq_search_path, flat: true ).map{ it -> [it[0].split('_')[0], it[1], it[2]] }.unique{ it -> it[0] }
  run_prokka = params.bakta ? false : true
  run_bakta = run_prokka ? false : true
  main:
    shovill(ch_fastq)
    if (run_prokka) {
      prokka(shovill.out.assembly)
    } else if (run_bakta) {
      bakta(shovill.out.assembly)
    }
    quast(shovill.out.assembly)
    parse_quast_report(quast.out)
}
