#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { shovill } from './modules/shovill.nf'
include { unicycler } from './modules/unicycler.nf'
include { prokka } from './modules/prokka.nf'
include { bakta } from './modules/bakta.nf'
include { quast } from './modules/quast.nf'
include { parse_quast_report } from './modules/quast.nf'


workflow {
  ch_fastq = Channel.fromFilePairs( params.fastq_search_path, flat: true ).map{ it -> [it[0].split('_')[0], it[1], it[2]] }.unique{ it -> it[0] }
  run_shovill = params.shovill ? false : true
  run_unicycler = run_shovill ? false : true
  run_prokka = params.bakta ? false : true
  run_bakta = run_prokka ? false : true
  main:
    if (run_shovill) {
      ch_assembly = shovill(ch_fastq).assembly
    } else {
      ch_assembly = unicycler(ch_fastq).assembly
    }
    if (run_prokka) {
      prokka(ch_assembly)
    } else if (run_bakta) {
      bakta(ch_assembly)
    }
    quast(ch_assembly)
    parse_quast_report(quast.out)
}
