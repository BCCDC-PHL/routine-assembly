process fastp {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_fastp.*", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_R1.trim.fastq.gz"), path("${sample_id}_R2.trim.fastq.gz"), emit: trimmed_reads
    tuple val(sample_id), path("${sample_id}_fastp.json"), emit: json
    tuple val(sample_id), path("${sample_id}_fastp.html"), emit: html
    tuple val(sample_id), path("${sample_id}_fastp_provenance.yml"), emit: provenance
    

    script:
    """
    printf -- "- process_name: fastp\\n"                                          >> ${sample_id}_fastp_provenance.yml
    printf -- "  tools:\\n"                                                       >> ${sample_id}_fastp_provenance.yml
    printf -- "    - tool_name: fastp\\n"                                         >> ${sample_id}_fastp_provenance.yml
    printf -- "      tool_version: \$(fastp --version 2>&1 | cut -d ' ' -f 2)\\n" >> ${sample_id}_fastp_provenance.yml
    printf -- "      parameters:\\n"                                              >> ${sample_id}_fastp_provenance.yml
    printf -- "        - parameter: --cut_tail\\n"                                >> ${sample_id}_fastp_provenance.yml
    printf -- "          value: null\\n"                                          >> ${sample_id}_fastp_provenance.yml
    printf -- "        - parameter: --trim_poly_g\\n"                             >> ${sample_id}_fastp_provenance.yml
    printf -- "          value: null\\n"                                          >> ${sample_id}_fastp_provenance.yml
    printf -- "        - parameter: --overrepresentation_analysis\\n"             >> ${sample_id}_fastp_provenance.yml
    printf -- "          value: null\\n"                                          >> ${sample_id}_fastp_provenance.yml
    printf -- "        - parameter: --detect_adapter_for_pe\\n"                   >> ${sample_id}_fastp_provenance.yml
    printf -- "          value: null\\n"                                          >> ${sample_id}_fastp_provenance.yml

    fastp \
	-t ${task.cpus} \
	-i ${reads[0]} \
	-I ${reads[1]} \
	--cut_tail \
	--trim_poly_g \
        --overrepresentation_analysis \
        --detect_adapter_for_pe \
	-o ${sample_id}_R1.trim.fastq.gz \
	-O ${sample_id}_R2.trim.fastq.gz \
	--report_title "fastp report: ${sample_id}" \
	-j ${sample_id}_fastp.json \
	--html ${sample_id}_fastp.html
    """
}

process fastp_json_to_csv {

    tag { sample_id }

    executor 'local'

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_fastp.csv", mode: 'copy'

    input:
    tuple val(sample_id), path(fastp_json)

    output:
    tuple val(sample_id), path("${sample_id}_fastp.csv")

    script:
    """
    fastp_json_to_csv.py -s ${sample_id} ${fastp_json} > ${sample_id}_fastp.csv
    """
}
