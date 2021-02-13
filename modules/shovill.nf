process shovill {

    tag { sample_id }

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "${sample_id}_assembly", mode: 'copy'

    cpus 8

    input:
      tuple val(grouping_key), path(reads)

    output:
      tuple val(sample_id), path("${sample_id}_assembly")

    script:
      if (grouping_key =~ '_S[0-9]+_') {
        sample_id = grouping_key.split("_S[0-9]+_")[0]
      } else if (grouping_key =~ '_') {
        sample_id = grouping_key.split("_")[0]
      } else {
        sample_id = grouping_key
      }
      """
      shovill --cpus 8 --outdir ${sample_id}_assembly --R1 ${reads[0]} --R2 ${reads[1]}
      """
}
