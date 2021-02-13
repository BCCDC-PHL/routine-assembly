process prokka {

    tag { sample_id }

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "", mode: 'copy'

    cpus 8

    input:
      tuple val(sample_id), path(assembly_dir)

    output:
      tuple val(sample_id), path("${sample_id}")

    script:
      """
      prokka --compliant --strain ${sample_id} --centre "BCCDC-PHL" --outdir ${sample_id} ${assembly_dir}/contigs.fa
      """
}
