process bakta {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}*.{gbk,gff,json,log}", mode: 'copy'

    input:
      tuple val(sample_id), path(assembly)

    output:
      tuple val(sample_id), path("${sample_id}.gbk"), emit: genbank
      tuple val(sample_id), path("${sample_id}.gff"), emit: gff
      tuple val(sample_id), path("${sample_id}_bakta.json"), emit: json
      tuple val(sample_id), path("${sample_id}_bakta.log"), emit: log

    script:
      """
      bakta --db ${params.bakta_db} --threads ${task.cpus} --compliant --keep-contig-headers --locus-tag ${sample_id} --prefix "${sample_id}" ${assembly}
      cp ${sample_id}.gff3 ${sample_id}_bakta.gff
      cp ${sample_id}.gbff ${sample_id}_bakta.gbk
      cp ${sample_id}.json ${sample_id}_bakta.json
      cp ${sample_id}.log ${sample_id}_bakta.log
      """
}