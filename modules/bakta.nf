process bakta {

    tag { sample_id }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}*.{gbk,gff,json,log}", mode: 'copy'

    input:
      tuple val(sample_id), path(assembly), val(assembler)

    output:
      tuple val(sample_id), path("${sample_id}_${assembler}_bakta.gbk"), emit: gbk
      tuple val(sample_id), path("${sample_id}_${assembler}_bakta.gff"), emit: gff
      tuple val(sample_id), path("${sample_id}_${assembler}_bakta.json"), emit: json
      tuple val(sample_id), path("${sample_id}_${assembler}_bakta.log"), emit: log
      tuple val(sample_id), path("${sample_id}_${assembler}_bakta_provenance.yml"), emit: provenance

    script:
      """
      printf -- "- process_name: bakta\\n"                                     >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "  tools:\\n"                                                  >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "    - tool_name: bakta\\n"                                    >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "      tool_version: \$(bakta --version | cut -d ' ' -f 2)\\n" >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "      parameters:\\n"                                         >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "        - parameter: --db\\n"                                 >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "          value: ${params.bakta_db}\\n"                       >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "        - parameter: --compliant\\n"                          >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "          value: null\\n"                                     >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "        - parameter: --keep-contig-headers\\n"                >> ${sample_id}_${assembler}_bakta_provenance.yml
      printf -- "          value: null\\n"                                     >> ${sample_id}_${assembler}_bakta_provenance.yml

      bakta \
        --threads ${task.cpus} \
        --db ${params.bakta_db} \
        --compliant \
        --keep-contig-headers \
        --locus-tag ${sample_id} \
        --prefix "${sample_id}" \
        ${assembly}

      cp ${sample_id}.gff3 ${sample_id}_${assembler}_bakta.gff
      cp ${sample_id}.gbff ${sample_id}_${assembler}_bakta.gbk
      cp ${sample_id}.json ${sample_id}_${assembler}_bakta.json
      cp ${sample_id}.log ${sample_id}_${assembler}_bakta.log
      """
}
