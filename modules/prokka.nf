process prokka {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}.{gbk,gff}", mode: 'copy'

    cpus 8

    input:
      tuple val(sample_id), path(assembly)

    output:
      tuple val(sample_id), path("${sample_id}.gbk"), path("${sample_id}.gff")

    script:
      """
      prokka --cpus ${task.cpus} --compliant --locustag ${sample_id} --centre "BCCDC-PHL" --prefix "${sample_id}" ${assembly}
      cp ${sample_id}/${sample_id}.gbk .
      cp ${sample_id}/${sample_id}.gff .
      """
}
