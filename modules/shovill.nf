process shovill {

    tag { sample_id }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}_shovill.{fa,log}", mode: 'copy'


    input:
      tuple val(sample_id), path(reads_1), path(reads_2)

    output:
      tuple val(sample_id), path("${sample_id}_shovill.fa"), val("shovill"), emit: assembly
      tuple val(sample_id), path("${sample_id}_shovill.log"), emit: log
      tuple val(sample_id), path("${sample_id}_shovill_provenance.yml"), emit: provenance

    script:
      """
      printf -- "- process_name: shovill\\n" > ${sample_id}_shovill_provenance.yml
      printf -- "  tool_name: shovill\\n  tool_version: \$(shovill --version | cut -d ' ' -f 2)\\n" >> ${sample_id}_shovill_provenance.yml
      shovill --cpus ${task.cpus} --trim --namefmt \"${sample_id}_contig%0d\" --outdir ${sample_id}_assembly --R1 ${reads_1} --R2 ${reads_2}
      cp ${sample_id}_assembly/contigs.fa ${sample_id}_shovill.fa
      cp ${sample_id}_assembly/shovill.log ${sample_id}_shovill.log
      """
}
