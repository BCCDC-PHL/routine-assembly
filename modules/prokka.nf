process prokka {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_prokka.{gbk,gff}", mode: 'copy'

    input:
      tuple val(sample_id), path(assembly)

    output:
      tuple val(sample_id), path("${sample_id}.gbk"), path("${sample_id}.gff")

    script:
      """
      prokka --cpus ${task.cpus} --compliant --locustag ${sample_id} --centre "BCCDC-PHL" --prefix "${sample_id}" ${assembly}
      cp ${sample_id}/${sample_id}.gbk ${sample_id}_prokka.gbk
      cp ${sample_id}/${sample_id}.gff ${sample_id}_prokka.gff
      """
}
