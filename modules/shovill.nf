process shovill {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}*.{fa,log}", mode: 'copy'

    cpus 8

    input:
      tuple val(sample_id), path(reads_1), path(reads_2)

    output:
      tuple val(sample_id), path("${sample_id}.fa"), emit: assembly
      tuple val(sample_id), path("${sample_id}_shovill.log"), emit: log

    script:
      """
      shovill --cpus ${task.cpus} --trim --namefmt \"${sample_id}_contig%0d\" --outdir ${sample_id}_assembly --R1 ${reads_1} --R2 ${reads_2}
      cp ${sample_id}_assembly/contigs.fa ${sample_id}.fa
      cp ${sample_id}_assembly/shovill.log ${sample_id}_shovill.log
      """
}
