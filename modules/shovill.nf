process shovill {

    tag { sample_id + ' / ' + assembly_mode }

    label 'process_medium'

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_shovill_short.{fa,gfa,log}", mode: 'copy'


    input:
    tuple val(sample_id), path(reads), val(assembly_mode)

    output:
    tuple val(sample_id), path("${sample_id}_shovill_${assembly_mode}.fa"),  val("shovill"), val(assembly_mode), emit: assembly
    tuple val(sample_id), path("${sample_id}_shovill_${assembly_mode}.gfa"), val("shovill"), val(assembly_mode), emit: assembly_graph
    tuple val(sample_id), path("${sample_id}_shovill_${assembly_mode}.log"), val("shovill"), val(assembly_mode), emit: log
    tuple val(sample_id), path("${sample_id}_shovill_${assembly_mode}_provenance.yml"),                            emit: provenance


    script:
    def args = task.ext.args ?: ''
    def memory = task.memory ? "--ram ${task.memory.toGiga()} ": ""
    """
	printf -- "- process_name: shovill\\n"                                                 	>> ${sample_id}_shovill_${assembly_mode}_provenance.yml
	printf -- "  tools:\\n"                                                             	>> ${sample_id}_shovill_${assembly_mode}_provenance.yml
    printf -- "    - tool_name: shovill\\n"                                                	>> ${sample_id}_shovill_${assembly_mode}_provenance.yml
    printf -- "      tool_version: \$(shovill --version | cut -d' ' -f2)\\n" 				>> ${sample_id}_shovill_${assembly_mode}_provenance.yml


    shovill \\
        --R1 ${reads[0]} \\
        --R2 ${reads[1]} \\
        $args \\
        --cpus $task.cpus \\
        $memory \\
        --outdir ${sample_id}_shovill \\
        --force

	cp ${sample_id}_shovill/contigs.fa ${sample_id}_shovill_${assembly_mode}.fa
	cp ${sample_id}_shovill/contigs.gfa ${sample_id}_shovill_${assembly_mode}.gfa
	cp ${sample_id}_shovill/shovill.log ${sample_id}_shovill_${assembly_mode}.log
    """
}

