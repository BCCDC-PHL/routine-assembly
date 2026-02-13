process checkm2 {

    tag { sample_id + ' / ' + assembly_mode }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_${assembler}_${assembly_mode}_checkm2.tsv", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly), val(assembler), val(assembly_mode)

    output:
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_checkm2.tsv"), val(assembler), val(assembly_mode), emit: tsv
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml"),                          emit: provenance

    script:
    """
    printf -- "- process_name: checkm2\\n"                               >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml
    printf -- "  tools:\\n"                                              >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml
    printf -- "    - tool_name: checkm2\\n"                              >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml
    printf -- "      tool_version: \$(checkm2 --version | tr -d 'v')\\n" >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml
    printf -- "      subcommand: predict\\n"                             >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml
    printf -- "      parameters:\\n"                                     >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml
    printf -- "        - parameter: --database_path\\n"                  >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml
    printf -- "          value: ${params.checkm2_db}\\n"                 >> ${sample_id}_${assembler}_${assembly_mode}_checkm2_provenance.yml

    mkdir -p tmp

    checkm2 predict \
        --threads ${task.cpus} \
	--database_path ${params.checkm2_db} \
	--input ${assembly} \
	--output-directory ${sample_id}_checkm2_output

    mv ${sample_id}_checkm2_output/quality_report.tsv ${sample_id}_${assembler}_${assembly_mode}_checkm2.tsv
    """
}
