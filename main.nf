#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { shovill } from './modules/shovill.nf'
include { prokka } from './modules/prokka.nf'
// include { quast } from './modules/quast.nf'


workflow {
  ch_fastq = Channel.fromFilePairs( "${params.run_dir}/Data/Intensities/BaseCalls/*_{R1,R2}_*.fastq.gz" )
  ch_run_dir = Channel.fromPath(params.run_dir)
  ch_run_id = Channel.fromPath(params.run_dir).map{ it -> it.baseName }
  
  
  main:
    shovill(ch_fastq)
    prokka(shovill.out)

}