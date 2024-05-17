process prokka {

    tag { sample_id + ' / ' + assembly_mode}

    errorStrategy 'ignore'

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_${assembler}_${assembly_mode}_prokka.{gbk,gff}", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly), val(assembler), val(assembly_mode)

    output:
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_prokka.gbk"),            emit: gbk
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_prokka.gff"),            emit: gff
    tuple val(sample_id), path("${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml"), emit: provenance

    script:
    locustag = params.use_sample_id_as_annotation_locustag ? "--locustag \"${sample_id}\"" : ""
    """
    printf -- "- process_name: prokka\\n"                                          >> ${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml
    printf -- "  tools:\\n"                                                        >> ${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml
    printf -- "    - tool_name: prokka\\n"                                         >> ${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml  
    printf -- "      tool_version: \$(prokka --version 2>&1 | cut -d ' ' -f 2)\\n" >> ${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml  
    printf -- "      parameters:\\n"                                               >> ${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml
    printf -- "        - parameter: --compliant\\n"                                >> ${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml
    printf -- "          value: null\\n"                                           >> ${sample_id}_${assembler}_${assembly_mode}_prokka_provenance.yml

    prokka \
	--cpus ${task.cpus} \
	--compliant \
	${locustag} \
	--centre "${params.annotation_centre}" \
	--prefix "${sample_id}" \
	${assembly}

    cp ${sample_id}/${sample_id}.gbk ${sample_id}_${assembler}_${assembly_mode}_prokka.gbk
    cp ${sample_id}/${sample_id}.gff ${sample_id}_${assembler}_${assembly_mode}_prokka.gff
    """
}
