process unicycler {

    tag { sample_id + ' / ' + assembly_mode }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", pattern: "${sample_id}_unicycler_${assembly_mode}.{fa,gfa,log}", mode: 'copy'

    input:
      tuple val(sample_id), path(reads), val(assembly_mode)

    output:
      tuple val(sample_id), path("${sample_id}_unicycler_${assembly_mode}.fa"),  val("unicycler"), val(assembly_mode), emit: assembly
      tuple val(sample_id), path("${sample_id}_unicycler_${assembly_mode}.gfa"), val("unicycler"), val(assembly_mode), emit: assembly_graph
      tuple val(sample_id), path("${sample_id}_unicycler_${assembly_mode}.log"), val("unicycler"), val(assembly_mode), emit: log
      tuple val(sample_id), path("${sample_id}_unicycler_${assembly_mode}_provenance.yml"),                            emit: provenance

    script:
      short_reads       = assembly_mode == "short" || assembly_mode == "hybrid" ? "-1 ${reads[0]} -2 ${reads[1]}" : ""
      hybrid_long_reads = assembly_mode == "hybrid" ? "-l ${reads[2]}" : ""
      long_reads        = assembly_mode == "long"   ? "-l ${reads[0]}" : ""
      """
      printf -- "- process_name: unicycler\\n"                                                 >> ${sample_id}_unicycler_${assembly_mode}_provenance.yml
      printf -- "  tools:\\n"                                                                  >> ${sample_id}_unicycler_${assembly_mode}_provenance.yml
      printf -- "    - tool_name: unicycler\\n"                                                >> ${sample_id}_unicycler_${assembly_mode}_provenance.yml
      printf -- "      tool_version: \$(unicycler --version | cut -d ' ' -f 2 | tr -d 'v')\\n" >> ${sample_id}_unicycler_${assembly_mode}_provenance.yml

      unicycler --threads ${task.cpus} \
        ${short_reads} \
        ${hybrid_long_reads} \
	${long_reads} \
        -o ${sample_id}_assembly

      check_for_empty_assembly.py --assembly ${sample_id}_assembly/assembly.fasta --sample-id ${sample_id}
      sed 's/^>/>${sample_id}_/' ${sample_id}_assembly/assembly.fasta > ${sample_id}_unicycler_${assembly_mode}.fa
      cp ${sample_id}_assembly/assembly.gfa ${sample_id}_unicycler_${assembly_mode}.gfa
      cp ${sample_id}_assembly/unicycler.log ${sample_id}_unicycler_${assembly_mode}.log
      """
}
