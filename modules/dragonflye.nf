process dragonflye {

    tag { sample_id }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}_dragonflye.{fa,gfa,log}", mode: 'copy'

    input:
      tuple val(sample_id), path(reads)

    output:
      tuple val(sample_id), path("${sample_id}_dragonflye.fa"), val("dragonflye"), emit: assembly
      tuple val(sample_id), path("${sample_id}_dragonflye.gfa"), emit: assembly_graph
      tuple val(sample_id), path("${sample_id}_dragonflye.log"), emit: log
      tuple val(sample_id), path("${sample_id}_dragonflye_provenance.yml"), emit: provenance

    script:
      """
      printf -- "- process_name: dragonflye\\n" > ${sample_id}_dragonflye_provenance.yml
      printf -- "  tool_name: dragonflye\\n  tool_version: \$(dragonflye --version)\\n" >> ${sample_id}_dragonflye_provenance.yml
      dragonflye --cpus ${task.cpus} \
        --opts "--plasmids" \
        --reads ${reads} \
	--outdir ${sample_id}_assembly
      sed 's/^>/>${sample_id}_/' ${sample_id}_assembly/contigs.fa > ${sample_id}_dragonflye.fa
      cp ${sample_id}_assembly/flye-unpolished.gfa ${sample_id}_dragonflye.gfa
      cp ${sample_id}_assembly/dragonflye.log ${sample_id}_dragonflye.log
      """
}
