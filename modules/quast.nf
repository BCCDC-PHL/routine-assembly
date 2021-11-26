process quast {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_quast.tsv", mode: 'copy'

    cpus 2

    input:
      tuple val(sample_id), path(assembly)

    output:
      tuple val(sample_id), path("${sample_id}_quast.tsv"), emit: tsv
      tuple val(sample_id), path("${sample_id}_quast_provenance.yml"), emit: provenance

    script:
      """
      printf -- "- tool_name: quast\\n  tool_version: \$(quast --version | cut -d ' ' -f 2)\\n" > ${sample_id}_quast_provenance.yml
      quast --threads ${task.cpus} ${assembly} --space-efficient --fast --output-dir ${sample_id}
      mv ${sample_id}/transposed_report.tsv ${sample_id}_quast.tsv
      """
}

process parse_quast_report {

    tag { sample_id }

    executor 'local'

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_quast.json", mode: 'copy'

    input:
      tuple val(sample_id), path(quast_report)

    output:
      tuple val(sample_id), path("${sample_id}_quast.json")

    script:
      """
      parse_quast_report.py ${quast_report} > ${sample_id}_quast.json
      """
}
