process unicycler {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}*.{fa,gfa,log}", mode: 'copy'

    input:
      tuple val(sample_id), path(reads_1), path(reads_2)

    output:
      tuple val(sample_id), path("${sample_id}.fa"), emit: assembly
      tuple val(sample_id), path("${sample_id}.gfa"), emit: assembly_graph
      tuple val(sample_id), path("${sample_id}_unicycler.log"), emit: log

    script:
      """
      unicycler --threads ${task.cpus} -1 ${reads_1} -2 ${reads_2} -o ${sample_id}_assembly
      sed 's/^>/>${sample_id}/' ${sample_id}_assembly/assembly.fasta > ${sample_id}.fa
      cp ${sample_id}_assembly/assembly.gfa ${sample_id}.gfa
      cp ${sample_id}_assembly/unicycler.log ${sample_id}_unicycler.log
      """
}
