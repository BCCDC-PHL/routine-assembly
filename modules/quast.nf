process quast {

    tag { sample_id }

    input:
      tuple val(sample_id), path(assembly), val(assembler)

    output:
      tuple val(sample_id), path("${sample_id}_${assembler}_quast.tsv"), val(assembler), emit: tsv
      tuple val(sample_id), path("${sample_id}_${assembler}_quast_provenance.yml"), emit: provenance

    script:
      """
      printf -- "- tool_name: quast\\n  tool_version: \$(quast --version | cut -d ' ' -f 2 | tr -d 'v')\\n" > ${sample_id}_${assembler}_quast_provenance.yml
      quast --threads ${task.cpus} ${assembly} --space-efficient --fast --output-dir ${sample_id}
      mv ${sample_id}/transposed_report.tsv ${sample_id}_${assembler}_quast.tsv
      """
}

process parse_quast_report {

    tag { sample_id }

    executor 'local'

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_${assembler}_quast.csv", mode: 'copy'

    input:
      tuple val(sample_id), path(quast_report), val(assembler)

    output:
      tuple val(sample_id), path("${sample_id}_${assembler}_quast.csv")

    script:
      """
      parse_quast_report.py ${quast_report} > ${sample_id}_${assembler}_quast.csv
      """
}
