process quast {

    tag { sample_id }

    input:
      tuple val(sample_id), path(assembly), val(assembler)

    output:
      tuple val(sample_id), path("${sample_id}_${assembler}_quast.tsv"), val(assembler), emit: tsv
      tuple val(sample_id), path("${sample_id}_${assembler}_quast_provenance.yml"), emit: provenance

    script:
      """
      printf -- "- process_name: quast\\n" > ${sample_id}_${assembler}_quast_provenance.yml
      printf -- "  tool_name: quast\\n  tool_version: \$(quast --version | cut -d ' ' -f 2 | tr -d 'v')\\n" >> ${sample_id}_${assembler}_quast_provenance.yml
      quast --threads ${task.cpus} ${assembly} --space-efficient --fast --output-dir ${sample_id}
      mv ${sample_id}/transposed_report.tsv ${sample_id}_${assembler}_quast.tsv
      """
}

process parse_quast_report {

    tag { sample_id }

    executor 'local'

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}_${assembler}_quast.csv", mode: 'copy'

    input:
      tuple val(sample_id), path(quast_report), val(assembler)

    output:
      tuple val(sample_id), path("${sample_id}_${assembler}_quast.csv")

    script:
      """
      parse_quast_report.py ${quast_report} > ${sample_id}_${assembler}_quast.csv
      """
}
