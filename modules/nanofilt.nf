process nanofilt {

    tag { sample_id }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}_nanofilt.log", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_L.trim.fastq.gz"), emit: trimmed_reads
    tuple val(sample_id), path("${sample_id}_nanofilt_provenance.yml"), emit: provenance

    script:
    """
    printf -- "- process_name: nanofilt\\n" > ${sample_id}_nanofilt_provenance.yml
    printf -- "  tool_name: nanofilt\\n  tool_version: \$(NanoFilt --version 2>&1 | cut -d ' ' -f 2)\\n" >> ${sample_id}_nanofilt_provenance.yml
    gunzip -c ${reads[2]} | \
      NanoFilt \
        --logfile ${sample_id}_nanofilt.log \
        --quality ${params.min_long_read_quality} | \
          gzip > ${sample_id}_L.trim.fastq.gz
    """
}
