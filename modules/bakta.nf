process bakta {

    tag { sample_id + ' / ' + assembly_mode }

    errorStrategy 'ignore'

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}*.{gbk,gff,json,log}", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly), val(assembler), val(assembly_mode)

    output:
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_bakta.gbk"),            emit: gbk
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_bakta.gff"),            emit: gff
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_bakta.json"),           emit: json
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_bakta.log"),            emit: log
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml"), emit: provenance

    script:
    locustag = params.use_sample_id_as_annotation_locustag ? "--locust-tag \"${sample_id}\"" : ""
    """
    printf -- "- process_name: bakta\\n"                                     >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "  tools:\\n"                                                  >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "    - tool_name: bakta\\n"                                    >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "      tool_version: \$(bakta --version | cut -d ' ' -f 2)\\n" >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "      parameters:\\n"                                         >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "        - parameter: --db\\n"                                 >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "          value: ${params.bakta_db}\\n"                       >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "        - parameter: --keep-contig-headers\\n"                >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml
    printf -- "          value: null\\n"                                     >> ${sample_id}_${assembler}_${assembly_mode}_bakta_provenance.yml

    mkdir tmp

    bakta \
        --threads ${task.cpus} \
        --tmp-dir ./tmp \
        --debug \
        --db ${params.bakta_db} \
        --keep-contig-headers \
        ${locustag} \
        --prefix "${sample_id}" \
        ${assembly}

    cp ${sample_id}.gff3 ${sample_id}_${assembler}_${assembly_mode}_bakta.gff
    cp ${sample_id}.gbff ${sample_id}_${assembler}_${assembly_mode}_bakta.gbk
    cp ${sample_id}.json ${sample_id}_${assembler}_${assembly_mode}_bakta.json
    cp ${sample_id}.log  ${sample_id}_${assembler}_${assembly_mode}_bakta.log
    """
}
