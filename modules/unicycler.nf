process unicycler {

    tag { sample_id }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}_unicycler.{fa,gfa,log}", mode: 'copy'

    input:
      tuple val(sample_id), path(reads)

    output:
      tuple val(sample_id), path("${sample_id}_unicycler.fa"), val("unicycler"), emit: assembly
      tuple val(sample_id), path("${sample_id}_unicycler.gfa"), emit: assembly_graph
      tuple val(sample_id), path("${sample_id}_unicycler.log"), emit: log
      tuple val(sample_id), path("${sample_id}_unicycler_provenance.yml"), emit: provenance

    script:
      long_reads = params.hybrid ? "-l ${reads[2]}" : ""
      """
      printf -- "- process_name: unicycler\\n" > ${sample_id}_unicycler_provenance.yml
      printf -- "  tool_name: unicycler\\n  tool_version: \$(unicycler --version | cut -d ' ' -f 2 | tr -d 'v')\\n" >> ${sample_id}_unicycler_provenance.yml
      unicycler --threads ${task.cpus} \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        ${long_reads} \
        -o ${sample_id}_assembly
      sed 's/^>/>${sample_id}_/' ${sample_id}_assembly/assembly.fasta > ${sample_id}_unicycler.fa
      cp ${sample_id}_assembly/assembly.gfa ${sample_id}_unicycler.gfa
      cp ${sample_id}_assembly/unicycler.log ${sample_id}_unicycler.log
      """
}
