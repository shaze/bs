

process get_downloads {
    input:
      path(delivery)
    output:
      stdout emit: good
      path("${params.project}_unknown_samples"), emit: bad
    publishDir params.out, pattern: "*_unknown_samples" 
    script:
      """
      bs -c \$CONFIG dataset list --project-name=AGenDA -f csv > downloads
      get_downloads.py ${params.project} downloads $delivery
      """
}

process do_download {
    maxForks params.parallel_downloads
    input:
       tuple val(sample), val(dataid)
    output:
       path(sample)
    publishDir params.out, mode: 'move'
    script:
    """
       bs --config \$CONFIG download dataset --id $dataid --output $sample
    """
}

process check_md5 {
    input:
    path(sample)
    output:
    path(md5)
    script:
    md5="${sample}.md5"
    """
    md5sum -c $sample/md5sum.txt - > $md5
    """
}

process overall_check {
    input:
    file(md5s)
    output:
    file(err_check)
    publishDir params.out
    script:
    err_check="${params.project}_overall.md5"
    script:
    """
     cat *md5 > $err_check
    """
}

workflow {
    delivery=Channel.fromPath(params.delivery_report)
    main:
    get_downloads(delivery).good.
         splitText().
         map { it-> d=it.trim().split(); return [d[0],d[1]]; } |
    do_download |
    check_md5 | toList
    overall_check
}
