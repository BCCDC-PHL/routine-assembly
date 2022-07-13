process filtlong {

    tag { sample_id }

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_L.filtered.fastq.gz"), emit: filtered_reads
    tuple val(sample_id), path("${sample_id}_filtlong_provenance.yml"), emit: provenance

    script:
    """
    printf -- "- process_name: filtlong\\n" > ${sample_id}_filtlong_provenance.yml
    printf -- "  tool_name: filtlong\\n  tool_version: \$(filtlong --version 2>&1 | cut -d ' ' -f 2)\\n" >> ${sample_id}_filtlong_provenance.yml
    filtlong \
      --min_length   ${params.filtlong_min_length} \
      --keep_percent ${params.filtlong_keep_percent} \
      ${reads} | \
        gzip > ${sample_id}_L.filtered.fastq.gz
    """
}


process nanoq {

    tag { sample_id }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}_nanoq_*.csv", mode: 'copy'

    input:
    tuple val(sample_id), path(reads), val(pre_or_post_filter)

    output:
    tuple val(sample_id), path("${sample_id}_nanoq_*.csv"), emit: stats
    tuple val(sample_id), path("${sample_id}_nanoq_${pre_or_post_filter}_provenance.yml"), emit: provenance

    script:
    """
    printf -- "- process_name: nanoq_${pre_or_post_filter}\\n" > ${sample_id}_nanoq_${pre_or_post_filter}_provenance.yml
    printf -- "  tool_name: nanoq\\n  tool_version: \$(nanoq --version 2>&1 | cut -d ' ' -f 2)\\n" >> ${sample_id}_nanoq_${pre_or_post_filter}_provenance.yml
    nanoq --header --stats --input ${reads} | tr ' ' ',' > ${sample_id}_nanoq_${pre_or_post_filter}.csv
    """
}
