process fastp {
    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_fastp.json", mode: 'copy'

    input:
    tuple val(sample_id), path(reads_1), path(reads_2)

    output:
    tuple val(sample_id), path("${sample_id}_R1.trim.fastq.gz"), path("${sample_id}_R2.trim.fastq.gz"), emit: trimmed_reads
    tuple val(sample_id), path("${sample_id}_fastp.json"), emit: json
    

    script:
    """
    fastp \
      -t ${task.cpus} \
      -i ${reads_1} \
      -I ${reads_2} \
      --cut_tail \
      -o ${sample_id}_R1.trim.fastq.gz \
      -O ${sample_id}_R2.trim.fastq.gz \
      -j ${sample_id}_fastp.json
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